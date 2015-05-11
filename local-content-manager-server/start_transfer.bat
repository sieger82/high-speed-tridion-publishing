@echo off

REM Please amend all paths and IP addresses to reflect your setup!

REM start server (sender)

:loop

REM create list of zip files to send
dir /b /s "D:\ftpchina\incoming\*.zip" > D:\uftp_exe_W7-4.6.1\myFiles.txt

REM send the zip files and delete when complete
if NOT ERRORLEVEL 1 (
    D:\uftp_exe_W7-4.6.1\uftp -U 0x11112222 -Y aes256-ccm -e ecdh_rsa -b 1024 -B 104857600 -z -R -1 -M 10.0.0.1 -i D:\uftp_exe_W7-4.6.1\myFiles.txt
    if NOT ERRORLEVEL 1 (
        FOR /F "delims=" %%f IN (D:\uftp_exe_W7-4.6.1\myFiles.txt) DO (
            del "%%f" 
        )
    )
) else timeout 10

REM delete xml files older than 15 minutes
call D:\uftp_exe_W7-4.6.1\delete_old_files.vbs

goto loop


