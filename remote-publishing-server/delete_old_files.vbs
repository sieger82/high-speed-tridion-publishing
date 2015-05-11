On Error Resume Next

'enable show file extensions, otherwise script will fail
FileExt = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt"
Set Sh = WScript.CreateObject("WScript.Shell")
St = Sh.RegRead(FileExt)

Sh.RegWrite FileExt, 0, "REG_DWORD"

strFolder = "C:\ftpupload\incoming\"
Set objShell = CreateObject("Shell.Application")
Set objFolder = objShell.Namespace(strFolder)
Set objFSO = CreateObject("Scripting.FileSystemObject")

For Each strFileName in objFolder.Items
	If len(objFSO.GetExtensionName(strFileName)) > 0 Then
		Set objFile = objFSO.GetFile(strFolder & strFileName.Name)
		If InStr(strFileName.Name, "state.xml") >= 1 Then
			If DateDiff("s",objFile.DateLastModified,Now()) > 900 Then
				objFSO.DeleteFile(strFolder & strFileName.Name),True
			End If
		End If
	End If
Next