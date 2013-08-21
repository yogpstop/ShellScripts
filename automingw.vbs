Const cReqPath = "http://sourceforge.net/projects/sevenzip/files/7-Zip/9.22/7z922-x64.msi/download"
Const cFileName = "7z.msi"
Set objShell = WScript.CreateObject("WScript.Shell")
Set objXmlHttp = WScript.CreateObject("WinHttp.WinHttpRequest.5.1")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objStream = WScript.CreateObject("ADODB.Stream")
objXmlHttp.Open "GET", cReqPath, False
objXmlHttp.Send
If (objXmlHttp.status <> 200) Then
  WScript.Echo "status is not 200"
  WScript.Quit
End If
objStream.Open
objStream.Type = 1
objStream.Write objXmlHttp.responseBody
objStream.SaveToFile objShell.CurrentDirectory & "\" & cFileName
objStream.Close
objShell.Run "7z.msi /q",0,True
objFSO.DeleteFile objShell.CurrentDirectory & "\" & cFileName, True
WScript.Quit

