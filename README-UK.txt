Nextcloud WebDAV Admin Portable 0.1.0

Перший GitHub-реліз.

Можливості:
- Підключення Nextcloud WebDAV як диск Windows.
- Підключення через Windows API WNetAddConnection2.
- Пароль застосунку Nextcloud не зберігається в config.json.
- Інтерфейс українською та англійською.
- Portable-конфіг поруч із програмою.
- Системні налаштування Windows WebClient/WebDAV.
- Вибір і встановлення локального/самописного сертифіката.
- Перевірка HTTPS, HTTPS без відкликання та WebDAV.

Використання:
1. Розпакуй архів у постійну папку.
2. Запусти Create-DesktopShortcut.vbs.
3. Запусти ярлик Nextcloud WebDAV Admin.
4. Налаштуй сервер, користувача, диск і шлях.
5. Введи App Password.
6. Натисни "Підключити диск".

Сертифікат:
- Обери .cer / .crt / .pem.
- Натисни "Встановити сертифікат".
- Підтвердь запуск від адміністратора.

Команда встановлення:
certutil -addstore -f Root "файл_сертифіката"
