#!/bin/bash

DIR=$(cd `dirname $0` && pwd)
DIR_VUE="${DIR}/modules/AdminPanelWebclient/vue"
TASK="build"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -t|--task)
    TASK="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo TASK: "$TASK"

if [ "$TASK" = "npm" ]; then
	cd ${DIR}
	
	npm install -g gulp-cli
	npm install

	if [ -d "$DIR_VUE" ]; then
		cd ${DIR_VUE}
		npm install
		npm install -g @quasar/cli
	fi
fi

if [ "$TASK" = "build" ]; then
	#cd ${DIR}
	gulp styles --themes Default,DeepForest,Funny,Sand --build a
	gulp js:build --build a
	gulp js:min --build a
	#gulp test

	if [ -d "$DIR_VUE" ]; then
		cd ${DIR_VUE}
		npm run build-production
	fi
fi

if [ "$TASK" = "pack" ]; then

	echo 'deny from all' > data/.htaccess
	
	PRODUCT_VERSION=`cat VERSION`
	
	echo CREATE ZIP FILE: "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	zip -rq ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip data/settings/config.json data/settings/modules data/.htaccess modules static system vendor dev adminpanel ".htaccess" dav.php index.php LICENSE VERSION README.md CHANGELOG.txt favicon.ico robots.txt package.json composer.json composer.lock gulpfile.js pre-config.json -x **/*.bak *.git* *node_modules/\*
fi

if [ "$TASK" = "upload" ]; then
	cd ${DIR}
	
	PRODUCT_VERSION=`cat VERSION`
	
	echo UPLOAD ZIP FILE: "${PRODUCT_NAME}_${PRODUCT_VERSION}.zip"
	
	curl -v --ftp-create-dirs --retry 6 -T ${PRODUCT_NAME}_${PRODUCT_VERSION}.zip -u ${FTP_USER}:${FTP_PASSWORD} ftp://afterlogic.com/
fi
