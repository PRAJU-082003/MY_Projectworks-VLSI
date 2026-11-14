import re

def parse_questa_log(log_file):
    with open(log_file, "r") as f:
        text = f.read()

    pattern = r"PYTHON_RESULT.*MISMATCH=(\d+)\s+TOTAL_ERROR=(\d+)\s+MAX_ERROR=(\d+)\s+INJECTED=(\d+)\s+DETECTED=(\d+)"
    m = re.search(pattern, text)

    if not m:
        print("PYTHON_RESULT line not found")
        return {
            "mismatch": 0,
            "total_error": 0,
            "max_error": 0,
            "injected": 0,
            "detected": 0
        }

    return {
        "mismatch": int(m.group(1)),
        "total_error": int(m.group(2)),
        "max_error": int(m.group(3)),
        "injected": int(m.group(4)),
        "detected": int(m.group(5))
    }
