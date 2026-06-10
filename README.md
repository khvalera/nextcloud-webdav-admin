# Nextcloud WebDAV Admin

**Version:** 0.1.1

Portable Windows GUI utility for mounting Nextcloud WebDAV as a Windows drive.

## Changes in 0.1.1

- Settings are now stored in the current Windows user profile:
  `%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.config.json`
- Config lookup order:
  1. user profile config;
  2. config next to the program as fallback/template;
  3. built-in defaults.
- All config saves go to the user profile.
- Manual WebDAV mount logic is unchanged from 0.1.0.

## Note

The config next to the program remains only as a fallback/default template.
The Nextcloud App Password is not stored in `config.json`.
