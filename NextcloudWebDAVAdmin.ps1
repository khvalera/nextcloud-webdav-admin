# Nextcloud WebDAV Admin Portable
# Version: 0.1.2
# Config file: NextcloudWebDAVAdmin.config.json in the same directory.

param(
    [switch]$AdminSetupOnly,
    [switch]$AutoMount
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

$ConfigFileName = "NextcloudWebDAVAdmin.config.json"

# 0.1.2:
# User config has priority and is always used for saving.
# Portable config near the program is only a fallback/default template.
$UserConfigDir = Join-Path $env:APPDATA "NextcloudWebDAVAdmin"
$UserConfigPath = Join-Path $UserConfigDir $ConfigFileName
$PortableConfigPath = Join-Path $ScriptDir $ConfigFileName

$ConfigPath = $UserConfigPath

$PasswordFile = Join-Path $UserConfigDir "nextcloud-webdav-app-password.dpapi"
$AutoMountScriptPath = Join-Path $UserConfigDir "NextcloudWebDAVAdmin.ps1"
$StartupDir = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\Startup"
$StartupVbsPath = Join-Path $StartupDir "Nextcloud-WebDAV-N.vbs"
$LogFilePath = Join-Path $UserConfigDir "NextcloudWebDAVAdmin.log"


$DefaultConfig = [ordered]@{
    language = "uk"
    host = "docs.lan"
    userId = "user1"
    drive = "N:"
    davPath = "/remote.php/dav/files/user1"
    certPath = ""
    authForwardServer = "https://docs.lan"
    persistent = $false
}

$Text = @{
    uk = @{
        Title = "Nextcloud WebDAV Admin 0.1.2"
        ModeAdmin = "Режим адміністратора: доступні системні налаштування. Для монтування диска краще запускати як звичайний користувач."
        ModeUser = "Режим користувача: можна монтувати диск. Системні налаштування потребують прав адміністратора."
        Language = "Мова"
        Host = "Сервер"
        UserId = "Користувач"
        Drive = "Літера диска"
        DavPath = "Шлях"
        Password = "Пароль застосунку"
        PasswordNote = "Пароль не в конфігу; для автозапуску натисни Зберегти пароль"
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
        SavePassword = "Зберегти пароль"
        InstallAutoStart = "Автопідключення"
        RemoveAutoStart = "Прибрати автозапуск"
        Ready = "Готово."
        Hint = "Спочатку один раз натисни 'Системні налаштування', потім підключай диск як звичайний користувач."
        ConfigSaved = "Конфіг збережено."
        ConfigLoaded = "Конфіг перечитано."
        NeedPassword = "Введи App Password від Nextcloud."
        PasswordSaved = "App Password збережено через DPAPI."
        PasswordMissingForAuto = "Для автопідключення спочатку збережи App Password."
        AutoStartInstalled = "Тихий автозапуск встановлено."
        AutoStartRemoved = "Автозапуск видалено."
        PasswordHidden = "Пароль у журнал не виводиться."
        MountOk = "Диск підключено!"
        MountFail = "Не вдалося підключити диск. Дивись журнал."
        UnmountOk = "Диск відключено!"
        AdminStarted = "Запуск системного налаштування з правами адміністратора..."
        AdminDone = "Системне налаштування виконано. Якщо потрібно — перезавантаж Windows."
        AdminNeed = "Потрібні права адміністратора."
        RevokeHint = "0.1.2: монтування через WScript.Network persistent=false. Тихий запуск: Start-NextcloudWebDAVAdmin.vbs або ярлик. Якщо сервер дає 429 — скинь Nextcloud brute-force для IP клієнта."
        HttpsOk = "HTTPS Ok"
        NoRevokeOk = "HTTPS без відкликання Ok"
        WebDavOk = "WebDav Ok"
        HttpsRevokeProblem = 'HTTPS перевірка впала через CRYPT_E_NO_REVOCATION_CHECK. Для локального сертифіката це очікувано, якщо Windows не може перевірити відкликання. Використай кнопку "Перевірка без відкликання".'
    }
    en = @{
        Title = "Nextcloud WebDAV Admin 0.1.2"
        ModeAdmin = "Administrator mode: system setup is available. For drive mapping, normal user mode is usually better."
        ModeUser = "User mode: drive mapping is available. System setup requires administrator rights."
        Language = "Language"
        Host = "Host"
        UserId = "User"
        Drive = "Drive letter"
        DavPath = "Path"
        Password = "App Password"
        PasswordNote = "Password is not in config; use Save password for autostart"
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
        SavePassword = "Save password"
        InstallAutoStart = "Install autostart"
        RemoveAutoStart = "Remove autostart"
        Ready = "Ready."
        Hint = "Run system setup once first, then map the drive as a normal user."
        ConfigSaved = "Config saved."
        ConfigLoaded = "Config reloaded."
        NeedPassword = "Enter Nextcloud App Password."
        PasswordSaved = "App Password saved with DPAPI."
        PasswordMissingForAuto = "Save the App Password first for autostart."
        AutoStartInstalled = "Silent autostart installed."
        AutoStartRemoved = "Autostart removed."
        PasswordHidden = "Password is not printed to log."
        MountOk = "Drive mounted!"
        MountFail = "Drive mount failed. See log."
        UnmountOk = "Drive unmounted!"
        AdminStarted = "Starting system setup with administrator rights..."
        AdminDone = "System setup completed. Reboot Windows if needed."
        AdminNeed = "Administrator rights are required."
        RevokeHint = "0.1.2: maps via WScript.Network persistent=false. If server returns 429, reset Nextcloud brute-force for the client IP."
        HttpsOk = "HTTPS Ok"
        NoRevokeOk = "HTTPS no-revoke Ok"
        WebDavOk = "WebDav Ok"
        HttpsRevokeProblem = 'HTTPS check failed with CRYPT_E_NO_REVOCATION_CHECK. For a local certificate, this is expected if Windows cannot check revocation. Use the "Check without revocation" button.'
    }
}

function Ensure-UserConfigDir {
    if (-not (Test-Path $UserConfigDir)) {
        New-Item -ItemType Directory -Path $UserConfigDir -Force | Out-Null
    }
}

function Save-ConfigObject {
    param($Cfg)

    Ensure-UserConfigDir

    $json = $Cfg | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($UserConfigPath, $json, [System.Text.Encoding]::UTF8)
}

function Read-ConfigObjectFromPath {
    param([string]$Path)

    $raw = Get-Content -Raw -Encoding UTF8 $Path
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

function Load-Config {
    # 1. First try user config.
    if (Test-Path $UserConfigPath) {
        try {
            return Read-ConfigObjectFromPath $UserConfigPath
        }
        catch {
            try {
                Ensure-UserConfigDir
                $backup = $UserConfigPath + ".broken-" + (Get-Date -Format "yyyyMMdd-HHmmss")
                Copy-Item -Path $UserConfigPath -Destination $backup -Force
            }
            catch {
                # Ignore backup errors
            }

            Save-ConfigObject $DefaultConfig
            return $DefaultConfig
        }
    }

    # 2. Fallback: read config next to the program.
    if (Test-Path $PortableConfigPath) {
        try {
            $cfg = Read-ConfigObjectFromPath $PortableConfigPath

            # Migrate fallback config to the user profile.
            Save-ConfigObject $cfg
            return $cfg
        }
        catch {
            Save-ConfigObject $DefaultConfig
            return $DefaultConfig
        }
    }

    # 3. No config exists: create default user config.
    Save-ConfigObject $DefaultConfig
    return $DefaultConfig
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

    try {
        Ensure-UserConfigDir
        $tsFull = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content -Path $LogFilePath -Value ("[$tsFull] $Message") -Encoding UTF8
    }
    catch {
        # Ignore file log errors.
    }

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

function Convert-SecureStringToPlainText {
    param([System.Security.SecureString]$SecureString)

    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Save-AppPasswordPlainText {
    param([string]$Password)

    if ([string]::IsNullOrWhiteSpace($Password)) {
        throw (T "NeedPassword")
    }

    Ensure-UserConfigDir
    $secure = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $secure | ConvertFrom-SecureString | Set-Content -Path $PasswordFile -Encoding ASCII
    Log (T "PasswordSaved")
}

function Read-SavedAppPasswordPlainText {
    if (-not (Test-Path $PasswordFile)) {
        throw (T "PasswordMissingForAuto")
    }

    $secure = Get-Content -Path $PasswordFile -ErrorAction Stop | ConvertTo-SecureString
    return Convert-SecureStringToPlainText $secure
}

function Get-NormalizedDrive {
    param([string]$Drive)
    $d = [string]$Drive.Trim()
    if (-not $d.EndsWith(":")) { $d = "$d`:" }
    return $d
}

function Get-WebDavUnc {
    param(
        [string]$HostName,
        [string]$DavPath
    )

    $pathWin = ([string]$DavPath -replace '/', '\').TrimStart('\')
    return "\\$HostName@SSL\DavWWWRoot\$pathWin"
}

function Clear-DriveMappingInternal {
    param([string]$Drive)

    $d = Get-NormalizedDrive $Drive
    $letter = $d.TrimEnd(":")

    Log ("Disable net use persistent default")
    Run-Capture "$env:SystemRoot\System32\net.exe" "use /persistent:no" "net use /persistent:no" 20 | Out-Null

    Log ("Remove current/remembered mapping: " + $d)
    try { [void][WNetHelper]::WNetCancelConnection2($d, 1, $true) } catch {}
    Run-Capture "$env:SystemRoot\System32\net.exe" ("use " + $d + " /delete /y") ("net use " + $d + " /delete /y") 20 | Out-Null
    Run-Capture "$env:SystemRoot\System32\reg.exe" ('delete "HKCU\Network\' + $letter + '" /f') ('reg delete "HKCU\Network\' + $letter + '" /f') 20 | Out-Null
}

function Mount-WebDavInternal {
    param(
        [string]$Drive,
        [string]$HostName,
        [string]$DavPath,
        [string]$UserName,
        [string]$Password
    )

    $d = Get-NormalizedDrive $Drive
    $unc = Get-WebDavUnc $HostName $DavPath

    Log ("UNC: " + $unc)
    Log (T "PasswordHidden")

    Clear-DriveMappingInternal $d

    try {
        Log "Mapping via WScript.Network.MapNetworkDrive, persistent=false"
        $network = New-Object -ComObject WScript.Network
        $network.MapNetworkDrive($d, $unc, $false, $UserName, $Password)

        Start-Sleep -Seconds 1

        if (Test-Path ($d + "\")) {
            Log (T "MountOk")
            return 0
        }

        Log ("MapNetworkDrive returned without exception, but drive is not accessible: " + $d)
        return 3
    }
    catch {
        Log ("MapNetworkDrive failed: " + $_.Exception.Message)
        Log "Hint: if Apache/Nextcloud log shows HTTP 429 for Microsoft-WebDAV-MiniRedir, reset Nextcloud brute-force for the client IP."
        return 1
    }
}

function Do-AutoMount {
    $cfg = Load-Config
    $script:Config = $cfg

    Log "============================================================"
    Log "AutoMount started"
    Log ("Config: " + $ConfigPath)

    $url = "https://" + [string]$cfg.host + "/status.php"
    for ($i = 1; $i -le 12; $i++) {
        Log ("Check HTTPS " + $i + "/12: " + $url)
        & curl.exe -sS -I --connect-timeout 5 $url *> $null
        if ($LASTEXITCODE -eq 0) {
            Log "HTTPS Nextcloud доступний."
            break
        }
        Start-Sleep -Seconds 10
    }

    try {
        $pass = Read-SavedAppPasswordPlainText
    }
    catch {
        Log ("AutoMount stopped: " + $_.Exception.Message)
        return 2
    }

    return (Mount-WebDavInternal ([string]$cfg.drive) ([string]$cfg.host) ([string]$cfg.davPath) ([string]$cfg.userId) $pass)
}

function Save-AppPasswordFromGui {
    $pass = [string]$PasswordBox.Text
    if ([string]::IsNullOrWhiteSpace($pass)) {
        [System.Windows.Forms.MessageBox]::Show((T "NeedPassword"), (T "Title"), "OK", "Warning") | Out-Null
        return
    }

    Save-GuiConfig
    Save-AppPasswordPlainText $pass
    [System.Windows.Forms.MessageBox]::Show((T "PasswordSaved"), (T "Title"), "OK", "Information") | Out-Null
}

function Install-AutoStart {
    Save-GuiConfig

    if (-not (Test-Path $PasswordFile)) {
        if (-not [string]::IsNullOrWhiteSpace($PasswordBox.Text)) {
            Save-AppPasswordPlainText ([string]$PasswordBox.Text)
        }
        else {
            [System.Windows.Forms.MessageBox]::Show((T "PasswordMissingForAuto"), (T "Title"), "OK", "Warning") | Out-Null
            return
        }
    }

    Ensure-UserConfigDir
    if (-not (Test-Path $StartupDir)) { New-Item -ItemType Directory -Path $StartupDir -Force | Out-Null }

    Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $AutoMountScriptPath -Force

    $vbs = @'
Option Explicit
Dim sh, appdata, ps1, cmd
Set sh = CreateObject("WScript.Shell")
appdata = sh.ExpandEnvironmentStrings("%APPDATA%")
ps1 = appdata & "\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.ps1"
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & ps1 & Chr(34) & " -AutoMount"
sh.Run cmd, 0, False
'@

    [System.IO.File]::WriteAllText($StartupVbsPath, $vbs, [System.Text.Encoding]::ASCII)
    Log (T "AutoStartInstalled")
    [System.Windows.Forms.MessageBox]::Show((T "AutoStartInstalled"), (T "Title"), "OK", "Information") | Out-Null
}

function Remove-AutoStart {
    if (Test-Path $StartupVbsPath) {
        Remove-Item $StartupVbsPath -Force
    }

    Log (T "AutoStartRemoved")
    [System.Windows.Forms.MessageBox]::Show((T "AutoStartRemoved"), (T "Title"), "OK", "Information") | Out-Null
}

if ($AutoMount) {
    exit (Do-AutoMount)
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
        persistent = $false
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

    $pass = [string]$PasswordBox.Text
    if ([string]::IsNullOrWhiteSpace($pass)) {
        try {
            $pass = Read-SavedAppPasswordPlainText
            Log "Using saved DPAPI App Password."
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show((T "NeedPassword"), (T "Title"), "OK", "Warning") | Out-Null
            return
        }
    }

    $drive = Get-NormalizedDrive $DriveBox.Text
    $hostName = $HostBox.Text.Trim()
    $path = $PathBox.Text.Trim()
    $user = $UserBox.Text.Trim()

    $code = Mount-WebDavInternal $drive $hostName $path $user $pass

    if ($code -eq 0) {
        [System.Windows.Forms.MessageBox]::Show((T "MountOk"), (T "Title"), "OK", "Information") | Out-Null
    }
    else {
        [System.Windows.Forms.MessageBox]::Show(((T "MountFail") + "`r`nCode: " + $code + "`r`nЯкщо в Apache log є HTTP 429 — скинь Nextcloud brute-force для IP клієнта."), (T "Title"), "OK", "Error") | Out-Null
    }
}

function Unmount-Drive {
    $drive = Get-NormalizedDrive $DriveBox.Text

    Log ("Disconnect via WScript.Network and cleanup: " + $drive)

    try {
        $network = New-Object -ComObject WScript.Network
        $network.RemoveNetworkDrive($drive, $true, $false)
    }
    catch {
        Log ("RemoveNetworkDrive ignored/error: " + $_.Exception.Message)
    }

    Clear-DriveMappingInternal $drive

    Log (T "UnmountOk")
    [System.Windows.Forms.MessageBox]::Show((T "UnmountOk"), (T "Title"), "OK", "Information") | Out-Null
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
$Form.Size = New-Object System.Drawing.Size(900, 790)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Form.MaximizeBox = $false
$Form.MinimumSize = New-Object System.Drawing.Size(900, 790)
$Form.MaximumSize = New-Object System.Drawing.Size(900, 790)
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
        "SavePassword"    { return [System.Drawing.SystemIcons]::Shield.ToBitmap() }
        "InstallAutoStart" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\imageres.dll" 232
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Application.ToBitmap()
        }
        "RemoveAutoStart" {
            $bmp = Get-DllIconBitmap "%SystemRoot%\System32\imageres.dll" 229
            if ($null -ne $bmp) { return $bmp }
            return [System.Drawing.SystemIcons]::Warning.ToBitmap()
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

# 0.1.2: autostart controls are directly under the mount controls.
Add-Button "InstallAutoStart" 20 420 410 38 { Install-AutoStart }
Add-Button "RemoveAutoStart" 450 420 410 38 { Remove-AutoStart }

Add-Button "SystemSetup" 20 470 230 38 { Start-AdminSetup }
Add-Button "TestHttps" 260 470 170 38 { Test-Https }
Add-Button "TestNoRevoke" 440 470 235 38 { Test-NoRevoke }
Add-Button "TestWebDav" 685 470 175 38 { Test-WebDav }

Add-Button "InternetOptions" 20 520 230 38 { Open-InternetOptions }
Add-Button "SaveConfig" 260 520 185 38 { Save-GuiConfig }
Add-Button "ReloadConfig" 455 520 200 38 { Reload-GuiConfig }
Add-Button "SavePassword" 665 520 195 38 { Save-AppPasswordFromGui }

$script:LogBox = New-Object System.Windows.Forms.TextBox
$script:LogBox.Multiline = $true
$script:LogBox.ScrollBars = "Vertical"
$script:LogBox.ReadOnly = $true
$script:LogBox.Location = New-Object System.Drawing.Point(20, 575)
$script:LogBox.Size = New-Object System.Drawing.Size(840, 165)
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
Log ("Config: " + $ConfigPath)
Log (T "Hint")
Log (T "RevokeHint")

[void]$Form.ShowDialog()
