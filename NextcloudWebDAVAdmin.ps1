# Nextcloud WebDAV Admin Portable
# Version: 0.1.0
# Config file: NextcloudWebDAVAdmin.config.json in the same directory.

param(
    [switch]$AdminSetupOnly
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WNetHelper
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct NETRESOURCE
    {
        public int dwScope;
        public int dwType;
        public int dwDisplayType;
        public int dwUsage;
        public string lpLocalName;
        public string lpRemoteName;
        public string lpComment;
        public string lpProvider;
    }

    [DllImport("mpr.dll", CharSet = CharSet.Unicode)]
    public static extern int WNetAddConnection2(
        ref NETRESOURCE lpNetResource,
        string lpPassword,
        string lpUserName,
        int dwFlags
    );

    [DllImport("mpr.dll", CharSet = CharSet.Unicode)]
    public static extern int WNetCancelConnection2(
        string lpName,
        int dwFlags,
        bool fForce
    );
}
"@

Add-Type -TypeDefinition @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

public static class ButtonIconTools
{
    [DllImport("Shell32.dll", CharSet = CharSet.Unicode)]
    public static extern int ExtractIconEx(
        string lpszFile,
        int nIconIndex,
        IntPtr[] phiconLarge,
        IntPtr[] phiconSmall,
        int nIcons
    );

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool DestroyIcon(IntPtr hIcon);

    public static Icon ExtractIcon(string file, int index)
    {
        IntPtr[] large = new IntPtr[1];
        IntPtr[] small = new IntPtr[1];

        int count = ExtractIconEx(file, index, large, small, 1);
        if (count <= 0)
        {
            return null;
        }

        Icon result = null;

        if (large[0] != IntPtr.Zero)
        {
            result = (Icon)Icon.FromHandle(large[0]).Clone();
        }
        else if (small[0] != IntPtr.Zero)
        {
            result = (Icon)Icon.FromHandle(small[0]).Clone();
        }

        if (large[0] != IntPtr.Zero)
        {
            DestroyIcon(large[0]);
        }

        if (small[0] != IntPtr.Zero)
        {
            DestroyIcon(small[0]);
        }

        return result;
    }
}
"@ -ReferencedAssemblies "System.Drawing"


$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ScriptDir "NextcloudWebDAVAdmin.config.json"

$DefaultConfig = [ordered]@{
    language = "uk"
    host = "docs.lan"
    userId = "user1"
    drive = "N:"
    davPath = "/remote.php/dav/files/user1"
    certPath = ""
    authForwardServer = "https://docs.lan"
    persistent = $true
}

