# Cudload
Console utills for download and upload backup to remote servers

###VERSION
1.0
----------
###Variables
* *login*                   - login for Yandex Disk

* *password*                - password for Yandex Disk

* *DROPBOX_UPLOADER_PATH*   - path to dropbox uploader

* *PASSWORD_PATH*           - path to password file

* *DOWNLOAD_PATH*           - path to download directory

* *ARCHIVE_BACKUP_PATH*     - path to archived backup

* *GOOGLE_UPLOADER_PATH*    - path to google uploader

* *SCRIPT_PATH*             - path to cudload.sh


<br>
----------

###Cudload.sh - simple backup operations<br>
<b>Usage:</b>

  ```
  ./cudload.sh [-i] [-ud] [-ryg] [-l] [-o FILE|DIR] [ -f FILENAME [-z FILEID] ]
  -i - interactive mode
  -u - upload mode
  -d - download mode
  -r - Dropbox
  -y - Yandex.Disk
  -g - Google Drive
  -w - get Dropbox uloader
  -q - get google uploader
  -m - archive for last file
  -o - archive for file or folder
  -l - list of files
  -f - name of file to download
  -z - ID for file in Google Drive\n
  ```
<br>
----------

<b>Examples:</b><br>
     
* Show list of files on Google Drive<br>
  ```./cudload.sh -l -g```
       
* Encrypt and upload /home/administrator to Google Drive<br>
  <code>./cudload.sh -u -g -o /home/administrator/</code>
     
* Download and decrypt file from Google Drive by ID 0BzA2l61Ik_23VzZtT0NXdDJYcW8<br>
  <code>./cudload.sh -d -g -f 2016-03-30 -z 0BzA2l61Ik_23VzZtT0NXdDJYcW8</code>
       
* Download from Yandex.Disk<br>
  <code>./cudload.sh -d -y -f 2016-03-30</code>
