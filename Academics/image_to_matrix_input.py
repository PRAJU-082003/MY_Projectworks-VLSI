from PIL import Image
import numpy as np


def load_digit_image_as_uint8(image_path):
    """
    Reads an image file, converts it to 28x28 grayscale,
    and returns uint8 pixel matrix.
    """

    img = Image.open(image_path).convert("L")
    img = img.resize((28, 28))

    arr = np.array(img, dtype=np.uint8)

    return arr


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


def create_simple_kernel_uint8():
    """
    Example 3x3 CNN kernel.
    """
    kernel = np.array([
        [25,  50, 25],
        [50, 255, 50],
        [25,  50, 25]
    ], dtype=np.uint8)

    return kernel.reshape(-1)


def image_to_first_matrix_block(image_path):
    """
    Converts image to one 8x4 A block and one 8x4 B block.
    This block can be sent to your 8x8 systolic array.
    """

    image = load_digit_image_as_uint8(image_path)
    kernel = create_simple_kernel_uint8()

    patches = im2col_single_channel(image, kernel_size=3)

    # choose center region patches, not top-left zero region
    out_w = 26
    start_idx = (10 * out_w) + 10

    A_block = patches[start_idx:start_idx + 8, 0:4]

    B_block = np.zeros((8, 4), dtype=np.uint8)

    for c in range(8):
        B_block[c, :] = kernel[0:4]

    return A_block, B_block


if __name__ == "__main__":
    A_block, B_block = image_to_first_matrix_block("digit.png")

    print("A_block from image:")
    print(A_block)

    print("\nB_block from CNN kernel:")
    print(B_block)