$Text = @{
    uk = @{
        Title = "Nextcloud WebDAV Admin 0.1.0"
        ModeAdmin = "Режим адміністратора: доступні системні налаштування. Для монтування диска краще запускати як звичайний користувач."
        ModeUser = "Режим користувача: можна монтувати диск. Системні налаштування потребують прав адміністратора."
        Language = "Мова"
        Host = "Сервер"
        UserId = "Користувач"
        Drive = "Літера диска"
        DavPath = "Шлях"
        Password = "Пароль застосунку"
        PasswordNote = "Пароль не зберігається в конфігурації"
        Certificate = "Сертифікат"
        BrowseCert = "Огляд..."
        InstallCert = "Встановити сертифікат"
        NeedCert = "Обери файл сертифіката."
        CertInstalling = "Запуск встановлення сертифіката з правами адміністратора..."
        CertInstallDone = "Команду встановлення сертифіката виконано. Перевір результат у вікні certutil."
        SystemSetup = "Системні налаштування"
        TestHttps = "Перевірка HTTPS"
        TestNoRevoke = "Перевірка без відкликання"
        TestWebDav = "Перевірка WebDAV"
        Mount = "Підключити диск"
        Unmount = "Відключити диск"
        NetUse = "Показати підключення"
        InternetOptions = "Параметри Інтернету"
        OpenPc = "Відкрити комп’ютер"
        SaveConfig = "Зберегти конфіг"
        ReloadConfig = "Перечитати конфіг"
        Ready = "Готово."
        Hint = "Спочатку один раз натисни 'Системні налаштування', потім підключай диск як звичайний користувач."
        ConfigSaved = "Конфіг збережено."
        ConfigLoaded = "Конфіг перечитано."
        NeedPassword = "Введи App Password від Nextcloud."
        PasswordHidden = "Пароль у журнал не виводиться."
        MountOk = "Диск підключено!"
        MountFail = "Не вдалося підключити диск. Дивись журнал."
        UnmountOk = "Диск відключено!"
        AdminStarted = "Запуск системного налаштування з правами адміністратора..."
        AdminDone = "Системне налаштування виконано. Якщо потрібно — перезавантаж Windows."
        AdminNeed = "Потрібні права адміністратора."
        RevokeHint = "Якщо HTTPS дає CRYPT_E_NO_REVOCATION_CHECK: Параметри Інтернету -> Додатково -> Безпека -> вимкнути перевірку відкликання сертифіката сервера."
        HttpsOk = "HTTPS Ok"
        NoRevokeOk = "HTTPS без відкликання Ok"
        WebDavOk = "WebDav Ok"
        HttpsRevokeProblem = 'HTTPS перевірка впала через CRYPT_E_NO_REVOCATION_CHECK. Для локального сертифіката це очікувано, якщо Windows не може перевірити відкликання. Використай кнопку "Перевірка без відкликання".'
    }
    en = @{
        Title = "Nextcloud WebDAV Admin 0.1.0"
        ModeAdmin = "Administrator mode: system setup is available. For drive mapping, normal user mode is usually better."
        ModeUser = "User mode: drive mapping is available. System setup requires administrator rights."
        Language = "Language"
        Host = "Host"
        UserId = "User"
        Drive = "Drive letter"
        DavPath = "Path"
        Password = "App Password"
        PasswordNote = "Password is not saved to config"
        Certificate = "Certificate"
        BrowseCert = "Browse..."
        InstallCert = "Install certificate"
        NeedCert = "Choose a certificate file."
        CertInstalling = "Starting certificate installation with administrator rights..."
        CertInstallDone = "Certificate install command finished. Check the certutil window for details."
        SystemSetup = "System setup"
        TestHttps = "Check HTTPS"
        TestNoRevoke = "Check without revocation"
        TestWebDav = "Check WebDAV"
        Mount = "Mount drive"
        Unmount = "Unmount drive"
        NetUse = "Show connections"
        InternetOptions = "Internet options"
        OpenPc = "Open computer"
        SaveConfig = "Save config"
        ReloadConfig = "Reload config"
        Ready = "Ready."
        Hint = "Run system setup once first, then map the drive as a normal user."
        ConfigSaved = "Config saved."
        ConfigLoaded = "Config reloaded."
        NeedPassword = "Enter Nextcloud App Password."
        PasswordHidden = "Password is not printed to log."
        MountOk = "Drive mounted!"
        MountFail = "Drive mount failed. See log."
        UnmountOk = "Drive unmounted!"
        AdminStarted = "Starting system setup with administrator rights..."
        AdminDone = "System setup completed. Reboot Windows if needed."
        AdminNeed = "Administrator rights are required."
        RevokeHint = "If HTTPS returns CRYPT_E_NO_REVOCATION_CHECK: Internet Options -> Advanced -> Security -> disable Check for server certificate revocation."
        HttpsOk = "HTTPS Ok"
        NoRevokeOk = "HTTPS no-revoke Ok"
        WebDavOk = "WebDav Ok"
        HttpsRevokeProblem = 'HTTPS check failed with CRYPT_E_NO_REVOCATION_CHECK. For a local certificate, this is expected if Windows cannot check revocation. Use the "Check without revocation" button.'
    }
}

function Save-ConfigObject {
    param($Cfg)
    $json = $Cfg | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($ConfigPath, $json, [System.Text.Encoding]::UTF8)
}

function Load-Config {
    if (-not (Test-Path $ConfigPath)) {
        Save-ConfigObject $DefaultConfig
    }

    try {
        $raw = Get-Content -Raw -Encoding UTF8 $ConfigPath
        $j = $raw | ConvertFrom-Json

        $cfg = [ordered]@{}
        foreach ($k in $DefaultConfig.Keys) {
            if ($null -ne $j.$k) {
                $cfg[$k] = $j.$k
            } else {
                $cfg[$k] = $DefaultConfig[$k]
            }
        }
        return $cfg
    }
    catch {
        Save-ConfigObject $DefaultConfig
        return $DefaultConfig
    }
}

$script:Config = Load-Config

function T {
    param([string]$Key)
    $lang = [string]$script:Config.language
    if (-not $Text.ContainsKey($lang)) { $lang = "uk" }
    if ($Text[$lang].ContainsKey($Key)) { return $Text[$lang][$Key] }
    return $Key
}

