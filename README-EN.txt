Nextcloud WebDAV Admin 0.1.1

Changes in 0.1.1:
- Settings are now stored in the current Windows user profile:
  %APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.config.json
- Config lookup order:
  1. user profile config;
  2. config next to the program as fallback/template;
  3. built-in defaults.
- Config saves always go to the user profile.
- Manual WebDAV mount logic was not changed from 0.1.0.

The Nextcloud App Password is not stored in config.json.
