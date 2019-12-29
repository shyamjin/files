# Create a 'DU' for Value Pack.

# The goal is to create artifacts from the Amily 'self service' functionality (and related end-user tasks) that can be
# deployed via the Value Pack DPM and its front-end GUI. These artifacts are generated from with the runtime
# environments and do not get back-propagated into source control. Instead, they are archived in a (Nexus) repository
# near to the runtime environment, to give the end-user an some ability of versioned deployments of the artifacts.
#
# RETURN CODES
# 0 = all ok
# 1 = error

# === SCRIPT FUNCTIONS ===
function print_error_and_exit
{
    echo -e "$@"
    exit 1
}

# --- Get user inputs

job_name="$1"
artifact_name="$(echo $job_name | cut -d'/' -f1)_$GIT_BRANCH"
artifact_version="$2"
description="$3"

# --- First query the DPM to see if the DU exists
echo ""
echo "First query the DPM to see if the DU exists"
echo ""

query_du_url="${DPM_BASE_URL}/deploymentunit/search/name/${artifact_name}"
echo "Querying the DPM to see if the DU is already defined"
echo ".. URL: ${query_du_url}"
query_response=$(curl -v -k -H Access-Token:\ ${DPM_AUTH_TOKEN} -H details:\ false "${query_du_url}" 2>&1)
if [[ ! ${query_response} =~ \"result\":\ \"success\" ]]
then
	print_error_and_exit "Error communicating with DPM on query:\n----------------------------------------\n${query_response}\n----------------------------------------\n"
fi

# --- If the DU does not exist, create it
if [[ ${query_response} =~ \"data\":\ null ]]
then
	echo ".. DPM says DU does not exist yet"
  echo ""
	new_du_details='{"name":"'${artifact_name}'", "type":"'${DU_TYPE}'", "release_notes":"'${RELEASE_NOTES}'","branch":"'${GIT_BRANCH}'", "deployer_to_use":"'${DEPLOYER_TO_USE}'","repository_to_use" : "'${REPOSITORY_TO_USE}'","flexible_attributes":{"compTypes":""}}'
	new_du_url="${DPM_BASE_URL}/deploymentunit/new"
	echo "Sending request to create new DU"
	echo ".. URL: ${new_du_url}"
	echo ".. Payload: ${new_du_details}"
	create_response=$(curl -v -k "${new_du_url}" -H 'Content-Type: application/json' -H Access-Token:\ ${DPM_AUTH_TOKEN} -d "${new_du_details}" 2>&1)
	if [[ ! ${create_response} =~ \"result\":\ \"success\" ]]
	then
		print_error_and_exit "Error communicating with DPM on create DU:\n----------------------------------------\n${create_response}\n----------------------------------------\n"
	fi
	# --- grab the DU ID
	du_id=$(echo $create_response|sed 's/^.*"_id": "\([^"]*\)".*$/\1/')
else
	# --- grab the DU ID
	du_id=$(echo $query_response|sed 's/^.*"\$oid": "\([^"]*\)".*$/\1/')
	echo ".. DPM says DU does exists, we got ID [${du_id}]"
fi

# --- check the ID actually looks like an ID
if [[ ! ${du_id} =~ ^[0-9a-f][0-9a-f]*$ ]]
then
	print_error_and_exit "Failed to extract the DU ID from the response from DPM Create DU API response\nConversation:\n${create_response}"
fi

# --- Update the DU with deployment fields
echo ""
echo ".. Trying to update DU"
update_du_details='{"name":"'${artifact_name}'","_id":{"oid":"'${du_id}'"},"deployment_field":{"fields":'${DEPLOYMENT_FIELDS}'}, "deployer_to_use":"'${DEPLOYER_TO_USE}'","repository_to_use" : "'${REPOSITORY_TO_USE}'", "type":"'${DU_TYPE}'", "release_notes":"'${RELEASE_NOTES}'"}'
update_du_url="${DPM_BASE_URL}/deploymentunit/update"
echo "Sending request to update DU : ${du_id}"
echo ".. URL: ${update_du_url}"
echo ".. Payload: ${update_du_details}"
update_response=$(curl -X PUT -v -k "${update_du_url}" -H 'Content-Type: application/json' -H Access-Token:\ ${DPM_AUTH_TOKEN} -d "${update_du_details}" 2>&1)
if [[ ! ${update_response} =~ \"result\":\ \"success\" ]]
then
	print_error_and_exit "Error communicating with DPM on update DU:\n----------------------------------------\n${update_response}\n----------------------------------------\n"
fi
	

echo "DU Step completed successfully"
echo "Finished."