function Is-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Log {
    param([string]$Message)
    if ($null -eq $script:LogBox) { return }
    $ts = Get-Date -Format "HH:mm:ss"
    $script:LogBox.AppendText("[$ts] $Message`r`n")
    $script:LogBox.SelectionStart = $script:LogBox.Text.Length
    $script:LogBox.ScrollToCaret()
}

function Run-Capture {
    param(
        [string]$Exe,
        [string]$ProcArgs,
        [string]$SafeLine,
        [int]$TimeoutSec = 45
    )

    if ([string]::IsNullOrWhiteSpace($SafeLine)) {
        Log "$Exe $ProcArgs"
    } else {
        Log $SafeLine
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    $psi.Arguments = $ProcArgs
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi

    try {
        [void]$p.Start()

        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        while (-not $p.HasExited) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 100

            if ($sw.Elapsed.TotalSeconds -ge $TimeoutSec) {
                try { $p.Kill() } catch {}
                Log ("TIMEOUT after " + $TimeoutSec + " sec. Process killed.")
                return 124
            }
        }

        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()

        if ($out.Trim()) { Log $out.Trim() }
        if ($err.Trim()) { Log ("ERR: " + $err.Trim()) }
        Log ("ExitCode: " + $p.ExitCode)
        return $p.ExitCode
    }
    catch {
        Log ("ERROR: " + $_.Exception.Message)
        return 9999
    }
}

function Run-CaptureInput {
    param(
        [string]$Exe,
        [string]$ProcArgs,
        [string]$InputText,
        [string]$SafeLine,
        [int]$TimeoutSec = 45
    )

    if ([string]::IsNullOrWhiteSpace($SafeLine)) {
        Log "$Exe $ProcArgs"
    } else {
        Log $SafeLine
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    $psi.Arguments = $ProcArgs
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi

    try {
        [void]$p.Start()

        try {
            $p.StandardInput.WriteLine($InputText)
            $p.StandardInput.Close()
        }
        catch {
            Log ("STDIN ERROR: " + $_.Exception.Message)
        }

        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        while (-not $p.HasExited) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 100

            if ($sw.Elapsed.TotalSeconds -ge $TimeoutSec) {
                try { $p.Kill() } catch {}
                Log ("TIMEOUT after " + $TimeoutSec + " sec. Process killed.")
                return 124
            }
        }

        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()

        if ($out.Trim()) { Log $out.Trim() }
        if ($err.Trim()) { Log ("ERR: " + $err.Trim()) }
        Log ("ExitCode: " + $p.ExitCode)
        return $p.ExitCode
    }
    catch {
        Log ("ERROR: " + $_.Exception.Message)
        return 9999
    }
}

function Do-AdminSetup {
    if (-not (Is-Admin)) {
        [System.Windows.Forms.MessageBox]::Show((T "AdminNeed"), (T "Title"), "OK", "Warning") | Out-Null
        return 1
    }

    $cfg = Load-Config
    $auth = [string]$cfg.authForwardServer
    if ([string]::IsNullOrWhiteSpace($auth)) {
        $auth = "https://" + [string]$cfg.host
    }

    try {
        Set-Service WebClient -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service WebClient -ErrorAction SilentlyContinue

        & "$env:SystemRoot\System32\reg.exe" add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v BasicAuthLevel /t REG_DWORD /d 1 /f | Out-Null
        & "$env:SystemRoot\System32\reg.exe" add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v AuthForwardServerList /t REG_MULTI_SZ /d "$auth" /f | Out-Null

        Restart-Service WebClient -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show((T "AdminDone"), (T "Title"), "OK", "Information") | Out-Null
        return 0
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (T "Title"), "OK", "Error") | Out-Null
        return 2
    }
}

if ($AdminSetupOnly) {
    exit (Do-AdminSetup)
}

function Gui-ToConfig {
    return [ordered]@{
        language = [string]$LangBox.SelectedItem
        host = $HostBox.Text.Trim()
        userId = $UserBox.Text.Trim()
        drive = $DriveBox.Text.Trim()
        davPath = $PathBox.Text.Trim()
        certPath = $CertPathBox.Text.Trim()
        authForwardServer = "https://" + $HostBox.Text.Trim()
        persistent = $true
    }
}

function Save-GuiConfig {
    $script:Config = Gui-ToConfig
    Save-ConfigObject $script:Config
    Apply-Language
    Log (T "ConfigSaved")
}

