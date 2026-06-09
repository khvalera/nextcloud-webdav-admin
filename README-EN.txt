Nextcloud WebDAV Admin Portable 0.1.0

First GitHub release.

Features:
- Mount Nextcloud WebDAV as a Windows drive.
- Uses Windows API WNetAddConnection2.
- Nextcloud App Password is not saved in config.json.
- Ukrainian and English UI.
- Portable config next to the program.
- Windows WebClient/WebDAV system setup.
- Select and install local/self-signed certificate.
- HTTPS, HTTPS no-revoke, and WebDAV checks.

Usage:
1. Unzip the archive to a permanent folder.
2. Run Create-DesktopShortcut.vbs.
3. Start the Nextcloud WebDAV Admin shortcut.
4. Configure host, user, drive, and path.
5. Enter App Password.
6. Click Mount drive.

Certificate:
- Select .cer / .crt / .pem.
- Click Install certificate.
- Confirm administrator prompt.

Install command:
certutil -addstore -f Root "certificate_file"
