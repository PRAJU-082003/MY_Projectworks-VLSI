from PIL import Image
import numpy as np

# ============================================================
# Project parameters
# ============================================================
N = 8
DATA_WIDTH = 8
MAC_PER_PE = 4
APPROX_BITS = 4


# ============================================================
# Load real digit image
# ============================================================
def load_digit_image_as_uint8(image_path="digit.png"):
    """
    Load an image, convert to grayscale, resize to 28x28,
    and return uint8 pixel matrix.
    """
    img = Image.open(image_path).convert("L")
    img = img.resize((28, 28))
    return np.array(img, dtype=np.uint8)


# ============================================================
# Approximate multiplier golden model
# ============================================================
def approx_mult(a, b, approx_bits=4):
    exact = int(a) * int(b)
    approx = (exact >> approx_bits) << approx_bits
    return approx


def pe_4mac_golden(a_vec, b_vec):
    """
    Golden model for one PE containing 4 approximate MAC units.
    """
    total = 0

    for k in range(4):
        total += approx_mult(a_vec[k], b_vec[k], APPROX_BITS)

    return total


# ============================================================
# Quantization
# ============================================================
def quantize_uint8(x):
    x = np.array(x, dtype=np.float32)
    x = np.clip(x, 0.0, 1.0)
    q = np.round(x * 255)
    return q.astype(np.uint8)


def quantize_weight_to_uint8(w):
    w = np.array(w, dtype=np.float32)

    w_min = w.min()
    w_max = w.max()

    if w_max == w_min:
        return np.zeros_like(w, dtype=np.uint8)

    q = (w - w_min) / (w_max - w_min)
    q = np.round(q * 255)

    return q.astype(np.uint8)


# ============================================================
# Optional fake MNIST-like image
# ============================================================
def create_example_mnist_like_input():
    image = np.zeros((28, 28), dtype=np.float32)

    # White square in the center, like a simple digit-like pattern
    image[10:18, 10:18] = 1.0

    return quantize_uint8(image)


# ============================================================
# Example CNN 3x3 kernel
# ============================================================
def create_example_kernel():
    kernel = np.array([
        [0.1, 0.2, 0.1],
        [0.2, 1.0, 0.2],
        [0.1, 0.2, 0.1]
    ], dtype=np.float32)

    return quantize_weight_to_uint8(kernel).reshape(-1)


# ============================================================
# im2col: convert convolution into matrix multiplication
# ============================================================
def im2col_single_channel(image, kernel_size=3, stride=1):
    H, W = image.shape
    K = kernel_size

    out_h = (H - K) // stride + 1
    out_w = (W - K) // stride + 1

    patches = []

    for i in range(out_h):
        for j in range(out_w):
            patch = image[i:i+K, j:j+K].reshape(-1)
            patches.append(patch)

    return np.array(patches, dtype=np.uint8)


# ============================================================
# Map 9-element convolution to 4-MAC chunks
# ============================================================
def map_9element_conv_to_pe_chunks(patch9, kernel9):
    patch9 = list(patch9)
    kernel9 = list(kernel9)

    # Pad 9 elements to 12 so it becomes 3 chunks of 4
    while len(patch9) < 12:
        patch9.append(0)

    while len(kernel9) < 12:
        kernel9.append(0)

    chunks = []

    for i in range(0, 12, 4):
        a_vec = patch9[i:i+4]
        b_vec = kernel9[i:i+4]
        chunks.append((a_vec, b_vec))

    return chunks


def conv3x3_single_output_golden(patch9, kernel9):
    chunks = map_9element_conv_to_pe_chunks(patch9, kernel9)

    total = 0

    for a_vec, b_vec in chunks:
        total += pe_4mac_golden(a_vec, b_vec)

    return total


# ============================================================
# Convert 8x4 matrix blocks to RTL/UVM input format
# ============================================================
def matrix_block_to_rtl_inputs(A_block, B_block):
    """
    A_block shape: 8 x 4
    B_block shape: 8 x 4

    row_a[r][k] goes to row_a_in_flat
    col_b[c][k] goes to col_b_in_flat
    """

    row_a = []
    col_b = []

    for r in range(8):
        row_a.append([int(A_block[r][k]) for k in range(4)])

    for c in range(8):
        col_b.append([int(B_block[c][k]) for k in range(4)])

    return row_a, col_b


# ============================================================
# Create first matrix block from real image digit.png
# ============================================================
def create_first_mnist_matrix_block():
    # Use real input image
    image = load_digit_image_as_uint8("digit.png")

    kernel = create_example_kernel()

    patches = im2col_single_channel(image, kernel_size=3)

    # 28x28 image with 3x3 kernel gives 26 patches per row
    out_w = 26

    # Select patches around the center region
    start_idx = (10 * out_w) + 10

    # Take 8 useful patches and first 4 values from each patch
    A_block = patches[start_idx:start_idx + 8, 0:4]

    # Create 8 columns of weights.
    # For simple demo, repeat first 4 kernel values for all 8 columns.
    B_block = np.zeros((8, 4), dtype=np.uint8)

    for c in range(8):
        B_block[c, :] = kernel[0:4]

    return A_block, B_block


if __name__ == "__main__":
    image = load_digit_image_as_uint8("digit.png")
    kernel = create_example_kernel()

    patches = im2col_single_channel(image, kernel_size=3)

    # Select center patch
    out_w = 26
    start_idx = (10 * out_w) + 10
    first_patch = patches[start_idx]

    result = conv3x3_single_output_golden(first_patch, kernel)

    print("Image shape:", image.shape)
    print("Number of patches:", patches.shape)
    print("Selected patch:", first_patch)
    print("Kernel:", kernel)
    print("Approx conv golden output:", result)

    chunks = map_9element_conv_to_pe_chunks(first_patch, kernel)

    print("\nPE_4MAC chunks:")
    for idx, (a_vec, b_vec) in enumerate(chunks):
        print("Chunk", idx)
        print("A =", a_vec)
        print("B =", b_vec)
        print("PE output =", pe_4mac_golden(a_vec, b_vec))

    A_block, B_block = create_first_mnist_matrix_block()
    row_a, col_b = matrix_block_to_rtl_inputs(A_block, B_block)

    print("\nA_block sent to RTL:")
    print(A_block)

    print("\nB_block sent to RTL:")
    print(B_block)

    print("\nrow_a for UVM:")
    print(row_a)

    print("\ncol_b for UVM:")
    print(col_b)