function Reload-GuiConfig {
    $script:Config = Load-Config
    $LangBox.SelectedItem = [string]$script:Config.language
    if ($null -eq $LangBox.SelectedItem) { $LangBox.SelectedItem = "uk" }
    $HostBox.Text = [string]$script:Config.host
    $script:LastUserId = [string]$script:Config.userId
    $UserBox.Text = [string]$script:Config.userId
    $DriveBox.Text = [string]$script:Config.drive
    $PathBox.Text = [string]$script:Config.davPath
    $CertPathBox.Text = [string]$script:Config.certPath
    $script:LastUserId = [string]$UserBox.Text.Trim()
    Apply-Language
    Log (T "ConfigLoaded")
}

function Browse-CertificateFile {
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Title = T "Certificate"
    $ofd.Filter = "Certificate files (*.cer;*.crt;*.pem)|*.cer;*.crt;*.pem|All files (*.*)|*.*"
    $ofd.Multiselect = $false

    if (-not [string]::IsNullOrWhiteSpace($CertPathBox.Text)) {
        $dir = Split-Path -Parent $CertPathBox.Text
        if (Test-Path $dir) {
            $ofd.InitialDirectory = $dir
        }
    }

    if ($ofd.ShowDialog() -eq "OK") {
        $CertPathBox.Text = $ofd.FileName
        Save-GuiConfig
    }
}

function Install-CertificateFile {
    $cert = [string]$CertPathBox.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($cert) -or -not (Test-Path $cert)) {
        [System.Windows.Forms.MessageBox]::Show((T "NeedCert"), (T "Title"), "OK", "Warning") | Out-Null
        return
    }

    Save-GuiConfig
    Log (T "CertInstalling")

    $certutil = "$env:SystemRoot\System32\certutil.exe"
    $args = '-addstore -f Root "' + $cert + '"'

    try {
        $p = Start-Process -FilePath $certutil -ArgumentList $args -Verb RunAs -Wait -PassThru
        Log ("certutil ExitCode: " + $p.ExitCode)

        if ($p.ExitCode -eq 0) {
            Log (T "CertInstallDone")
            [System.Windows.Forms.MessageBox]::Show((T "CertInstallDone"), (T "Title"), "OK", "Information") | Out-Null
        } else {
            [System.Windows.Forms.MessageBox]::Show(("certutil ExitCode: " + $p.ExitCode), (T "Title"), "OK", "Warning") | Out-Null
        }
    }
    catch {
        Log ("ERROR: " + $_.Exception.Message)
        [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, (T "Title"), "OK", "Error") | Out-Null
    }
}

function Start-AdminSetup {
    Save-GuiConfig
    Log (T "AdminStarted")

    $ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $arg = '-NoProfile -ExecutionPolicy Bypass -STA -File "' + $MyInvocation.MyCommand.Path + '" -AdminSetupOnly'

    try {
        Start-Process -FilePath $ps -ArgumentList $arg -Verb RunAs
    }
    catch {
        Log ("ERROR: " + $_.Exception.Message)
    }
}

