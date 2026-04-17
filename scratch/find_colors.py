import re

file_path = "/Users/ajay/Desktop/bmw/Onecharge/assets/issue/Dlivery Map.json"
with open(file_path, 'r') as f:
    content = f.read()

# Find all blocks like "k": [ r, g, b, a ]
# Handling potential whitespace and newlines
pattern = r'"k":\s*\[\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+),\s*([0-9.]+)\s*\]'
matches = re.finditer(pattern, content)

unique_colors = set()
for match in matches:
    colors = (match.group(1), match.group(2), match.group(3), match.group(4))
    unique_colors.add(colors)

for c in sorted(unique_colors):
    print(c)
