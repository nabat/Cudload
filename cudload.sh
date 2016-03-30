#!/bin/bash
VERSION=1.0

login=test	  #login yandex
password=test	#password yandex

DROPBOX_UPLOADER_PATH="/usr/local/Cudload/"
DROPBOX_API_SCRIPT="https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh"

PASSWORD_PATH="/usr/local/Cudload/"
BACKUP_PATH="/usr/local/Cudload/"

DOWNLOAD_PATH="/var/download/"
ARCHIVE_BACKUP_PATH="/var/Cudload/"

GOOGLE_UPLOADER_PATH="/usr/local/Cudload/"
GOOGLE_API_SCRIPT="https://drive.google.com/uc?id=0B3X9GlR6EmbnSnVqdUFWSjJhbUU"
SCRIPT_PATH="/usr/local/Cudload/"

DATE=`date +%Y-%m-%d`
CURL=`which curl`
WGET=`which wget`

#********************************************
#  Usage
#*******************************************
print_help () {

echo "
  Cudload.sh - simple backup operations

   Usage: ./cudload.sh [-i] [-ud] [-ryg] [-l] [-o FILE|DIR]

     -i - interactive mode
     -u - upload mode
     -d - download mode
     -r - dropbox
     -y - yandex
     -g - google
     -w - get dropbox uloader
     -q - get google uploader
     -m - archive for last file
     -o - archive for file or folder
     -l - list of files
     -h - Show this help
"

exit 1;

}

#********************************************
# Downloading dropbox API script
#********************************************
dropbox_uploader () {

	${WGET} -P ${DROPBOX_UPLOADER_PATH} ${DROPBOX_API_SCRIPT}
	chmod +x ${DROPBOX_UPLOADER_PATH} dropbox_uploader.sh
	echo "Downloaded Dropbox uploader";

}

#*********************************************
# Downloading Google API script
#*********************************************
google_uploader () {

	${WGET} ${GOOGLE_API_SCRIPT} -O ${GOOGLE_UPLOADER_PATH}google_uploader
	chmod +x ${GOOGLE_UPLOADER_PATH}google_uploader

}

#********************************************
# Make archive
#********************************************
make_archive () {

  if ! [ -d "/var/Сudload/" ]; then
		mkdir "/var/Сudload/"
	fi;

  if [ "${TYPE_ARCHIVE}"  = "m" ]; then
    cd $BACKUP_PATH
    echo "$BACKUP_PATH"
    FILE=`ls -t | head -1`
  	tar -cvf ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz $FILE
  	openssl enc -e -aes-256-cbc -in ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz -out ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code -pass file:${PASSWORD_PATH}pass.txt
  	echo "Encrypting operations:  done"
  	fi;
  if [ "${TYPE_ARCHIVE}" = "o" ]; then
  	tar -cvf ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz $BACKUP_PATH
		openssl enc -e -aes-256-cbc -in ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz -out ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code -pass file:${PASSWORD_PATH}pass.txt
		echo "Encrypting operations:  done"
  fi;

}

#********************************************
# Decrypt and remove crypted archive
#********************************************
destroy_archive () {
	echo -p "Path to file for decrypting:" FILENAME;

	openssl enc -d -aes-256-cbc -in ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code -out ${DOWNLOAD_PATH}${FILENAME}.tar.gz -pass file:${PASSWORD_PATH}pass.txt

	rm ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code

	echo "Done";
}

