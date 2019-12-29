

# === SCRIPT FUNCTIONS ===
function print_error_and_exit
{
    echo -e "$@"
    exit 1
}

echo "------------------------Fetching DU ID from deployment manager------------------------"


artifact_name="$(echo $JOB_NAME | cut -d'/' -f1)_$GIT_BRANCH"
query_du_url="${DPM_BASE_URL}/deploymentunit/search/name/${artifact_name}"
echo "Querying the DPM to see if the DU is already defined"
echo ".. URL: ${query_du_url}"
query_response=$(curl -v -k -H Access-Token:\ ${DPM_AUTH_TOKEN} -H details:\ false "${query_du_url}" 2>&1)
if [[ ! ${query_response} =~ \"result\":\ \"success\" ]]
then
    print_error_and_exit "Error communicating with DPM on query:\n----------------------------------------\n${query_response}\n----------------------------------------\n"
fi

# --- grab the DU ID
echo $query_response
DU_ID=$(echo $query_response|sed 's/^.*"\$oid": "\([^"]*\)".*$/\1/')
echo ".. DPM says DU does exists, we got ID [${DU_ID}]"

echo "------------------------Uploading build to deployment manager------------------------"
export http_proxy= https_proxy= no_proxy= HTTP_PROXY= HTTPS_PROXY= NO_PROXY=

STATUS=1
BUILD_FILE_NAME="build.zip"
SIZE=$(du -h ${BUILD_FILE_NAME} | awk '{print $1}')
GROUP_ID="$(echo $JOB_NAME | cut -d'/' -f1)"
RELATIVE_PATH="${REPO_ID}/${JOB_NAME}/${ARTIFACT_ID}/${GIT_BRANCH}"
RELEASE_AUTHOR="$(git show --format='%aN <%aE>' $GIT_COMMIT)"
RELEASE_NOTES="$(git diff-tree --no-commit-id --name-only -r $GIT_COMMIT)"
PACKAGE="$(echo $GROUP_ID | cut -d'/' -f1).$GIT_BRANCH"
ADDITIONAL_INFO="{\"version\" : \"${GIT_BRANCH}\",\"package\" : \"${JOB_NAME}\",\"artifact\" : \"${ARTIFACT_ID}\",\"repo_id\" : \"${REPO_ID}\",\"relative_path\" : \"${RELATIVE_PATH}\",\"file_name\" : \"${ARTIFACT_ID}-${GIT_BRANCH}-${BUILD_NUMBER}.zip\",\"release_notes\" : \"${RELEASE_NOTES}\"}"
FILE_PATH="${NEXUS_DPM_URL}/${REPO_ID}/${JOB_NAME}/${ARTIFACT_ID}/${GIT_BRANCH}/${ARTIFACT_ID}-${GIT_BRANCH}-${BUILD_NUMBER}.zip"
ADD_BUILD_URL=${DPM_BASE_URL}/build/add
JSON="{\"status\" : \"${STATUS}\", \"build_number\" : \"${BUILD_NUMBER}\", \"package_name\" : \"${ARTIFACT_ID}-${GIT_BRANCH}-${BUILD_NUMBER}.zip\",\"package_type\":\"zip\",\"parent_entity_id\" : \"${DU_ID}\",\"type\" : \"url\",\"file_path\" : \"${FILE_PATH}\",\"file_size\" : \"${SIZE}\",\"repo_type\" : \"nexus\",\"additional_info\" :${ADDITIONAL_INFO}}"

echo ""
echo "Build JSON: $JSON"
echo ""
echo "Build ADD_BUILD_URL: $ADD_BUILD_URL"

RESULT=$(echo ${JSON} | curl -k --silent  --output /dev/stderr  --write-out "%{http_code}"  -H  "Content-Type: application/json" -H "Access-Token":"${DPM_AUTH_TOKEN}" --request POST --data @- ${ADD_BUILD_URL})

echo ""
echo "DPM Response $RESULT"

if [ $RESULT -eq 200 ]
then
    echo "curl -k command passed, removing the ${BUILD_FILE_NAME}"
    rm -f ${BUILD_FILE_NAME}
else
    echo "curl -k command failed,removing the ${BUILD_FILE_NAME}"
    rm -f ${BUILD_FILE_NAME}
    exit 1
fi