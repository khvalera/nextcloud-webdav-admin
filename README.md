# Nextcloud WebDAV Admin Portable

**Version:** 0.1.0

Portable Windows GUI utility for configuring and mounting a Nextcloud WebDAV drive.

## Features

- Mount Nextcloud WebDAV as a Windows drive letter.
- Uses Windows API `WNetAddConnection2` for drive mapping.
- Does not store the Nextcloud App Password in the config.
- Supports Ukrainian and English UI.
- Stores portable configuration in `NextcloudWebDAVAdmin.config.json`.
- Can run system setup tasks for Windows WebClient/WebDAV support.
- Can select and install a local/self-signed CA certificate into the Windows Root store.
- Includes HTTPS, HTTPS no-revoke, and WebDAV checks.

## Default configuration

```json
{
  "language": "uk",
  "host": "docs.lan",
  "userId": "user1",
  "drive": "N:",
  "davPath": "/remote.php/dav/files/user1",
  "certPath": "",
  "authForwardServer": "https://docs.lan",
  "persistent": true
}
```

## Usage

1. Unzip the archive to a permanent folder.
2. Run `Create-DesktopShortcut.vbs`.
3. Start **Nextcloud WebDAV Admin** from the desktop shortcut.
4. Edit host/user/drive/path as needed.
5. Enter the Nextcloud **App Password**.
6. Click **Підключити диск** / **Mount drive**.

## Certificate installation

For local or self-signed certificates:

1. Select the certificate file: `.cer`, `.crt`, or `.pem`.
2. Click **Встановити сертифікат** / **Install certificate**.
3. Approve the administrator prompt.

The tool runs:

```cmd
certutil -addstore -f Root "certificate_file"
```

## Notes

- The App Password is not saved in the config file.
- The WebDAV drive mapping requires Windows WebClient service.
- For local certificates, the regular HTTPS check may fail with `CRYPT_E_NO_REVOCATION_CHECK`; use the no-revoke check when appropriate.
