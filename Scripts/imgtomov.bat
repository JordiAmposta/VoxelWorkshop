@echo off

echo usage: imgtomov.bat image.%04d.jpg
echo.

:: Set FFMPEG_BIN to the path of the ffmpeg executable
set FFMPEG_BIN="T:\dispenser\packages\ffmpeg\4.3.1\Windows\bin\ffmpeg.exe"
:: If you want to crop the image, set CROP to a value between 0 and 1. It is used to remove overscan.
set CROP=0.9

set IMG=%1
set FOLDER=%~dp1
set "IMG_WITHOUT_TOKEN=%IMG:.%04d=%"
for %%A in ("%IMG_WITHOUT_TOKEN%") do set "IMG_WITHOUT_TOKEN=%%~nA"

set OUTPUT=%FOLDER%\%IMG_WITHOUT_TOKEN%.mov

%FFMPEG_BIN% ^
    -r 24.0 ^
    -start_number 0 ^
    -f image2 ^
    -i %IMG% ^
    -filter_complex "[0:v]crop=floor((iw*%CROP%)/2)*2:floor((ih*%CROP%)/2)*2[tmp];[tmp]colormatrix=bt601:bt709[outv]" ^
    -map "[outv]" ^
    -c:v libx264 ^
    -colorspace bt709 ^
    -pix_fmt yuv420p ^
    -crf: 20 ^
    -r 24 ^
    -y %OUTPUT%

