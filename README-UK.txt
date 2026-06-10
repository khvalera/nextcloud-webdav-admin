Nextcloud WebDAV Admin
======================

Nextcloud WebDAV Admin — portable Windows GUI-утиліта для підключення Nextcloud WebDAV як мережевого диска Windows.

Версія: 0.1.2

Скріншот:
images\appearance.png


Що змінилось у 0.1.2
====================

У версії 0.1.2 змінено логіку підключення та автозапуску:

- ручне підключення диска виконується через WScript.Network.MapNetworkDrive;
- використовується persistent=false / UpdateProfile=false;
- Windows не створює remembered WebDAV-диск у HKCU\Network\<літера>;
- App Password Nextcloud можна зберегти через Windows DPAPI для поточного користувача Windows;
- автопідключення встановлюється через прихований VBS у Startup-папці користувача;
- GUI можна запускати без чорного вікна через Start-NextcloudWebDAVAdmin.vbs;
- прибрано багаторазові fallback-спроби монтування, щоб не набивати Nextcloud brute-force / HTTP 429.


Можливості
==========

- підключення Nextcloud WebDAV як диск Windows;
- відключення підключеного диска;
- відкриття диска у Провіднику Windows;
- перегляд активних мережевих підключень;
- перевірка HTTPS;
- перевірка HTTPS без перевірки відкликання сертифіката для діагностики;
- перевірка WebDAV з App Password;
- встановлення локального / самописного CA-сертифіката;
- системне налаштування Windows WebClient/WebDAV;
- збереження App Password через DPAPI для автозапуску;
- встановлення та видалення тихого автопідключення після входу в Windows;
- portable-режим без інсталятора;
- український та англійський інтерфейс.


Файли в архіві
==============

NextcloudWebDAVAdmin.ps1
    Основна GUI-програма.

Start-NextcloudWebDAVAdmin.vbs
    Тихий запуск GUI без консольного вікна.

Debug-Start.cmd
    Debug-запуск із консоллю. Використовувати для діагностики.

Create-DesktopShortcut.vbs
    Створює звичайний ярлик на робочому столі. Ярлик запускає GUI тихо.

Create-DesktopShortcut-DEBUG.vbs
    Створює debug-ярлик на робочому столі.

NextcloudWebDAVAdmin.config.json
    Portable fallback/default шаблон конфігурації.

README.md
    Англомовна документація.

README-UK.txt
    Українська документація.

README-EN.txt
    Коротка англомовна текстова документація.

VERSION
    Файл версії.


Де зберігаються дані
====================

Починаючи з версії 0.1.1, конфігурація зберігається у профілі поточного користувача Windows:

%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.config.json

У версії 0.1.2 App Password для автозапуску зберігається тут:

%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi

Цей файл зашифрований через Windows DPAPI. Його може розшифрувати тільки той самий Windows-користувач у тому самому профілі.

Журнал програми:

%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.log

Порядок пошуку конфігурації:

1. конфіг у %APPDATA%;
2. конфіг поруч із програмою як fallback/шаблон;
3. стандартні значення програми.

Файл конфігурації поруч із програмою використовується тільки як шаблон першого запуску. Усі подальші збереження йдуть у %APPDATA%.


Приклад конфігурації
====================

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

Для WebDAV-диска краще залишати:

"persistent": false

Програма спеціально не створює Windows remembered WebDAV mapping, бо після перезавантаження Windows може пробувати відновити диск занадто рано, показувати вікно логіна або набивати Nextcloud brute-force / HTTP 429.


Рекомендований перший запуск
============================

1. Розпакуй архів у постійну папку, наприклад:

   D:\Programms\NextcloudWebDAVAdmin

2. Запусти:

   Start-NextcloudWebDAVAdmin.vbs

   або один раз запусти Create-DesktopShortcut.vbs і далі користуйся ярликом на робочому столі.

3. Заповни поля:

   - сервер, наприклад docs.lan;
   - користувач, наприклад user1;
   - літера диска, наприклад N:;
   - WebDAV-шлях, наприклад /remote.php/dav/files/user1;
   - App Password Nextcloud.

4. На новому комп'ютері один раз натисни «Системні налаштування».

