#!/bin/bash

if [[ ! -f $1 ]]; then
  echo "Error: pipline.json file is not provided"
  exit 1
fi

which jq > /dev/null
if [ $? -ne 0 ]; then
	echo "Error: jq isn't installed."
	echo "Ubuntu instalation: sudo apt install jq"
	echo "Mac instalation: brew install jq"
exit
fi


pipeline_config=$1
current_date=$(date +%Y-%m-%d)
updated_pipeline_config="../pipeline-${current_date}.json"


branch=main
owner=""
poll_for_source_changes=false
configuration=""


shift
while [[ $# -gt 0 ]]; do
	case "$1" in
		--branch) branch="$2"; shift 2;;
		--owner) owner="$2"; shift 2;;
		'--poll-for-source-changes') poll_for_source_changes="$2"; shift 2;; 
		--configuration) configuration="$2"; shift 2;;
		*) break;;
	esac
done

env_var=$(jq '.pipeline.stages[1].actions[0].configuration.EnvironmentVariables' $pipeline_config)
updated_env_var=$(echo $env_var | sed 's/"value\\":\\.*\\",/\"value\\":\\"REPLACE\\",/' | sed "s/REPLACE/$configuration/")

jq 'del(.metadata)' $pipeline_config | jq '.pipeline.version = .pipeline.version + 1' |\
 jq --arg owner "$owner" '.pipeline.stages[0].actions[0].configuration.Owner = $owner' |\
 jq --arg branch "$branch" '.pipeline.stages[0].actions[0].configuration.Branch = $branch' |\
 jq --arg pull "$poll_for_source_changes" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pull' |\
 jq --argjson env_variable "$updated_env_var" '.pipeline.stages[1].actions[0].configuration.EnvironmentVariables = $env_variable' |\
 jq --argjson env_variable "$updated_env_var" '.pipeline.stages[3].actions[0].configuration.EnvironmentVariables = $env_variable' > $updated_pipeline_config