function Get-UNC {
    $host = $HostBox.Text.Trim()
    $path = $PathBox.Text.Trim()
    $path = $path -replace '/', '\'
    $path = $path.TrimStart('\')
    return "\\$host@SSL\DavWWWRoot\$path"
}

function Test-Https {
    $url = "https://" + $HostBox.Text.Trim() + "/status.php"
    $code = Run-Capture "curl.exe" ('-sS -I "' + $url + '"') "curl -sS -I $url"
    if ($code -eq 0) {
        Log (T "HttpsOk")
    } elseif ($code -eq 35) {
        Log (T "HttpsRevokeProblem")
    }
}

function Test-NoRevoke {
    $url = "https://" + $HostBox.Text.Trim() + "/status.php"
    $code = Run-Capture "curl.exe" ('-sS --ssl-no-revoke -I "' + $url + '"') "curl -sS --ssl-no-revoke -I $url"
    if ($code -eq 0) {
        Log (T "NoRevokeOk")
    }
}

function Test-WebDav {
    $pass = $PasswordBox.Text
    if ([string]::IsNullOrWhiteSpace($pass)) {
        [System.Windows.Forms.MessageBox]::Show((T "NeedPassword"), (T "Title"), "OK", "Warning") | Out-Null
        return
    }

    $url = "https://" + $HostBox.Text.Trim() + $PathBox.Text.Trim().TrimEnd("/") + "/"
    $user = $UserBox.Text.Trim()

    Log (T "PasswordHidden")
    # -sS hides curl progress meter but still shows real errors.
    # -o NUL avoids flooding the log with XML multistatus output.
    $code = Run-Capture "curl.exe" ('-sS --ssl-no-revoke -X PROPFIND -H "Depth: 0" -u "' + $user + ':' + $pass + '" -o NUL "' + $url + '"') "curl -sS --ssl-no-revoke PROPFIND $url"
    if ($code -eq 0) {
        Log (T "WebDavOk")
        [System.Windows.Forms.MessageBox]::Show((T "WebDavOk"), (T "Title"), "OK", "Information") | Out-Null
    }
}

function Quote-ProcessArg {
    param([string]$Value)

    if ($null -eq $Value) { return '""' }

    # Quote for direct CreateProcess use, not cmd.exe.
    # Backslashes are kept unchanged; only double quotes are escaped.
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Run-HiddenNoRedirect {
    param(
        [string]$Exe,
        [string]$ProcArgs,
        [string]$SafeLine,
        [int]$TimeoutSec = 45
    )

    if ([string]::IsNullOrWhiteSpace($SafeLine)) {
        Log "$Exe $ProcArgs"
    } else {
        Log $SafeLine
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Exe
    $psi.Arguments = $ProcArgs
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardInput = $false
    $psi.RedirectStandardOutput = $false
    $psi.RedirectStandardError = $false

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi

    try {
        [void]$p.Start()

        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        while (-not $p.HasExited) {
            [System.Windows.Forms.Application]::DoEvents()
            Start-Sleep -Milliseconds 100

            if ($sw.Elapsed.TotalSeconds -ge $TimeoutSec) {
                try { $p.Kill() } catch {}
                Log ("TIMEOUT after " + $TimeoutSec + " sec. Process killed.")
                return 124
            }
        }

        Log ("ExitCode: " + $p.ExitCode)
        return $p.ExitCode
    }
    catch {
        Log ("ERROR: " + $_.Exception.Message)
        return 9999
    }
}

function Mount-Drive {
    Save-GuiConfig

    $pass = $PasswordBox.Text
    if ([string]::IsNullOrWhiteSpace($pass)) {
        [System.Windows.Forms.MessageBox]::Show((T "NeedPassword"), (T "Title"), "OK", "Warning") | Out-Null
        return
    }

    $drive = $DriveBox.Text.Trim()
    if (-not $drive.EndsWith(":")) { $drive = "$drive`:" }

    $hostName = $HostBox.Text.Trim()
    $path = $PathBox.Text.Trim()
    $pathWin = ($path -replace '/', '\').TrimStart('\')

    $unc1 = "\\$hostName@SSL\DavWWWRoot\$pathWin"
    $unc2 = "\\$hostName@SSL\$pathWin"
    $user = $UserBox.Text.Trim()

    Log ("UNC primary: " + $unc1)
    Log ("UNC fallback: " + $unc2)

    # Disconnect old mapping. Error is not fatal.
    try {
        [void][WNetHelper]::WNetCancelConnection2($drive, 0, $true)
        Log ("Old mapping removed: " + $drive)
    }
    catch {
        Log ("Old mapping remove ignored: " + $_.Exception.Message)
    }

    Log (T "PasswordHidden")
    Log "Mapping via Windows API WNetAddConnection2, not net.exe."

    $nr = New-Object WNetHelper+NETRESOURCE
    $nr.dwType = 1 # RESOURCETYPE_DISK
    $nr.lpLocalName = $drive
    $nr.lpRemoteName = $unc1
    $nr.lpProvider = $null

    $CONNECT_UPDATE_PROFILE = 0x00000001

    $code = [WNetHelper]::WNetAddConnection2([ref]$nr, $pass, $user, $CONNECT_UPDATE_PROFILE)

    if ($code -ne 0) {
        Log ("WNetAddConnection2 primary failed. Win32 code: " + $code + " - " + (New-Object ComponentModel.Win32Exception($code)).Message)
        Log "Trying fallback UNC..."

        try { [void][WNetHelper]::WNetCancelConnection2($drive, 0, $true) } catch {}

        $nr2 = New-Object WNetHelper+NETRESOURCE
        $nr2.dwType = 1
        $nr2.lpLocalName = $drive
        $nr2.lpRemoteName = $unc2
        $nr2.lpProvider = $null

        $code = [WNetHelper]::WNetAddConnection2([ref]$nr2, $pass, $user, $CONNECT_UPDATE_PROFILE)
    }

    if ($code -eq 0) {
        Log (T "MountOk")
        [System.Windows.Forms.MessageBox]::Show((T "MountOk"), (T "Title"), "OK", "Information") | Out-Null
    } else {
        $msg = (New-Object ComponentModel.Win32Exception($code)).Message
        Log ("WNetAddConnection2 failed. Win32 code: " + $code + " - " + $msg)
        [System.Windows.Forms.MessageBox]::Show(((T "MountFail") + "`r`nWin32 code: " + $code + "`r`n" + $msg), (T "Title"), "OK", "Error") | Out-Null
    }
}

function Unmount-Drive {
    $drive = $DriveBox.Text.Trim()
    if (-not $drive.EndsWith(":")) { $drive = "$drive`:" }

    Log ("Disconnect via WNetCancelConnection2: " + $drive)
    $code = [WNetHelper]::WNetCancelConnection2($drive, 1, $true)

    if ($code -eq 0) {
        Log (T "UnmountOk")
        [System.Windows.Forms.MessageBox]::Show((T "UnmountOk"), (T "Title"), "OK", "Information") | Out-Null
    } else {
        $msg = (New-Object ComponentModel.Win32Exception($code)).Message
        Log ("Disconnect failed. Win32 code: " + $code + " - " + $msg)
    }
}

function Show-NetUse {
    Run-Capture "$env:SystemRoot\System32\cmd.exe" "/c net use" "net use" | Out-Null
}

function Open-InternetOptions {
    Start-Process "inetcpl.cpl"
}

function Open-ThisPc {
    Start-Process "explorer.exe" "shell:MyComputerFolder"
}

# GUI
$Form = New-Object System.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(900, 720)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false
$Form.MinimumSize = New-Object System.Drawing.Size(900, 720)
$Form.MaximumSize = New-Object System.Drawing.Size(900, 720)
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$TitleLabel = New-Object System.Windows.Forms.Label
$TitleLabel.Location = New-Object System.Drawing.Point(20, 15)
$TitleLabel.AutoSize = $true
$TitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$Form.Controls.Add($TitleLabel)

$ModeLabel = New-Object System.Windows.Forms.Label
$ModeLabel.Location = New-Object System.Drawing.Point(20, 55)
$ModeLabel.Size = New-Object System.Drawing.Size(820, 45)
$Form.Controls.Add($ModeLabel)

function Add-Label {
    param([int]$X, [int]$Y, [int]$W)
    $l = New-Object System.Windows.Forms.Label
    $l.Location = New-Object System.Drawing.Point($X, $Y)
    $l.Size = New-Object System.Drawing.Size($W, 25)
    $Form.Controls.Add($l)
    return $l
}

$LanguageLabel = Add-Label 20 110 140
$LangBox = New-Object System.Windows.Forms.ComboBox
$LangBox.DropDownStyle = "DropDownList"
[void]$LangBox.Items.Add("uk")
[void]$LangBox.Items.Add("en")
$LangBox.SelectedItem = [string]$script:Config.language
if ($null -eq $LangBox.SelectedItem) { $LangBox.SelectedItem = "uk" }
$LangBox.Location = New-Object System.Drawing.Point(180, 108)
$LangBox.Size = New-Object System.Drawing.Size(120, 25)
$Form.Controls.Add($LangBox)

$HostLabel = Add-Label 20 145 140
$HostBox = New-Object System.Windows.Forms.TextBox
$HostBox.Text = [string]$script:Config.host
$HostBox.Location = New-Object System.Drawing.Point(180, 143)
$HostBox.Size = New-Object System.Drawing.Size(320, 25)
$Form.Controls.Add($HostBox)

$UserLabel = Add-Label 20 180 140
$UserBox = New-Object System.Windows.Forms.TextBox
$UserBox.Text = [string]$script:Config.userId
$UserBox.Location = New-Object System.Drawing.Point(180, 178)
$UserBox.Size = New-Object System.Drawing.Size(320, 25)
$Form.Controls.Add($UserBox)

$PasswordLabel = Add-Label 20 215 140
$PasswordBox = New-Object System.Windows.Forms.TextBox
$PasswordBox.Location = New-Object System.Drawing.Point(180, 213)
$PasswordBox.Size = New-Object System.Drawing.Size(320, 25)
$PasswordBox.UseSystemPasswordChar = $true
$Form.Controls.Add($PasswordBox)

$PasswordNoteLabel = New-Object System.Windows.Forms.Label
$PasswordNoteLabel.Location = New-Object System.Drawing.Point(520, 215)
$PasswordNoteLabel.Size = New-Object System.Drawing.Size(340, 25)
$Form.Controls.Add($PasswordNoteLabel)

$DriveLabel = Add-Label 20 250 140
$DriveBox = New-Object System.Windows.Forms.TextBox
$DriveBox.Text = [string]$script:Config.drive
$DriveBox.Location = New-Object System.Drawing.Point(180, 248)
$DriveBox.Size = New-Object System.Drawing.Size(90, 25)
$Form.Controls.Add($DriveBox)

$PathLabel = Add-Label 20 285 140
$PathBox = New-Object System.Windows.Forms.TextBox
$PathBox.Text = [string]$script:Config.davPath
$PathBox.Location = New-Object System.Drawing.Point(180, 283)
$PathBox.Size = New-Object System.Drawing.Size(560, 25)
$Form.Controls.Add($PathBox)

$script:LastUserId = [string]$UserBox.Text.Trim()
$script:UpdatingUserPath = $false

function Update-DavPathForUser {
    param(
        [string]$OldUser,
        [string]$NewUser
    )

    if ([string]::IsNullOrWhiteSpace($NewUser)) {
        return
    }

    if ($script:UpdatingUserPath) {
        return
    }

    $path = [string]$PathBox.Text

    if ([string]::IsNullOrWhiteSpace($path)) {
        $script:UpdatingUserPath = $true
        $PathBox.Text = "/remote.php/dav/files/" + $NewUser
        $script:UpdatingUserPath = $false
        return
    }

    # Replace the user segment in standard Nextcloud WebDAV path.
    if ($path -match '^/remote\.php/dav/files/[^/]+/?$') {
        $suffix = ""
        if ($path.EndsWith("/")) { $suffix = "/" }

        $script:UpdatingUserPath = $true
        $PathBox.Text = "/remote.php/dav/files/" + $NewUser + $suffix
        $script:UpdatingUserPath = $false
        return
    }

    # If old user is present in the path, replace only that segment.
    if (-not [string]::IsNullOrWhiteSpace($OldUser)) {
        $oldEsc = [regex]::Escape($OldUser)

        if ($path -match ('/remote\.php/dav/files/' + $oldEsc + '(/|$)')) {
            $script:UpdatingUserPath = $true
            $PathBox.Text = [regex]::Replace($path, '(/remote\.php/dav/files/)' + $oldEsc + '(/|$)', ('$1' + $NewUser + '$2'), 1)
            $script:UpdatingUserPath = $false
        }
    }
}

$UserBox.Add_TextChanged({
    $newUser = [string]$UserBox.Text.Trim()

    if ($newUser -ne $script:LastUserId) {
        Update-DavPathForUser $script:LastUserId $newUser
        $script:LastUserId = $newUser
    }
})

$CertLabel = Add-Label 20 320 140
$CertPathBox = New-Object System.Windows.Forms.TextBox
$CertPathBox.Text = [string]$script:Config.certPath
$CertPathBox.Location = New-Object System.Drawing.Point(180, 318)
$CertPathBox.Size = New-Object System.Drawing.Size(360, 25)
$Form.Controls.Add($CertPathBox)

$CertBrowseButton = New-Object System.Windows.Forms.Button
$CertBrowseButton.Location = New-Object System.Drawing.Point(550, 310)
$CertBrowseButton.Size = New-Object System.Drawing.Size(100, 42)
$CertBrowseButton.Add_Click({ Browse-CertificateFile })
$Form.Controls.Add($CertBrowseButton)

$CertInstallButton = New-Object System.Windows.Forms.Button
$CertInstallButton.Location = New-Object System.Drawing.Point(660, 310)
$CertInstallButton.Size = New-Object System.Drawing.Size(200, 42)

try {
    $certInstallIconFile = [Environment]::ExpandEnvironmentVariables("%SystemRoot%\System32\imageres.dll")
    $certInstallIcon = [ButtonIconTools]::ExtractIcon($certInstallIconFile, 1)

    if ($null -ne $certInstallIcon) {
        $CertInstallButton.Image = $certInstallIcon.ToBitmap()
        $CertInstallButton.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $CertInstallButton.TextImageRelation = [System.Windows.Forms.TextImageRelation]::ImageBeforeText
        $CertInstallButton.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $CertInstallButton.Padding = New-Object System.Windows.Forms.Padding(8, 0, 8, 0)
    }
}
catch {
    # If icon extraction fails, keep the button text-only.
}

$CertInstallButton.Add_Click({ Install-CertificateFile })
$Form.Controls.Add($CertInstallButton)

$Buttons = @{}

function Get-DllIconBitmap {
    param(
        [string]$IconFile,
        [int]$IconIndex
    )

    try {
        $expanded = [Environment]::ExpandEnvironmentVariables($IconFile)
        $icon = [ButtonIconTools]::ExtractIcon($expanded, $IconIndex)

        if ($null -ne $icon) {
            return $icon.ToBitmap()
        }
    }
    catch {
        # Fall back below
    }

    return $null
}

function Get-ButtonIcon {
    param([string]$Name)

    switch ($Name) {
        "Mount" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 9
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Application.ToBitmap()
        }
        "Unmount" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\imageres.dll" 26
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Error.ToBitmap()
        }
        "OpenPc" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 205
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::WinLogo.ToBitmap()
        }
        "InternetOptions" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 164
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Shield.ToBitmap()
        }
        "NetUse"          { return [System.Drawing.SystemIcons]::Information.ToBitmap() }
        "SystemSetup" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\imageres.dll" 22
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Shield.ToBitmap()
        }
        "TestHttps" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 13
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Information.ToBitmap()
        }
        "TestNoRevoke"    { return [System.Drawing.SystemIcons]::Warning.ToBitmap() }
        "TestWebDav" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 45
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Question.ToBitmap()
        }
        "SaveConfig" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 258
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Asterisk.ToBitmap()
        }
        "ReloadConfig" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\shell32.dll" 238
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Question.ToBitmap()
        }
        default           { return $null }
    }
}