5. Натисни «Перевірка HTTPS».

6. Натисни «Перевірка WebDAV».

7. Натисни «Підключити диск».

8. Якщо диск підключився — натисни «Зберегти пароль».

9. Якщо треба автопідключення після входу у Windows — натисни «Автопідключення».


Кнопки програми
===============

Підключити диск
---------------

Підключає вказаний WebDAV-шлях Nextcloud до вибраної літери диска.

У версії 0.1.2 використовується:

WScript.Network.MapNetworkDrive

з параметром:

persistent=false

Тому Windows не створює remembered-профіль диска:

HKCU\Network\<літера>


Відключити диск
---------------

Відключає вибрану літеру диска та прибирає застарілий remembered mapping для цієї літери, якщо він є.


Відкрити комп'ютер / відкрити диск
----------------------------------

Відкриває Провідник Windows або підключений диск.


Показати підключення
--------------------

Виконує net use і показує активні мережеві підключення Windows.


Зберегти пароль
---------------

Зберігає введений App Password Nextcloud у DPAPI-файл:

%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi

Пароль не записується у JSON-конфіг.


Автопідключення
---------------

Встановлює тихий VBS-запуск у Startup-папку поточного користувача:

%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Nextcloud-WebDAV-N.vbs

Також копіює робочий PowerShell-скрипт у:

%APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.ps1

VBS запускає PowerShell приховано з параметром:

-AutoMount

Це користувацький автозапуск. Він не потребує прав адміністратора.


Прибрати автозапуск
-------------------

Видаляє VBS-файл зі Startup-папки.

Збережений DPAPI-пароль не видаляється. Щоб видалити пароль, видали файл:

%APPDATA%\NextcloudWebDAVAdmin\nextcloud-webdav-app-password.dpapi


Системні налаштування
---------------------

Разово налаштовує Windows WebClient/WebDAV з правами адміністратора.

Виконується приблизно таке:

Set-Service WebClient -StartupType Automatic
Start-Service WebClient

reg add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v BasicAuthLevel /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters" /v AuthForwardServerList /t REG_MULTI_SZ /d "https://docs.lan" /f

Restart-Service WebClient -Force

Цю кнопку достатньо натиснути один раз на комп'ютері або після скидання WebClient/WebDAV налаштувань Windows.


Встановити сертифікат
---------------------

Встановлює локальний або самописний CA-сертифікат у Windows Trusted Root Certification Authorities.

Команда:

certutil -addstore -f Root "certificate_file"

Використовуй це, якщо Nextcloud працює через локальний/private CA.


Перевірка HTTPS
---------------

Перевіряє доступність:

https://<server>/status.php


Перевірка без відкликання
-------------------------

Діагностична перевірка через:

curl --ssl-no-revoke

Вона потрібна тільки щоб зрозуміти, чи проблема у Windows-перевірці відкликання сертифіката. Постійно вимикати перевірку відкликання не бажано. Краще виправити сертифікат на сервері: CRL Distribution Points і Authority Information Access.


Перевірка WebDAV
----------------

Перевіряє WebDAV-доступ з введеним App Password.


Як працює автозапуск
====================

Фінальна робоча схема:

Windows login
    ↓
Startup-папка користувача
    ↓
Nextcloud-WebDAV-N.vbs
    ↓
прихований PowerShell
    ↓
NextcloudWebDAVAdmin.ps1 -AutoMount
    ↓
читання App Password з DPAPI
    ↓
MapNetworkDrive(..., persistent=false)

Чому саме так:

- не відкривається чорне вікно консолі;
- не потрібні права адміністратора;
- App Password не потрапляє в командний рядок;
- Windows не створює remembered WebDAV-диск;
- спроби підключення контрольовані й не множаться.


Ручні команди для діагностики
=============================

Перевірити Windows WebDAV вручну можна так:

net use N: "\\docs.lan@SSL\DavWWWRoot\remote.php\dav\files\user1" /user:user1 * /persistent:no

або так:

net use N: "https://docs.lan/remote.php/dav/files/user1/" /user:user1 * /persistent:no

Після запиту введи App Password Nextcloud.

Не використовуй для цього диска:

/persistent:yes


Nextcloud brute-force / HTTP 429
================================

