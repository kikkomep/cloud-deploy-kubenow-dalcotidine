#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
# (but allow for the error trap)
set -eE

function report_err() {
  # post deployment log to slack channel (only if portal deployment)
  if [[ ! -n "$LOCAL_DEPLOYMENT" ]]; then
    curl -F text="Portal deployment failed, reference=$PORTAL_DEPLOYMENT_REFERENCE" \
	     -F channels="portal-deploy-error" \
	     -F token="$SLACK_ERR_REPORT_TOKEN" \
	     https://slack.com/api/chat.postMessage
  fi
}

# Trap errors
trap 'report_err' ERR

# read portal secrets from private repo
#if [ -z "$LOCAL_DEPLOYMENT" ]; then
#   source "$PORTAL_APP_REPO_FOLDER/phenomenal-cloudflare/cloudflare_token_phenomenal.cloud.sh"
#   export SLACK_ERR_REPORT_TOKEN=${cat \"$PORTAL_APP_REPO_FOLDER/phenomenal-cloudflare/slacktoken\"}
#fi

# Add terraform to path (TODO) remove this portal workaround eventually
export PATH=/usr/lib/terraform_0.10.7:$PATH

# Query Terraform state file
terraform show "$PORTAL_DEPLOYMENTS_ROOT/$PORTAL_DEPLOYMENT_REFERENCE/terraform.tfstate"
