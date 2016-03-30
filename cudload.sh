#!/bin/bash
#
# Cudload - Crypted up- down- load
#
#  Yandex.Disk
#  Google Drive
#  Dropbox
#

VERSION=1.0

# Yandex access
login=srav.ja.na
password=223355668899sSs

SCRIPT_PATH=`pwd`

DROPBOX_UPLOADER_PATH="${SCRIPT_PATH}/dropbox/"
DROPBOX_API_SCRIPT="https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh"

PASSWORD_PATH="${SCRIPT_PATH}/"
BACKUP_PATH="${SCRIPT_PATH}/backup/"

DOWNLOAD_PATH="${SCRIPT_PATH}/download/"
ARCHIVE_BACKUP_PATH="${SCRIPT_PATH}/archive/"

GOOGLE_UPLOADER_PATH="${SCRIPT_PATH}/google/"
GOOGLE_API_SCRIPT="https://drive.google.com/uc?id=0B3X9GlR6EmbnSnVqdUFWSjJhbUU"


DATE=`date +%Y-%m-%d`
CURL=`which curl`
WGET=`which wget`

if [ ! -d  ${DROPBOX_UPLOADER_PATH} ]; then
 mkdir ${DROPBOX_UPLOADER_PATH}
fi;

if [ ! -d  ${GOOGLE_UPLOADER_PATH} ]; then
 mkdir ${GOOGLE_UPLOADER_PATH}
fi;

if [ ! -d  ${BACKUP_PATH} ]; then
 mkdir ${BACKUP_PATH}
fi;

if [ ! -d  ${DOWNLOAD_PATH} ]; then
 mkdir ${DOWNLOAD_PATH}
fi;

if [ ! -d  ${ARCHIVE_BACKUP_PATH} ]; then
 mkdir ${ARCHIVE_BACKUP_PATH}
fi;

if [ ! -d  ${SCRIPT_PATH} ]; then
 mkdir ${SCRIPT_PATH}
fi;

if [ ! -d ${PASSWORD_PATH} ]; then
  mkdir ${PASSWORD_PATH};
fi;

if [ ! -e ${PASSWORD_PATH}/pass.txt ]; then
  echo "super secret plain text password ${DATE}" > ${PASSWORD_PATH}/pass.txt
  chmod 600 ${PASSWORD_PATH}/pass.txt
fi;

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
     -r - Dropbox
     -y - Yandex.Disk
     -g - Google Drive
     -w - get Dropbox uloader
     -q - get google uploader
     -m - archive for last file
     -o - archive for file or folder
     -l - list of files
     -f - name of file to download
     -z - ID for file in Google Drive
     -h - Show this help

   Examples:
     Show list of files on Google Drive
       ./cudload.sh -l -g

     Encrypt and upload /home/administrator to Google Drive
       ./cudload.sh -u -g -o /home/administrator/

     Download and decrypt file from Google Drive by ID 0BzA2l61Ik_23VzZtT0NXdDJYcW8
       ./cudload.sh -d -g -f 2016-03-30 -z 0BzA2l61Ik_23VzZtT0NXdDJYcW8

     Download from Yandex.Disk
       ./cudload.sh -d -y -f 2016-03-30
"

exit 1;

}

#********************************************
# Downloading dropbox API script
#********************************************
dropbox_uploader () {

	${WGET} -P ${DROPBOX_UPLOADER_PATH} ${DROPBOX_API_SCRIPT}
	chmod 700 ${DROPBOX_UPLOADER_PATH} dropbox_uploader.sh
	echo "Downloaded Dropbox uploader";

}

#*********************************************
# Downloading Google API script
#*********************************************
google_uploader () {

	${WGET} ${GOOGLE_API_SCRIPT} -O ${GOOGLE_UPLOADER_PATH}google_uploader
	chmod 700 ${GOOGLE_UPLOADER_PATH}google_uploader

}

