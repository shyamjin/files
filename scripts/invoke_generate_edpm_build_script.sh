FILE="./dpm/scripts/generate_edpm_build.sh"
GLOBALFILE="$DPM_SCRIPTS_PATH/generate_edpm_build.sh"
FILETOEXECUTE=""

if [ ! -f $FILE ]; then
            echo "$FILE not found!. Checking for script in global path"


                if [ ! -f $GLOBALFILE]; then
                    echo "$GLOBALFILE not found!. Exiting!!"
                    exit 1
                else
                    echo "GlobalScript : $GLOBALFILE was found"
                    FILETOEXECUTE=$GLOBALFILE
                fi

else
            echo "Local Script : $FILE was found"
            FILETOEXECUTE=$FILE
fi

$FILETOEXECUTE

