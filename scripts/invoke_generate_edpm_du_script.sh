FILE="./dpm/scripts/generate_edpm_du.sh" 
GLOBALFILE="$DPM_SCRIPTS_PATH/generate_edpm_du.sh" 
FILETOEXECUTE=""
   
if [ ! -f $FILE ]; then
            echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
	    echo "$FILE not found!. Checking for script in global path"
            echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"

		if [ ! -f $GLOBALFILE]; then
                    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		    echo "$GLOBALFILE not found!. Exiting!!"
                    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		    exit 1
		else
		    echo "GlobalScript : $GLOBALFILE was found"
		    FILETOEXECUTE=$GLOBALFILE
		fi

else
	    echo "Local Script : $FILE was found"
	    FILETOEXECUTE=$FILE
fi

echo $JOB_NAME $BUILD_NUMBER
$FILETOEXECUTE $JOB_NAME $BUILD_NUMBER