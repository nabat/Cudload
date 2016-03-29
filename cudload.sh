#!/bin/bash
VERSION=1.0

login=kikoandrew														#login yandex
password=kiko335														#password yandex
DROPBOX_UPLOADER_PATH=/usr/local/Cudload/
PASSWORD_PATH=/usr/local/Cudload/
BACKUP_PATH=/usr/local/Cudload/
DOWNLOAD_PATH=/var/download/
ARCHIVE_BACKUP_PATH=/var/Cudload/
GOOGLE_UPLOADER_PATH=/usr/local/Cudload/
SCRIPT_PATH=/usr/local/Cudload/
DATE=`date +%Y-%m-%d`
CURL=`which curl`
WGET=`which wget`

#********************************************
#HELP
#*******************************************
print_help () {

echo "

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
"

}

#********************************************
#Скачиваем Dropbox uploader
#********************************************
dropbox_uploader () {

	${WGET} -P ${DROPBOX_UPLOADER_PATH}  https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh
	chmod 777 ${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh
	echo "Uploader download"

}

#*********************************************
#Скачиваем Google uploader
#*********************************************
google_uploader () {

	${WGET}  https://drive.google.com/uc?id=0B3X9GlR6EmbnSnVqdUFWSjJhbUU -O ${GOOGLE_UPLOADER_PATH}google_uploader
	chmod 777 ${GOOGLE_UPLOADER_PATH}google_uploader

}

#********************************************
#Делает архив
#********************************************
make_archive () {

  if ! [ -d /var/cudload/ ]; then
		mkdir /var/cudload/
	fi;

  if [ "${TYPE_ARCHIVE}"  = "m" ]; then
    cd $BACKUP_PATH
    echo "$BACKUP_PATH"
    FILE=`ls -t | head -1`
  	tar -cvf ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz $FILE
  	openssl enc -e -aes-256-cbc -in ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz -out ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code -pass file:${PASSWORD_PATH}pass.txt
  	echo "Code done"
  	fi;
  if [ "${TYPE_ARCHIVE}" = "o" ]; then
  	tar -cvf ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz $BACKUP_PATH
		openssl enc -e -aes-256-cbc -in ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz -out ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code -pass file:${PASSWORD_PATH}pass.txt
		echo "Code done"
  fi;

}

#********************************************
#Расшифровывает архив и удаляет зашифрованый
#********************************************
destroy_archive () {
	echo "Enter file name for encoding:";
	read FILENAME;
	openssl enc -d -aes-256-cbc -in ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code -out ${DOWNLOAD_PATH}${FILENAME}.tar.gz -pass file:${PASSWORD_PATH}pass.txt
	rm ${DOWNLOAD_PATH}${FILENAME}.tar.gz.code
	echo "Done"

}

#********************************************
#Загрузка бекапов на Dropbox
#********************************************
dropbox_upload () {
	
	if [ ! -f /usr/local/cudload/dropbox_uploader.sh ]; then		
		if [ ! -f /usr/bin/wget ]; then
			apt-get --reinstall install wget
		fi;										# Проверка на наличие dropbox_uploadera										
 	 dropbox_uploader
	fi;
	${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh upload ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code .
	echo "File upload"
	rm ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code
	echo "Coded archive deleted"

}

#*******************************************
#Скачивание бекапов с Dropbox
#*******************************************
dropbox_download () {

	${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh download ${DATE}.tar.gz.code ${DOWNLOAD_PATH}
	echo "File download"

}

#****************************************************
#Загружаем на яндекс диск
#****************************************************
yandex_upload () {

	${CURL} --user ${login}:${password} -T ${ARCHIVE_BACKUP_PATH}${DATE}.tar.gz.code "https://webdav.yandex.ru"
	echo "File upload"
	
}

#*****************************************************
#Скачиваем с яндекса диска
#*****************************************************
yandex_download () {
	echo 'Enter file name for upload:';
	read FILE
	
	${CURL} --user ${login}:${password}  "https://webdav.yandex.ru/${FILE}.tar.gz.code" -o ${DOWNLOAD_PATH}${FILE}.tar.gz.code
	echo "File download"

}

#*****************************************
#Закачиваем на Google Drive
#*****************************************
google_upload () {

	if [ ! -f /usr/local/cudload/google_uploader ]; then
		if [ ! -f /usr/bin/wget ]; then
			apt-get --reinstall install wget
		fi;																												# проверка на наличие google_uploadera
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
	echo 'Enter file name';
	read FILENAME;
	${GOOGLE_UPLOADER_PATH}google_uploader list -t $FILENAME;
	
	echo 'Enter file ID';
	read ID;

	#ID=`${GOOGLE_UPLOADER_PATH}google_uploader list -t $FILE | grep ${FILE} | awk '{ print $1 }'`
	FILE=${ID}

	${GOOGLE_UPLOADER_PATH}google_uploader download  -i $FILE
	cp ${SCRIPT_PATH}$FILENAME.tar.gz.code ${DOWNLOAD_PATH}
	rm ${SCRIPT_PATH}$FILENAME.tar.gz.code

}

#*******************************************
#Список файлов
#*******************************************
file_list () {

	echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
	read SYSTEM
	if [ "${SYSTEM}" = r ]; then
		${DROPBOX_UPLOADER_PATH}dropbox_uploader.sh list
	fi;
	if [ "${SYSTEM}" = g ]; then
	${GOOGLE_UPLOADER_PATH}google_uploader list
	fi;

}
#*******************************************
#Интерактивный мод
#*******************************************
interactive () {

	echo -n "Select action: u - upload / d - download / w - get dropbox uploader / q - get google uploader / l - file list : "
	read ACTION
	if [ ${ACTION} = l ]; then
		echo -n "Select system for $ACTION file: r - dropbox, y - yandex, g - google : "
		read SYSTEM
	else
		echo -n "Select what to archive - o - make archive of path / m - last file : "
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

