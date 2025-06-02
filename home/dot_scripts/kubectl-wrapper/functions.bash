#From here: https://www.baeldung.com/linux/check-variable-exists-in-list
function exists_in_list() {
    LIST=$1
    DELIMITER=$2
    VALUE=$3
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}

function SCREEN_MESSAGE() {
    MESSAGE=$1
    DASH_O_PASSED_IN_NOT_WIDE=$2

    if [ "$DASH_O_PASSED_IN_NOT_WIDE" == 0 ]; then
        echo -e "$MESSAGE"
    fi
}

function CHECK_FOR_REQUIRED_PLUGINS() {
    kubectl plugin list --name-only 2>/dev/null | grep -i "kubectl-confirm" 2>/dev/null 1>/dev/null

    #
    #       I had to write out the whole redirect at the end because for some reason
    #       my (James P's) shell script formatter screws it up
    #
    if [ $? -ne 0 ]; then
        echo "kubectl-confirm plugin is not installed. Please install it."
        echo "First install krew: https://krew.sigs.k8s.io/docs/user-guide/setup/install/"
        echo "Then install kubectl-confirm: kubectl krew install confirm"
        exit 1
    fi
}

#
#   Check to see if the user has access to the cloudwatch log group
#       Exit if no, no matter what.
#
function CHECK_CLOUDWATCH_ACCESS() {
    # Check if the user has access to the S3 bucket
    aws logs describe-log-streams --log-group-name /koddi/platform/kubectl_wrapper --region us-east-1 2>/dev/null 1>/dev/null
    if [ $? -ne 0 ]; then
        echo -e "${FAIL}You do don't seem to have access to the cloudwatch log group. Make sure you have AWS variables set in your environment and they're pointed at the right environment.  run 'aws sts get-caller-identity' and make sure you're connecting to the prod account ()${ENDC}"
        exit 1
    fi
}

#
#   Build the JSON in here & save to cloudwatch.
#
#   How do we handle the logging now?
#       If destructive option & not on a dev cluster, log it to cloudwatch
#
#   How do we maybe WANT to handle the logging?:
#       If on AKS, check for access to aws platform cloudwatch and send the logs there.
#       If on AWS, and in platform, send the logs there (same as every account on AKS)
#       If on AWS, and NOT in the platform account, how do we send logs to the platform cloudwatch?
#
#   Why is the latter not just done? If you run on dev AWS you've got keys set for the nonprod account which currently doesn't allow access to platform cloudwatch
#       Will have to figure out how to allow access, it's probably not difficult, I just don't want to deal with it right now.
#       Plus logging for dev isn't the most important
#
function LOG() {
    CLUSTER_NAME=$1
    CONTEXT=$2
    NAMESPACE=$3
    ENTIRE_COMMAND_ENCODED=$4
    CONFIRM_OUTPUT_ENCODED=$5

    ENTIRE_COMMAND=$(echo $ENTIRE_COMMAND_ENCODED | base64 -d)
    CONFIRM_OUTPUT=$(echo $CONFIRM_OUTPUT_ENCODED | base64 -d)

    WHOAMI=$(whoami)
    HOSTNAME=$(hostname)

    #The following isn't perfect but OS X doesn't have an easy way to get epoch milliseconds, you have to install a separate package from homebrew and it's not worth it for this.
    DATE_EPOCH_MILLISECONDS="$(date +"%s")000"

    if [[ $CONFIRM_OUTPUT == *"Command aborted"* ]]; then
        COMMAND_STATUS="Aborted"
    elif [[ $CONFIRM_OUTPUT == *"Error"* ]]; then
        COMMAND_STATUS="Error"
    else
        COMMAND_STATUS="Success"
    fi

    if [[ $CLUSTER_NAME != *"dev"* ]]; then
        LOG_LINE=$(
            cat <<EOF
{ "cluster": "$CLUSTER_NAME", "local_context": "$CONTEXT", "namespace": "$NAMESPACE", "command": "$ENTIRE_COMMAND", "status": "$COMMAND_STATUS", "local_user": "$WHOAMI", "local_hostname": "$HOSTNAME", "confirm_output_encoded": "$CONFIRM_OUTPUT_ENCODED" }
EOF
        )

        LOG_MESSAGE=$(echo $LOG_LINE | jq tostring)

        aws logs put-log-events --log-group-name "/koddi/platform/kubectl_wrapper" --log-stream-name "kubectl_wrapper_logs" --region us-east-1 --log-events "[{\"timestamp\": $DATE_EPOCH_MILLISECONDS, \"message\": $LOG_MESSAGE}]" 2>/dev/null 1>/dev/null

    else
        echo "You're on a dev cluster, not logging to cloudwatch"
    fi
}

#
#   COLORS, yo!
#
HEADER="\033[95m"
OKBLUE="\033[94m"
OKCYAN="\033[96m"
OKGREEN="\033[92m"
WARNING="\033[93m"
FAIL="\033[91m"
ENDC="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