Після багатьох невдалих WebDAV-спроб Nextcloud може повернути:

HTTP 429 Too Many Requests

У Windows це може виглядати як:

System error 59
An unexpected network error occurred.

або як загальна помилка монтування.

У Apache access log це може виглядати так:

OPTIONS /remote.php/dav/files/user1 HTTP/1.1" 429 ... "Microsoft-WebDAV-MiniRedir/10.0.19045"

Перевірити й скинути brute-force стан для IP клієнта:

cd /usr/share/webapps/nextcloud

sudo -u nextcloud php-legacy occ security:bruteforce:attempts 192.168.28.112
sudo -u nextcloud php-legacy occ security:bruteforce:reset 192.168.28.112

Якщо це довірена LAN-станція, можна додати її IP у whitelist:

Administration settings -> Security -> Brute-force IP whitelist

Краще додавати тільки конкретний IP робочої станції, а не всю мережу.


Сертифікат, CRL/AIA і CRYPT_E_NO_REVOCATION_CHECK
=================================================

Якщо Windows показує:

CRYPT_E_NO_REVOCATION_CHECK

це означає, що Windows SChannel не може перевірити відкликання сертифіката.

Для локального/private CA правильний серверний fix:

- додати CRL Distribution Points у серверний сертифікат;
- додати Authority Information Access / CA Issuers URL;
- опублікувати CRL і CA issuer certificate по HTTP, наприклад:

http://docs.lan/ca/nextcloud-lan-ca.crl
http://docs.lan/ca/nextcloud-lan-ca.cer

Після виправлення сертифіката команда має працювати без --ssl-no-revoke:

curl.exe -I https://docs.lan/status.php


Типові проблеми
===============

Після перезавантаження з'являється вікно логіна до docs.lan
------------------------------------------------------------

Причина: Windows remembered WebDAV mapping.

Очистити:

net use N: /delete /y
reg delete "HKCU\Network\N" /f
net use /persistent:no

Після цього використовуй кнопку «Автопідключення», а не Windows persistent mapping.


System error 59
---------------

Перевір Apache/Nextcloud log. Якщо там HTTP 429 — скинь brute-force для IP клієнта.


System error 1244
-----------------

Windows не отримав або не прийняв облікові дані. У версії 0.1.2 використовуй «Зберегти пароль» і «Автопідключення».


WNetAddConnection2 code 31
--------------------------

Старі версії могли показувати цю помилку при TLS/WebClient/серверному throttling. Версія 0.1.2 використовує MapNetworkDrive.


GUI відкривається з чорним вікном
---------------------------------

Запускай:

Start-NextcloudWebDAVAdmin.vbs

або звичайний ярлик, створений через:

Create-DesktopShortcut.vbs

Debug-Start.cmd використовуй тільки для діагностики.


Оновлення з 0.1.1
=================

1. Закрий стару програму.

2. Прибери старий WebDAV remembered mapping, якщо він є:

net use N: /delete /y
reg delete "HKCU\Network\N" /f
net use /persistent:no

3. Розпакуй 0.1.2 у нову папку.

4. Запусти GUI через:

Start-NextcloudWebDAVAdmin.vbs

5. Перевір налаштування і App Password.

6. Натисни «Підключити диск».

7. Натисни «Зберегти пароль».

8. Натисни «Автопідключення».


Зміни у 0.1.2
=============

- ручне монтування змінено на WScript.Network.MapNetworkDrive;
- вимкнено Windows remembered WebDAV mappings через persistent=false;
- додано DPAPI-збереження App Password;
- додано тихий автозапуск через Startup VBS;
- додано тихий запуск GUI через Start-NextcloudWebDAVAdmin.vbs;
- кнопки автозапуску перенесено під кнопки підключення диска;
- додано іконки:
  - Автопідключення: C:\Windows\System32\imageres.dll,232
  - Прибрати автозапуск: C:\Windows\System32\imageres.dll,229
- зменшено кількість fallback-спроб, щоб не провокувати Nextcloud brute-force / HTTP 429;
- додано лог:
  %APPDATA%\NextcloudWebDAVAdmin\NextcloudWebDAVAdmin.log


License
=======

MIT