function Add-Button {
    param([string]$Name, [int]$X, [int]$Y, [int]$W, [int]$H, [scriptblock]$Action)

    $b = New-Object System.Windows.Forms.Button
    $b.Location = New-Object System.Drawing.Point($X, $Y)
    $b.Size = New-Object System.Drawing.Size($W, $H)

    $icon = Get-ButtonIcon $Name
    if ($null -ne $icon) {
        $b.Image = $icon
        $b.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $b.TextImageRelation = [System.Windows.Forms.TextImageRelation]::ImageBeforeText
        $b.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $b.Padding = New-Object System.Windows.Forms.Padding(8, 0, 8, 0)
    }

    $b.Add_Click($Action)
    $Form.Controls.Add($b)
    $Buttons[$Name] = $b
}

Add-Button "Mount" 20 365 210 42 { Mount-Drive }
Add-Button "Unmount" 240 365 210 42 { Unmount-Drive }
Add-Button "OpenPc" 460 365 185 42 { Open-ThisPc }
Add-Button "NetUse" 655 365 205 42 { Show-NetUse }

Add-Button "SystemSetup" 20 420 230 38 { Start-AdminSetup }
Add-Button "TestHttps" 260 420 170 38 { Test-Https }
Add-Button "TestNoRevoke" 440 420 235 38 { Test-NoRevoke }
Add-Button "TestWebDav" 685 420 175 38 { Test-WebDav }

