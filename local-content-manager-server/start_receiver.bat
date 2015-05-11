@echo off
REM start client (reciever / listener)

REM -p set the listening port
REM -D set the incoming directory
REM -t use temporary file names when receiving
REM -B set the receive buffer to 100MB
REM -E only accept encrypted connections

D:\uftp_exe_W7-4.6.1\uftpd -p 1044 -D "D:\ftpchina\incoming" -t -B 104857600 -E 