Option Explicit

Dim fso, shell, scriptDir, desktop, lnkPath, ps1, ps, shortcut
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = fso.BuildPath(scriptDir, "NextcloudWebDAVAdmin.ps1")

If Not fso.FileExists(ps1) Then
    MsgBox "File not found: " & ps1, vbCritical, "Nextcloud WebDAV Admin"
    WScript.Quit 1
End If

ps = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"

desktop = shell.SpecialFolders("Desktop")
lnkPath = fso.BuildPath(desktop, "Nextcloud WebDAV Admin.lnk")

Set shortcut = shell.CreateShortcut(lnkPath)
shortcut.TargetPath = ps
shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & ps1 & Chr(34)
shortcut.WorkingDirectory = scriptDir
shortcut.IconLocation = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\imageres.dll,104"
shortcut.Save

MsgBox "Shortcut created:" & vbCrLf & lnkPath, vbInformation, "Nextcloud WebDAV Admin"