Add-Button "InternetOptions" 20 470 230 38 { Open-InternetOptions }
Add-Button "SaveConfig" 260 470 185 38 { Save-GuiConfig }
Add-Button "ReloadConfig" 455 470 200 38 { Reload-GuiConfig }

$script:LogBox = New-Object System.Windows.Forms.TextBox
$script:LogBox.Multiline = $true
$script:LogBox.ScrollBars = "Vertical"
$script:LogBox.ReadOnly = $true
$script:LogBox.Location = New-Object System.Drawing.Point(20, 525)
$script:LogBox.Size = New-Object System.Drawing.Size(840, 120)
$Form.Controls.Add($script:LogBox)

function Apply-Language {
    $script:Config.language = [string]$LangBox.SelectedItem
    $Form.Text = T "Title"
    $TitleLabel.Text = T "Title"
    $ModeLabel.Text = if (Is-Admin) { T "ModeAdmin" } else { T "ModeUser" }

    $LanguageLabel.Text = T "Language"
    $HostLabel.Text = T "Host"
    $UserLabel.Text = T "UserId"
    $DriveLabel.Text = T "Drive"
    $PathLabel.Text = T "DavPath"
    $PasswordLabel.Text = T "Password"
    $PasswordNoteLabel.Text = T "PasswordNote"
    $CertLabel.Text = T "Certificate"
    $CertBrowseButton.Text = T "BrowseCert"
    $CertInstallButton.Text = T "InstallCert"

    foreach ($k in $Buttons.Keys) {
        $Buttons[$k].Text = T $k
    }
}

$LangBox.Add_SelectedIndexChanged({
    $script:Config.language = [string]$LangBox.SelectedItem
    Apply-Language
})

Apply-Language
Log (T "Ready")
Log (T "Hint")
Log (T "RevokeHint")

[void]$Form.ShowDialog()
