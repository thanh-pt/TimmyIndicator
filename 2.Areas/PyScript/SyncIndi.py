import shutil
import os


def move_files_with_extension(path_a, path_b, extension=".ex4"):
    for root, dirs, files in os.walk(path_a):
        # Tính toán thư mục con tương ứng trong path_b
        relative_path = os.path.relpath(root, path_a)
        target_dir = os.path.join(path_b, relative_path)
        
        # Tạo thư mục tương ứng trong path_b nếu chưa tồn tại
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)
        for file in files:
            if file.endswith(extension):
                source_file = os.path.join(root, file)
                target_file = os.path.join(target_dir, file)
                
                # Di chuyển file từ path_a sang path_b, ghi đè nếu đã tồn tại
                shutil.copy2(source_file, target_file)
                print(f"Đã chuyển: {file}")

script_path = os.path.dirname(os.path.abspath(__file__))
source = os.path.abspath(os.path.join(script_path, "../../../../../")) + '/'

targetId = '2191F4A3D14D7B4B1EBB84F924777883'
target = os.path.abspath(os.path.join(source, "../"+targetId))      + '/'
move_files_with_extension(source+'MQL4/Indicators/', target+'MQL4/Indicators/', ".ex4")
move_files_with_extension(source+'MQL4/Experts/', target+'MQL4/Experts/', ".ex4")
move_files_with_extension(source+'templates/', target+'templates/', ".tpl")

targetId = '4B5AFECFE6DF22D551907BBA5F00BB79'
target = os.path.abspath(os.path.join(source, "../"+targetId))      + '/'
move_files_with_extension(source+'MQL4/Indicators/', target+'MQL4/Indicators/', ".ex4")
move_files_with_extension(source+'MQL4/Experts/', target+'MQL4/Experts/', ".ex4")
move_files_with_extension(source+'templates/', target+'templates/', ".tpl")
