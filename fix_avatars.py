import os
import re

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove final List<IconData> avatarIcons = [...]; or static const List<IconData> _avatarIcons = [...];
    content = re.sub(r'(\s+)(?:static const|final)\s+List<IconData>\s+_?avatarIcons\s*=\s*\[.*?\];', r'\1', content, flags=re.DOTALL)
    
    # Fix the Icon(ClipOval(...), color, size) issue in marketing/videographer
    content = re.sub(r'Icon\(\s*ClipOval\(child: Image\.asset\(availableAvatars\[emp\.avatar % availableAvatars\.length\], fit: BoxFit\.cover, width: \d+, height: \d+\)\),\s*color:[^,]+,\s*size:[^,]+,\s*\)', r'ClipOval(child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 44, height: 44))', content, flags=re.DOTALL)
    
    # Also fix where we might not have replaced yet due to multi-line Icons
    content = re.sub(r'Icon\(\s*emp\.avatar\s*>=\s*0\s*&&\s*emp\.avatar\s*<\s*_?avatarIcons\.length\s*\?\s*_?avatarIcons\[emp\.avatar\]\s*:\s*Icons\.face,\s*color:[^,]+,\s*size:[^,]+,\s*\)', r'ClipOval(child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 44, height: 44))', content, flags=re.DOTALL)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base_dir = r"c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens"
fix_file(os.path.join(base_dir, "marketing_executive_dashboard.dart"))
fix_file(os.path.join(base_dir, "videographer_dashboard.dart"))
fix_file(os.path.join(base_dir, "employee_dashboard.dart"))

print("Files fixed.")
