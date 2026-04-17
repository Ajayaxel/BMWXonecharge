import sys

file_path = "/Users/ajay/Desktop/bmw/Onecharge/assets/issue/Dlivery Map.json"

with open(file_path, "r") as f:
    content = f.read()

# Replace Route color
content = content.replace(
    "0.021139537587,\n                                    0.350254462747,\n                                    0.929411764706",
    "0.2,\n                                    0.2,\n                                    0.2"
)

with open(file_path, "w") as f:
    f.write(content)