#********************************************
# Upload backup to Dropbox
#********************************************
dropbox_upload () {

	if [ ! -e ${WGET} ]; then
	  echo "Wrong path to Wget : '${WGET}'. Exit";
	  exit 1;
	fi;

	if [ ! -f "${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh" ]; then
 	 dropbox_uploader
	fi;

	${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh upload ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code .

	echo "File upload"
	rm ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code
	echo "Coded archive deleted"

}

#*******************************************
# Download from Dropbox
#*******************************************
dropbox_download () {
	echo 'Enter file name for download from Dropbox:';
	read FILE
	${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh download ${FILE}.tar.gz.code ${DOWNLOAD_PATH}
	echo "File download"

}

#****************************************************
# Upload to Yandex.Disk
#****************************************************
yandex_upload () {

	${CURL} --user ${login}:${password} -T ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code "https://webdav.yandex.ru"
	echo "File upload"
	
}

#*****************************************************
# Download from Yandex.Disk
#*****************************************************
yandex_download () {
	echo 'Enter file name to download from Yandex Disk:';
	read FILE
	
	${CURL} --user ${login}:${password}  "https://webdav.yandex.ru/${FILE}.tar.gz.code" -o ${DOWNLOAD_PATH}${FILE}.tar.gz.code
	echo "Download from Yandex Disk completed"

}

#*****************************************
# Upload to Google Drive
#*****************************************
google_upload () {

	if [ ! -e ${WGET} ]; then
	  echo "Wrong path to Wget : '${WGET}'. Exit";
	  exit 1;
	fi;


	if [ ! -f ${GOOGLE_UPLOADER_PATH}google_uploader ]; then
		google_uploader
	fi;


	${GOOGLE_UPLOADER_PATH}google_uploader upload -f ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code
	echo "File upload"
	rm ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code
	echo "Coded archive deleted"


}

#******************************************
#Скачиваем с Google Drive
#******************************************
google_download () {
	echo 'Enter file name to download from Google Drive';
	read FILENAME;
	${GOOGLE_UPLOADER_PATH}google_uploader list -t $FILENAME;

	# TODO : Grep ID

	echo -p 'Enter file ID to download' ID;

	#ID=`${GOOGLE_UPLOADER_PATH}google_uploader list -t $FILE | grep ${FILE} | awk '{ print $1 }'`
	FILE=${ID}

	${GOOGLE_UPLOADER_PATH}google_uploader download  -i $FILE
	cp ${SCRIPT_PATH}$FILENAME.tar.gz.code ${DOWNLOAD_PATH}
	rm ${SCRIPT_PATH}$FILENAME.tar.gz.code

	echo 'Download from Google Drive has been completed';
}

#*******************************************
# List of files
#*******************************************
file_list () {

	echo -np "Select system for $ACTION file: r - dropbox, y - yandex, g - google : " SYSTEM

	if [ "${SYSTEM}" = r ]; then
		${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh list
	fi;

	if [ "${SYSTEM}" = g ]; then
	  ${GOOGLE_UPLOADER_PATH}google_uploader list
	fi;

}

#*******************************************
# Interactive mode
#*******************************************
interactive () {

	echo -np "Select action: u - upload / d - download / w - get dropbox uploader / q - get google uploader / l - file list : " ACTION

	if [ ${ACTION} = l ]; then
		echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
		read SYSTEM
	else
		echo -n "What you want to backup?  o - make archive of path / m - last file : "
		read TYPE_ARCHIVE
		read BACKUP_PATH
		echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
		read SYSTEM
	fi;
}

while getopts "udirywgqm:o:l" opt ; do
  case "$opt" in

  w)
     ACTION=w;																							# Скачать dropbox uploader
  ;;
  q)
     ACTION=q;																							# Скачать google uploader
  ;;
  u)
     ACTION=u;																							# Upload
  ;;
  d)
     ACTION=d;																							# Download
  ;;
  r)
     SYSTEM=r;																							# Dropbox
  ;;
  y)
     SYSTEM=y;																							# Yandex
  ;;
  g)
     SYSTEM=g;																							# Google
  ;;

  i) 
     interactive=i;																					# Интерактивный режим
  ;;
  m)
     BACKUP_PATH=$OPTARG;
     TYPE_ARCHIVE=m;																				# Архив последнего файла
  ;;
  o)
     BACKUP_PATH=$OPTARG;
     TYPE_ARCHIVE=o;																				# Архив файла по имени
  ;;
  l)
  		ACTION=l;
  ;;
esac
done

if [ "${interactive}" = i ]; then
  interactive;
fi;

if [ "${ACTION}" = l ]; then
	file_list
else
if [ "${ACTION}" = u ]; then
  make_archive

  if [ "${SYSTEM}" = r ]; then
    dropbox_upload
  fi;

  if [ "${SYSTEM}" = y ]; then
    yandex_upload
  fi;

  if [ "${SYSTEM}" = g ]; then
    google_upload
  fi;

elif [ "${ACTION}" = d ]; then

  if [ "${SYSTEM}" = r ]; then
    dropbox_download
    destroy_archive
  fi
  if [ "${SYSTEM}" = y ]; then
    yandex_download
    destroy_archive
  fi
  if [ "${SYSTEM}" = g ]; then
    google_download
    destroy_archive
  fi

elif [ "${ACTION}" = w ]; then
    dropbox_uploader
elif [ "${ACTION}" = q ]; then
    google_uploader
else
  print_help
fi
fi;

exit 0

