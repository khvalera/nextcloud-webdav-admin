Option Explicit

Dim fso, shell, scriptDir, desktop, lnkPath, launcher, wscriptPath, shortcut
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
launcher = fso.BuildPath(scriptDir, "Start-NextcloudWebDAVAdmin.vbs")

If Not fso.FileExists(launcher) Then
    MsgBox "File not found: " & launcher, vbCritical, "Nextcloud WebDAV Admin"
    WScript.Quit 1
End If

wscriptPath = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\wscript.exe"

desktop = shell.SpecialFolders("Desktop")
lnkPath = fso.BuildPath(desktop, "Nextcloud WebDAV Admin.lnk")

Set shortcut = shell.CreateShortcut(lnkPath)
shortcut.TargetPath = wscriptPath
shortcut.Arguments = Chr(34) & launcher & Chr(34)
shortcut.WorkingDirectory = scriptDir
shortcut.IconLocation = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\imageres.dll,104"
shortcut.Save

MsgBox "Shortcut created:" & vbCrLf & lnkPath, vbInformation, "Nextcloud WebDAV Admin"
