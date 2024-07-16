@echo off

echo usage: imgtomov.bat image.%%04d.jpg
echo.

:: If you want to crop the image, set CROP to a value between 0 and 1. It is used to remove overscan.
set CROP=1/1.15

IF NOT EXIST "%~dp0\ffmpeg.zip" (
    curl -L -o %~dp0\ffmpeg.zip https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip
) ELSE (
    echo ffmpeg.zip already exists
)

:: Extract and find the directory name inside the zip
IF NOT EXIST "%~dp0\ffmpeg" (
    echo Listing contents to find directory name...
    for /f "delims=" %%i in ('tar -tf "%~dp0\ffmpeg.zip" ^| findstr /r "bin/ffmpeg.exe$"') do set "FFMMPEG_EXE=%%i" && goto extract
    :extract
    echo Found directory: %FFMMPEG_EXE%
    mkdir "%~dp0\ffmpeg"
    tar -xf "%~dp0\ffmpeg.zip" -C "%~dp0\ffmpeg"
    echo Extracted to %FFMMPEG_EXE%
) ELSE (
    for /f "delims=" %%i in ('tar -tf "%~dp0\ffmpeg.zip" ^| findstr /r "bin/ffmpeg.exe$"') do set "FFMMPEG_EXE=%%i"
    echo Found directory: %FFMMPEG_EXE%
)

set "FFMPEG_BIN=%~dp0ffmpeg\%FFMMPEG_EXE%"

set IMG=%1
set FOLDER=%~dp1

for %%A in ("%IMG%") do set "IMG_EXTENSION=%%~xA"
for %%A in ("%IMG%") do set "IMG_WITHOUT_TOKEN=%%~nA"
for %%A in ("%IMG_WITHOUT_TOKEN%") do set "IMG_WITHOUT_TOKEN=%%~nA"

set "IMG_INPUT=%FOLDER%\%IMG_WITHOUT_TOKEN%.%%04d%IMG_EXTENSION%"
set OUTPUT=%FOLDER%\%IMG_WITHOUT_TOKEN%.mov

%FFMPEG_BIN% ^
    -r 24.0 ^
    -start_number 0 ^
    -f image2 ^
    -i %IMG_INPUT% ^
    -filter_complex "[0:v]crop=floor((iw*(%CROP%))/2)*2:floor((ih*(%CROP%))/2)*2[tmp];[tmp]colormatrix=bt601:bt709[outv]" ^
    -map "[outv]" ^
    -c:v libx264 ^
    -colorspace bt709 ^
    -pix_fmt yuv420p ^
    -crf: 20 ^
    -r 24 ^
    -y %OUTPUT%

