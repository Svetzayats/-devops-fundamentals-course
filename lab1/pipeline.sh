#!/bin/bash 

# check JQ and exit if it is not installed 
if ! command -v jq &> /dev/null; then
    echo -e "\e[91mError: JQ is not installed on your system.\e[0m"
    echo ""
    echo "To install JQ on different platforms:"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "sudo apt-get update && sudo apt-get install -y jq"
    echo ""
    echo "For CentOS/RHEL:"
    echo "sudo yum install -y epel-release && sudo yum install -y jq"
    echo ""
    echo "For macOS:"
    echo "brew install jq"
    echo ""
    echo "For other platforms, please refer to the JQ documentation."
    exit 1
fi



# check that we get path to pipeline 
if [ -z "$1" ]
then
    echo -e "\e[91mError: Please provide path to pipeline json\e[0m"
    exit 1
fi 

# check that file exists 
if [ -f "$1" ]
then true
else 
    echo -e "\e[91mError: File is not found. Check the path to file\e[0m"
    exit 1
fi

# create copy json pipeline 
filename=$(basename -- "$1")
directory=$(dirname -- "$1")
date=$(date '+%Y-%m-%d')
new_filename="${filename%.*}-${date}.${filename##*.}"
cp "$1" "${directory}/${new_filename}"

# check that we have required properties 
if ! jq -e '.pipeline | has("version") and has("stages")' "${directory}/${new_filename}" >/dev/null 
then 
    echo -e "\e[91mError: JSON doesn't contain required field pipeline or version and stages in pipeline object\e[0m"
    exit 1
fi

jq 'del(.metadata)' "${directory}/${new_filename}" > "${directory}/${new_filename}.tmp" && mv "${directory}/${new_filename}.tmp" "${directory}/${new_filename}"
jq '.pipeline.version += 1' "${directory}/${new_filename}" > "${directory}/${new_filename}.tmp" && mv "${directory}/${new_filename}.tmp" "${directory}/${new_filename}"

branch=
owner=
poll_for_source_changes="false"
configuration="production"

# check flags 
while [[ $# -gt 0 ]] 
do 
    key="$1"
    case $key in
        -b|--branch)
        branch="$2"
        shift
        shift
        ;;
        -o|--owner)
        owner="$2"
        shift
        shift
        ;;
        -p|--poll-for-source-changes)
        poll_for_source_changes="true"
        shift
        ;;
        -c|--configuration)
        configuration="$2"
        shift
        shift
        ;;
        *)
        shift
        ;;
    esac
done 

if [ -z "$branch" ]
then 
    branch=main
fi

# update branch, poll and config 
jq --arg branchName "$branch" --argjson poll "$poll_for_source_changes" --arg config "[{\"name\":\"BUILD_CONFIGURATION\",\"value\":\"$configuration\",\"type\":\"PLAINTEXT\"}]" '.pipeline.stages[0].actions[0].configuration.Branch = $branchName | .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $poll | .pipeline.stages[1].actions[0].configuration.EnvironmentVariables = $config |  .pipeline.stages[3].actions[0].configuration.EnvironmentVariables = $config' "${directory}/${new_filename}" > "${directory}/${new_filename}.tmp" 
mv "${directory}/${new_filename}.tmp" "${directory}/${new_filename}"

# optionally update owner
if [ -z "$owner" ]
then true
else 
    jq --arg ownerName "$owner" '.pipeline.stages[0].actions[0].configuration.Owner = $ownerName' "${directory}/${new_filename}" > "${directory}/${new_filename}.tmp" 
    mv "${directory}/${new_filename}.tmp" "${directory}/${new_filename}"
fi

echo "Your updated pipeline ${new_filename} is ready!"



