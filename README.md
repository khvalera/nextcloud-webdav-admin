# Nextcloud WebDAV Admin

**Nextcloud WebDAV Admin** is a portable Windows GUI utility for mounting a Nextcloud WebDAV folder as a Windows network drive.

Version: **0.1.2**

![Nextcloud WebDAV Admin](images/appearance.png)

---

## What changed in 0.1.2

Version **0.1.2** changes the mount/autostart logic from the older `WNetAddConnection2` flow to the tested Windows COM flow:

- manual mounting uses `WScript.Network.MapNetworkDrive`;
- the mount is created with `persistent=false` / `UpdateProfile=false`;
- Windows does **not** create a remembered WebDAV drive in `HKCU\Network\<drive>`;
- the Nextcloud App Password can be saved encrypted with Windows DPAPI for the current Windows user;
- autostart is installed through a hidden VBS launcher in the current user's Startup folder;
- the GUI can be started silently with `Start-NextcloudWebDAVAdmin.vbs`, without a console window;
- repeated mount fallbacks were removed to reduce the risk of Nextcloud brute-force / HTTP `429` throttling.

---

## Features

- mount Nextcloud WebDAV as a Windows drive;
- unmount the connected drive;
- open the mounted drive in Windows Explorer;
- show active Windows network connections;
- check HTTPS;
- check HTTPS without certificate revocation verification for diagnostics;
- check WebDAV with the entered App Password;
- install a local/self-signed CA certificate into Windows Trusted Root;
- run Windows WebClient/WebDAV system setup;
- save the App Password with Windows DPAPI for autostart;
- install/remove silent autostart after Windows login;
- portable mode without an installer;
- Ukrainian and English UI.

---

## Files included

| File | Purpose |
|---|---|
| `NextcloudWebDAVAdmin.ps1` | Main GUI application. |
| `Start-NextcloudWebDAVAdmin.vbs` | Silent GUI launcher without a console window. |
| `Debug-Start.cmd` | Debug launcher with console output. Use it when troubleshooting. |
| `Create-DesktopShortcut.vbs` | Creates a normal desktop shortcut that starts the GUI silently. |
| `Create-DesktopShortcut-DEBUG.vbs` | Creates a debug desktop shortcut. |
| `NextcloudWebDAVAdmin.config.json` | Portable fallback/default config template. |
| `README.md` | English documentation. |
| `README-UK.txt` | Ukrainian documentation. |
| `README-EN.txt` | Short English text documentation. |
| `VERSION` | Version file. |

---

## Where data is stored

Starting with version **0.1.1**, settings are stored in the current Windows user profile:

```text
%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.config.json
```

Version **0.1.2** also stores the App Password for autostart here:

```text
%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi
```

The password file is encrypted by Windows DPAPI. It can only be decrypted by the same Windows user in the same Windows profile.

The log file is stored here:

```text
%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.log
```

Configuration lookup order:

1. user profile config in `%APPDATA%`;
2. config next to the program as fallback/template;
3. built-in defaults.

The config next to the program is only a fallback template for first launch. All later saves go to `%APPDATA%`.

---

## Example config

```json
{
  "language": "uk",
  "host": "docs.lan",
  "userId": "user1",
  "drive": "N:",
  "davPath": "/remote.php/dav/files/user1",
  "certPath": "",
  "authForwardServer": "https://docs.lan",
  "persistent": false
}
```

`persistent` should remain `false`. The program intentionally avoids Windows remembered WebDAV mappings because they may reconnect too early after reboot and cause credential prompts or Nextcloud brute-force throttling.

---

## Recommended first run

1. Unzip the archive to a permanent folder, for example:
   ```text
   D:\Programms\NextcloudWebDAVAdmin
   ```
2. Run:
   ```text
   Start-NextcloudWebDAVAdmin.vbs
   ```
   or run `Create-DesktopShortcut.vbs` once and then start the program from the desktop shortcut.
