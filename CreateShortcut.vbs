set WshShell=WScript.CreateObject("WScript.Shell")
Set Ws = CreateObject("Scripting.FileSystemObject")
'获取当前脚本路径
currentpath = Ws.GetFile(Wscript.ScriptFullName).ParentFolder.Path
set oShellLink=WshShell.CreateShortcut(currentpath & "\Starter.lnk")
oShellLink.TargetPath= currentpath & "\src\AutoHotkey64.exe"
oShellLink.Arguments  = "Starter.ah2"
oShellLink.IconLocation= currentpath & "\resource\img\Starter.ico"
oShellLink.WorkingDirectory=currentpath & "\src"
oShellLink.Save