#********************************************
# Make archive
#********************************************
make_archive () {

  if ! [ -d "${ARCHIVE_BACKUP_PATH}" ]; then
		mkdir ${ARCHIVE_BACKUP_PATH}
	fi;

	if [ ! -e $BACKUP_PATH ];then
	  echo "File or dir does not exists";
	   exit 1;
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

  if [ ! ${DOWNLOAD_PATH}${FILENAME} ];then
	  echo -n "Path to file for decrypting:" ;
    read FILENAME
  fi;

	openssl enc -d -aes-256-cbc -in ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code -out ${DOWNLOAD_PATH}${FILENAME}.tar.gz -pass file:${PASSWORD_PATH}pass.txt

	rm ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code

	echo "Done";
	echo "Decrypted archive: ${DOWNLOAD_PATH}${FILENAME}.tar.gz ";
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

  if [ ! -e ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code ];then
    echo " !!! File does not exists: ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code";
    exit 1;
  fi;

	${CURL} --user ${login}:${password} -T ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code "https://webdav.yandex.ru"
	echo "File upload"

}

#*****************************************************
# Download from Yandex.Disk
#*****************************************************
yandex_download () {
  if [ ! ${FILE_DOWNLOAD_NAME} ];then
	  echo 'Enter file name to download from Yandex Disk:';
	  read FILENAME
	else
	  FILENAME=${FILE_DOWNLOAD_NAME};
	fi;

	FILENAME=`echo ${FILENAME} | sed 's/.tar.gz.*//'`;

	${CURL} --user ${login}:${password}  "https://webdav.yandex.ru/${FILENAME}.tar.gz.code" -o ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code
	echo "Download from Yandex Disk completed";
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
	echo "Crypted archive deleted"
}

#******************************************
#Скачиваем с Google Drive
#******************************************
google_download () {

  if [ ! -e  ${GOOGLE_UPLOADER_PATH}google_uploader ]; then
    google_uploader;
  fi;

  if [ ! ${FILE_DOWNLOAD_NAME} ];then
	  echo
	  echo ' # Enter file name to download from Google Drive';
	  read FILENAME;
	else
	  FILENAME=${FILE_DOWNLOAD_NAME};
	fi

  if [ -e ${FILENAME} ];then
    rm ${FILENAME};
  fi;

	FILENAME=`echo ${FILENAME} | sed 's/.tar.gz.*//'`;

  if [ ! ${FILE_DOWNLOAD_ID} ]; then
    ${GOOGLE_UPLOADER_PATH}google_uploader list -t ${FILENAME};

  	echo
  	echo ' # Enter ID of file to download';
    read ID;
  else
    ID=${FILE_DOWNLOAD_ID}
  fi

	#ID=`${GOOGLE_UPLOADER_PATH}google_uploader list -t $FILE | grep ${FILE} | awk '{ print $1 }'`
	FILE=${ID}

  ${GOOGLE_UPLOADER_PATH}google_uploader download  -i ${FILE}

  if [ ! -e ${FILENAME}.tar.gz.code ]; then
    echo ' !!! Error occured while downloading from Google Drive';
	  exit 1
  fi;

	cp ${FILENAME}.tar.gz.code ${DOWNLOAD_PATH}
  rm ${FILENAME}.tar.gz.code

	echo ' # Download from Google Drive has been completed';
}

#*******************************************
# List of files
#*******************************************
file_list () {

  if [ ! "${SYSTEM}" ];then

  	echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
    read SYSTEM;

  fi;

	if [ "${SYSTEM}" = r ]; then
		${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh list
	elif [ "${SYSTEM}" = g ]; then
	  ${GOOGLE_UPLOADER_PATH}google_uploader list
	else
	  echo " !!! System does not supports list";
  fi;

}

#*******************************************
# Interactive mode
#*******************************************
interactive () {

	echo -n  "Select action: u - upload / d - download / w - get dropbox uploader / q - get google uploader / l - file list : "
  read ACTION

  if [ x"${ACTION}" = x"w" -o x"${ACTION}" = x"q" ];then
    return
  fi;

	if [ x"${ACTION}" = x"l" ]; then
		echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
		read SYSTEM
	else
		echo -n "What you want to backup?  o - make archive of path / m - last file : "
		read TYPE_ARCHIVE

		echo "Path to file ";
		read BACKUP_PATH

		echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
		read SYSTEM
	fi;
}

while getopts "udirywgqm:o:l:f:z:" opt ; do
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
  f)
     FILE_DOWNLOAD_NAME=$OPTARG;
  ;;
  z)
     FILE_DOWNLOAD_ID=$OPTARG;
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

