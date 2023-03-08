#!/bin/bash

if [[ ! -f $1 ]]; then
  echo "Error: pipline.json file is not provided"
  exit 1
fi

pipeline_config=$1
current_date=$(date +%Y-%m-%d)
updated_pipeline_config="../pipeline-${current_date}.json"


branch=main
owner=""
pull_from_source_changes=false
configuration=""


shift
while [[ $# -gt 0 ]]; do
	case "$1" in
		--branch) branch="$2"; shift 2;;
		--owner) owner="$2"; shift 2;;
		--pull-from-source-changes) pull_from_source_changes=true; shift;; 
		--configuration) configuration="$2"; shift 2;;
		*) break;;
	esac
done

echo "branch === $branch"
echo "owner === $owner"
echo "pull === $pull_from_source_changes"
echo "configuration === $configuration"

set_configuration() {
qualityGateEnvVar=$(jq '.pipeline.stages[1].actions[0].configuration.EnvironmentVariables' $pipeline_config)
buildEnvVar=$(jq '.pipeline.stages[3].actions[0].configuration.EnvironmentVariables' $pipeline_config)

echo $qualityGateEnvVar | sed 's/"value\\":\\.*\\",/\"value\\":\\"REPLACE\\",/' | sed "s/REPLACE/$configuration/"

jq -c '.pipeline.stages[1].actions[0].configuration.EnvironmentVariables | fromjson' $pipeline_config | jq -c '.[]' |\
 jq --arg config "$configuration" '.value = $config'

#echo "TEST $test"
}

jq 'del(.metadata)' $pipeline_config | jq '.pipeline.version = .pipeline.version + 1' |\
 jq --arg owner "$owner" '.pipeline.stages[0].actions[0].configuration.Owner = $owner' |\
 jq --arg branch "$branch" '.pipeline.stages[0].actions[0].configuration.Branch = $branch' |\
 jq --arg pull "$pull_from_source_changes" '.pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pull'


#'.pipeline.stages[0].actions[0].configuration.Owner = $owner' > $updated_pipeline_config
#jq '.pipeline.name = 123' "../${updated_pipeline_config}"
#cat $updated_pipeline_config

set_configuration