3. Fill in:
   - host, for example `docs.lan`;
   - user ID, for example `user1`;
   - drive letter, for example `N:`;
   - WebDAV path, for example `/remote.php/dav/files/user1`;
   - Nextcloud App Password.
4. Click **System setup** once on a new Windows machine.
5. Click **Check HTTPS**.
6. Click **Check WebDAV**.
7. Click **Mount drive**.
8. If the drive mounts correctly, click **Save password**.
9. Click **Install autostart** if you want the drive mounted automatically after Windows login.

---

## Buttons

### Mount drive

Mounts the configured Nextcloud WebDAV path to the selected Windows drive letter.

Version **0.1.2** uses:

```text
WScript.Network.MapNetworkDrive
```

with:

```text
persistent=false
```

This means Windows does not create a remembered drive profile in:

```text
HKCU\Network\<drive-letter>
```

### Unmount drive

Disconnects the selected drive letter and removes stale remembered mapping data for that drive when possible.

### Open This PC / open drive

Opens the mounted drive or Windows Explorer.

### Show connections

Runs `net use` and shows active Windows network connections.

### Save password

Saves the entered Nextcloud App Password into a DPAPI-encrypted file:

```text
%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi
```

The password is **not** stored in the JSON configuration file.

### Install autostart

Installs a silent VBS launcher into the current user's Startup folder:

```text
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Nextcloud-WebDAV-N.vbs
```

The VBS launches the copied PowerShell script from:

```text
%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.ps1
```

with:

```text
-AutoMount
```

This is intentionally a user-level startup method, not a scheduled task requiring administrator rights.

### Remove autostart

Removes the Startup VBS launcher.

It does not delete the saved DPAPI password. To remove the saved password, delete:

```text
%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi
```

### System setup

Runs the Windows WebClient/WebDAV setup with administrator rights.

It configures:

```powershell
Set-Service WebClient -StartupType Automatic
Start-Service WebClient

reg add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v BasicAuthLevel /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v AuthForwardServerList /t REG_MULTI_SZ /d "https://docs.lan" /f

Restart-Service WebClient -Force
```

Run this once per Windows machine, or after WebClient/WebDAV settings were reset.

### Install certificate

Installs a local/private CA certificate into Windows Trusted Root Certification Authorities:

```cmd
certutil -addstore -f Root "certificate_file"
```

Use this when Nextcloud uses a local/private CA.

### Check HTTPS

Checks whether Windows/cURL can reach:

```text
https://<host>/status.php
```

### Check without revocation

Diagnostic check that uses `curl --ssl-no-revoke`.

Use it only to detect Windows revocation-check problems. The better fix is to publish proper CRL/AIA URLs in the server certificate instead of permanently disabling revocation checking.

### Check WebDAV

Checks WebDAV access with the entered App Password.

---

## Autostart design

The final tested autostart flow is:

```text
Windows login
    ↓
Startup folder VBS
    ↓
hidden PowerShell
    ↓
NextcloudWebDAVAdmin.ps1 -AutoMount
    ↓
read saved DPAPI App Password
    ↓
MapNetworkDrive(..., persistent=false)
```

Why this design is used:

- no console window is shown;
- no administrator rights are required;
- the App Password is not placed in the command line;
- Windows does not create a remembered WebDAV mapping;
- reconnect attempts are controlled and limited.

---

## Manual command for diagnostics

If you need to test Windows WebDAV manually, use:

```cmd
net use N: "\\docs.lan@SSL\DavWWWRoot\remote.php\dav\files\user1" /user:user1 * /persistent:no
```

or:

```cmd
net use N: "https://docs.lan/remote.php/dav/files/user1/" /user:user1 * /persistent:no
```

Enter the Nextcloud App Password when prompted.

Do **not** use `/persistent:yes` for this WebDAV drive.

---

## Nextcloud brute-force / HTTP 429

