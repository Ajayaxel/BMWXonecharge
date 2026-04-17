import sys

file_path = "/Users/ajay/Desktop/bmw/Onecharge/assets/issue/Dlivery Map.json"

with open(file_path, "r") as f:
    content = f.read()

# Replace Pin color
content = content.replace(
    "0.930000035903,\n                                    0.159999997008,\n                                    0.397000002394",
    "0,\n                                    0,\n                                    0"
)

# Replace Teal color
content = content.replace(
    "0.098038998772,\n                                    0.690195958755,\n                                    0.741175991881",
    "0.15,\n                                    0.15,\n                                    0.15"
)

# Replace Blue color
content = content.replace(
    "0,\n                                    0.510000011968,\n                                    0.944999964097",
    "0.1,\n                                    0.1,\n                                    0.1"
)

with open(file_path, "w") as f:
    f.write(content)
