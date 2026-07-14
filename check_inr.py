import os
import glob

def check_files():
    files = glob.glob('lib/**/*.dart', recursive=True)
    for f in files:
        with open(f, 'rb') as file:
            content = file.read()
            if b'\xef\xbf\xbd,1' in content:
                print(f"Found corrupted INR in {f}")
            elif b'\xef\xbf\xbd' in content:
                print(f"Found general corruption in {f}")

if __name__ == '__main__':
    check_files()