During repeated failed WebDAV mount attempts, Nextcloud may return:

```text
HTTP 429 Too Many Requests
```

In Windows this may appear as:

```text
System error 59
An unexpected network error occurred.
```

or as a generic mapping failure.

In Apache access logs it may look like:

```text
OPTIONS /remote.php/dav/files/user1 HTTP/1.1" 429 ... "Microsoft-WebDAV-MiniRedir/10.0.19045"
```

Check and reset the Nextcloud brute-force state for the client IP:

```bash
cd /usr/share/webapps/nextcloud

sudo -u nextcloud php-legacy occ security:bruteforce:attempts 192.168.28.112
sudo -u nextcloud php-legacy occ security:bruteforce:reset 192.168.28.112
```

If this is a trusted LAN workstation, you can whitelist its IP in:

```text
Administration settings -> Security -> Brute-force IP whitelist
```

Prefer whitelisting only the exact trusted workstation IP, not the whole LAN.

---

## Certificate revocation and CRYPT_E_NO_REVOCATION_CHECK

If Windows shows:

```text
CRYPT_E_NO_REVOCATION_CHECK
```

then Windows SChannel cannot verify certificate revocation status.

For local/private CA environments, the recommended server-side fix is:

- include CRL Distribution Points in the server certificate;
- include Authority Information Access / CA Issuers URL;
- publish CRL and CA issuer certificate over plain HTTP, for example:
  ```text
  http://docs.lan/ca/nextcloud-lan-ca.crl
  http://docs.lan/ca/nextcloud-lan-ca.cer
  ```

After fixing the certificate, this should work without `--ssl-no-revoke`:

```cmd
curl.exe -I https://docs.lan/status.php
```

---

## Troubleshooting

### The drive asks for credentials after reboot

Remove remembered WebDAV mapping:

```cmd
net use N: /delete /y
reg delete "HKCU\Network\N" /f
net use /persistent:no
```

Then use the program's **Install autostart** button instead of Windows persistent mapping.

### System error 59

Check the Apache/Nextcloud log. If the log shows `429`, reset Nextcloud brute-force attempts for the client IP.

### System error 1244

Windows did not receive or accept credentials. Use the GUI with **Save password** and the 0.1.2 autostart flow.

### WNetAddConnection2 code 31

Older versions used WNet mapping and could show this for TLS, WebClient, or server throttling issues. Version 0.1.2 uses `MapNetworkDrive` instead.

### The GUI starts with a console window

Use:

```text
Start-NextcloudWebDAVAdmin.vbs
```

or the normal shortcut created by:

```text
Create-DesktopShortcut.vbs
```

Use `Debug-Start.cmd` only for troubleshooting.

---

## Upgrade from 0.1.1

1. Close the old program.
2. Remove any old WebDAV remembered mapping:
   ```cmd
   net use N: /delete /y
   reg delete "HKCU\Network\N" /f
   net use /persistent:no
   ```
3. Unzip version `0.1.2` into a new folder.
4. Start the GUI with `Start-NextcloudWebDAVAdmin.vbs`.
5. Check settings and App Password.
6. Click **Mount drive**.
7. Click **Save password**.
8. Click **Install autostart**.

---

## Changes in 0.1.2

- changed manual mount to `WScript.Network.MapNetworkDrive`;
- disabled Windows remembered WebDAV mappings by using `persistent=false`;
- added DPAPI App Password storage;
- added silent autostart through Startup folder VBS;
- added silent GUI launcher `Start-NextcloudWebDAVAdmin.vbs`;
- moved autostart buttons under the mount buttons;
- added requested icons:
  - Install autostart: `C:\Windows\System32\imageres.dll,232`;
  - Remove autostart: `C:\Windows\System32\imageres.dll,229`;
- reduced mount fallbacks to avoid Nextcloud brute-force / HTTP 429;
- added log file in `%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.log`.

---

## License

MIT
