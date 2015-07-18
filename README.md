# Cudload
Console utills for download and upload backup to remote servers

VERSION=1.0

login=                                      - логин к яндекс диску
password=                                   - пароль к яндекс диску
DROPBOX_UPLOADER_PATH=/usr/local/cudload/   - путь к скрипту дробокса
PASSWORD_PATH=/usr/local/cudload/           - путь к файлу с паролем для шифрования архива
DOWNLOAD_PATH=/var/download/                - путь к папке куда скачивает бекапы с удаленных серверов
ARCHIVE_BACKUP_PATH=/var/cudload/           - путь к архиву бекапа
GOOGLE_UPLOADER_PATH=/usr/local/cudload/    - путь к скрипту гугл диска
SCRIPT_PATH=/usr/local/cudload/             - путь к нашему скрипту
DATE=`date +%Y-%m-%d`
CURL=`which curl`
WGET=`which wget`

Работа с скриптом:
     -u - upload mode
     -d - download mode
     -i - interactive mode
     -r - dropbox
     -y - yandex
     -g - google
     -w - get dropbox uloader
     -q - get google uploader
     -m - archive for last file
     -o - archive for file or folder
     -l - list of files
