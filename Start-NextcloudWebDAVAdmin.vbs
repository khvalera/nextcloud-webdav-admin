Option Explicit

Dim fso, shell, scriptDir, ps1, ps, cmd
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1 = fso.BuildPath(scriptDir, "NextcloudWebDAVAdmin.ps1")

If Not fso.FileExists(ps1) Then
    MsgBox "File not found: " & ps1, vbCritical, "Nextcloud WebDAV Admin"
    WScript.Quit 1
End If

ps = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
cmd = Chr(34) & ps & Chr(34) & " -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File " & Chr(34) & ps1 & Chr(34)

' 0 = hidden window, False = do not wait
shell.Run cmd, 0, False
