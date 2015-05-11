' The Tridion publisher in our setup does not always release memory the way it should.
' Run this script as a scheduled task every 15 minutes or so, to check the memory usage and restart the publisher service as needed to free up memory.

Option Explicit

' Declare variables
Dim objSWbemLocator, objWMIService, objProcesses, objProcess
Dim bolProcessFound, bolMaxProcessWorkingSetSizeExceeded
Dim strDeviceAddr
Dim strWindowsUser, strWindowsPass

' Set process and counter to look for
Const strSearchedProcess = "TcmPublisher.exe"
Const lngMaxProcessWorkingSetSize = 8589934592

' Define variables
bolProcessFound = False
bolMaxProcessWorkingSetSizeExceeded = False

' Connect to target machine via WMI and query for process
Set objSWbemLocator = CreateObject("WbemScripting.SWbemLocator")
Set objWMIService = objSWbemLocator.ConnectServer(strDeviceAddr,"root\cimv2",strWindowsUser, strWindowsPass)
Set objProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process where Caption='" & strSearchedProcess & "'")

' Check if the process is running
If objProcesses.Count > 0 Then
	bolProcessFound = True
Else
	bolProcessFound = False
End If

' Check memory usage
If bolProcessFound Then
	For Each objProcess In objProcesses
		If lngMaxProcessWorkingSetSize > CDbl(objProcess.WorkingSetSize) And Not bolMaxProcessWorkingSetSizeExceeded Then
			bolMaxProcessWorkingSetSizeExceeded = False
		Else
			bolMaxProcessWorkingSetSizeExceeded = True
		End If
	Next
End If

' Return result
If Not bolProcessFound Then
	wscript.Echo "Process not found"
Else
	If Not bolMaxProcessWorkingSetSizeExceeded Then
		wscript.Echo "Process memory usage OK"
	Else
		wscript.Echo "Memory usage exceeded"
		Dim objShell
		Set objShell = WScript.CreateObject("WScript.Shell")
		objShell.Run "net stop TcmPublisher", 0, true
		WScript.Sleep(1000)
		objShell.Run "net start TcmPublisher", 0, true
	End If
End If
