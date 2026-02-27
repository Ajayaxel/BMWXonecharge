import os

pbxproj_path = "/Users/apple/Desktop/Onecharge/ios/Runner.xcodeproj/project.pbxproj"

if not os.path.exists(pbxproj_path):
    print(f"Error: {pbxproj_path} not found")
    exit(1)

with open(pbxproj_path, 'r') as f:
    content = f.read()

# Add entitlements to build settings
if "CODE_SIGN_ENTITLEMENTS" not in content:
    content = content.replace(
        "INFOPLIST_FILE = Runner/Info.plist;",
        "INFOPLIST_FILE = Runner/Info.plist;\n\t\t\t\tCODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;"
    )

with open(pbxproj_path, 'w') as f:
    f.write(content)

print("Successfully added CODE_SIGN_ENTITLEMENTS to pbxproj")
