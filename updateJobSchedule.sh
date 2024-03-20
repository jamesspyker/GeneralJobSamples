USAGE="$(basename "$0") project_name job_name"

if [ $# != 2 ] ; then
    echo $USAGE
    exit 1;
fi

PROJECT_ID=`cpdctl project list --name $1 --output json -j "(resources[].metadata.guid)[0]" --raw-output`


JOB_ID=`cpdctl asset search --project-id $PROJECT_ID --type-name job --query "asset.name:$2" --output json -j "results[0].metadata.asset_id" --raw-output`

cpdctl job get --project-id $PROJECT_ID --job-id $JOB_ID --output json >tmpJobDef.json

# The field /entity/job/schedule shows the schedule information in the server time zone (always UTC for CPDaaS)
# It is in CRON format: https://en.wikipedia.org/wiki/Cron

SCHEDULE_STRING=`jq -r '.entity.job.schedule' <tmpJobDef.json`
#echo "$SCHEDULE_STRING"

# The logic to update the schedule string will depend upon the nature of your scheduling and what you are trying to update.
# For example, to move the schedule one hour ahead to compensate for a daylight savings time change you can just add 1
# to the hours value (modulus 24, so 23+1 becomes zero).   If your schedule also specifies a day (e.g. it was 23:30 on Friday)
# you'd need to update the day as well if the hour is 23 (e.g. 23:30 on Friday becomes 00:30 on Saturday)

# In this example, using a python function to adjust a schedule one hour ahead where the job is scheduled to run
#  at a specific time once a week 
NEW_SCHEDULE_STRING=`python updateScheduleString.py "$SCHEDULE_STRING"`
#echo "$NEW_SCHEDULE_STRING"

PATCH_BODY="[{ \"op\": \"replace\", \"path\": \"/entity/job/schedule\", \"value\": \"$NEW_SCHEDULE_STRING\" }]"

cpdctl job update --project-id $PROJECT_ID --job-id $JOB_ID --body "$PATCH_BODY"

