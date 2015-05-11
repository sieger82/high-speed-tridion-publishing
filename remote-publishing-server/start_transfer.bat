@echo off

REM Please amend all paths and IP addresses to reflect your setup!

REM start server (sender)

:loop

REM create list of xml files to send
dir /b /s "C:\ftpupload\incoming\*.state.xml" > C:\uftp_exe_W7-4.6.1\myFiles.txt

REM send the xml files
if NOT ERRORLEVEL 1 (
    REM option: -Y and -e encryption type. -b UDP datapacket size. -B send buffer size. -z sync mode. 
    REM -R max transfer speed (-1 = as fast as possible). -M remote server address -i list of files to send
    C:\uftp_exe_W7-4.6.1\uftp -Y aes256-ccm -e ecdh_rsa -b 1024 -B 104857600 -z -R -1 -M 10.0.0.2 -i C:\uftp_exe_W7-4.6.1\myFiles.txt
) else timeout 10

REM delete xml files older than 15 minutes
call C:\uftp_exe_W7-4.6.1\delete_old_files.vbs

goto loop
