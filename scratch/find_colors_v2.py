import re

file_path = "/Users/ajay/Desktop/bmw/Onecharge/assets/issue/Dlivery Map.json"
with open(file_path, 'r') as f:
    content = f.read()

# Find all color arrays [r, g, b, a] where r, g, b < 1 and they look like colors
# Lottie colors are almost always 4 numbers between 0 and 1
pattern = r'\[\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)\s*\]'
matches = re.finditer(pattern, content)

unique_colors = set()
for match in matches:
    r, g, b, a = float(match.group(1)), float(match.group(2)), float(match.group(3)), float(match.group(4))
    if a == 1.0 and (0 <= r <= 1) and (0 <= g <= 1) and (0 <= b <= 1):
        unique_colors.add((match.group(1), match.group(2), match.group(3), match.group(4)))

for c in sorted(unique_colors):
    print(c)
