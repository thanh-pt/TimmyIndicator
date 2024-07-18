import shutil
import os
import sys

targetId = '2191F4A3D14D7B4B1EBB84F924777883'

script_path = os.path.dirname(os.path.abspath(__file__))

source = os.path.abspath(os.path.join(script_path, "../../../../")) + '/'
target = os.path.abspath(os.path.join(source, "../"+targetId))      + '/'

def checkPath(path):
    if not os.path.exists(path):
        os.makedirs(path)

def move_files_ext(source_folder, target_folder, extention):
    # Lặp qua tất cả các file trong thư mục nguồn
    for filename in os.listdir(source_folder):
        # Kiểm tra nếu là file có đuôi '.ex4'
        if filename.endswith(extention):
            # Đường dẫn đầy đủ tới file nguồn và đích
            source_file = os.path.join(source_folder, filename)
            target_file = os.path.join(target_folder, filename)
            
            # Kiểm tra nếu thư mục đích không tồn tại, tạo mới
            if not os.path.exists(target_folder):
                os.makedirs(target_folder)
            
            # Copy file từ nguồn sang đích
            shutil.copyfile(source_file, target_file)
            print(f"Đã chuyển file: {filename}")

timmyMkrFile   = 'TimmyMaker.ex4'
timmyMkrExPath = 'MQL4/Experts/TimmyMaker/'
timmyMkrIdPath = 'MQL4/Indicators/TimmyMaker_Indi_Def/'
commonIndiPath = 'MQL4/Indicators/TimmyIndicator/'

checkPath(target+timmyMkrIdPath)
checkPath(target+timmyMkrExPath)
checkPath(target+commonIndiPath)

shutil.copyfile(source+timmyMkrIdPath+timmyMkrFile, target+timmyMkrIdPath+timmyMkrFile)
shutil.copyfile(source+timmyMkrExPath+timmyMkrFile, target+timmyMkrExPath+timmyMkrFile)

move_files_ext(source+commonIndiPath, target+commonIndiPath, '.ex4')
move_files_ext(source+'templates/'  , target+'templates/'  , '.tpl')