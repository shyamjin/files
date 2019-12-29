
echo ""
echo " Running at location : $PWD"
BUILD_FILE_NAME="build.zip"
chmod 777 build.sh
./build.sh ${BUILD_FILE_NAME}
echo exit code $?

echo "Zip is finished - `pwd`/${BUILD_FILE_NAME}"

if [ ! -f  ${BUILD_FILE_NAME} ]; then
      echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	    echo " ${BUILD_FILE_NAME} not found at $PWD!. Exiting"
      echo " Please ensure that ${BUILD_FILE_NAME} was created and retry !!"
      echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
      exit 1
else
    echo " ${BUILD_FILE_NAME} found at $PWD!"
fi


