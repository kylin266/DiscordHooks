#!/bin/bash
#https://github.com/DiscordHooks/gitlab-ci-discord-webhook
#todo- replace artifact code

function htmlEscape(){ local s="${1//&/&amp;}"; s="${s//</&lt;}"; s="${s//>/&gt;}"; echo "${s//'"'/&quot;}"; } #stop code injection

case $1 in
  "success") EMBED_COLOR=3066993; STATUS_MESSAGE="Passed"; ARTIFACT_URL="$CI_JOB_URL/artifacts/download" ;;
  "failure") EMBED_COLOR=15158332; STATUS_MESSAGE="Failed"; ARTIFACT_URL="Not available" ;;
  *) EMBED_COLOR=0; STATUS_MESSAGE="Status Unknown"; ARTIFACT_URL="Not available" ;;
esac
shift
[ $# -lt 1 ] && { echo -e "ERROR\nThis script requires a second argument to populate the WEBHOOK_URL environment variable." && exit; }
#<debug>
env #just get all the variables
#</debug>


AUTHOR_NAME="${GITLAB_USER_NAME} <${GITLAB_USER_EMAIL}>" #follow CI_COMMIT_AUTHOR format

AUTHOR_NAME="$(htmlEscape "$AUTHOR_NAME")"
CI_COMMIT_AUTHOR="$(htmlEscape "$CI_COMMIT_AUTHOR")"
CI_COMMIT_TITLE="$(htmlEscape "$CI_COMMIT_TITLE")"
CI_COMMIT_DESCRIPTION="$(htmlEscape "$CI_COMMIT_DESCRIPTION")"

CREDITS=" $GITLAB_USER_EMAIL authored &"
[ "$AUTHOR_NAME" != "$CI_COMMIT_AUTHOR" ] || CREDITS+=" ${CI_COMMIT_AUTHOR}"
CREDITS+=" committed"

[ -z $CI_MERGE_REQUEST_ID ] || URL="$CI_PROJECT_URL/merge_requests/$CI_MERGE_REQUEST_ID"
[ -z $LINK_ARTIFACT ] || [ $LINK_ARTIFACT = false ] || LINK_ARTIFACT=','$'\n''    { "name": "Artifacts", "value": "'"[\`$CI_JOB_ID\`]($ARTIFACT_URL)"'", "inline": true }'
DISCORD_WEBHOOK_DATA='{ "username": "", "avatar_url": "https://gitlab.com/favicon.png",
  "embeds": [ {
    "author": { "name": "Pipeline #'"$CI_PIPELINE_IID"' '"$STATUS_MESSAGE"' - '"$CI_PROJECT_PATH_SLUG"'", "url": "'"$CI_PIPELINE_URL"'", "icon_url": "https://gitlab.com/favicon.png" },
    "color": '$EMBED_COLOR', "title": "'"$CI_COMMIT_TITLE"'", "url": "'"${URL:-}"'", "description": "'"${CI_COMMIT_DESCRIPTION//$'\n'/ }"\\n\\n"$CREDITS"'", "timestamp": "'"$CI_JOB_STARTED_AT"'",
    "fields": [ 
      { "name": "Commit", "value": "'"[\`$CI_COMMIT_SHORT_SHA\`]($CI_PROJECT_URL/commit/$CI_COMMIT_SHA)"'", "inline": true },
      { "name": "Branch", "value": "'"[\`$CI_COMMIT_REF_NAME\`]($CI_PROJECT_URL/tree/$CI_COMMIT_REF_NAME)"'", "inline": true}'"${LINK_ARTIFACT:-}"'
] } ] }'

#-----Google Chat Webhook
shopt -s extglob #for +($'\n')
export parent=spaces/AAAAvhfgZQ8 key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI token=C84V7QzXJ5tQ0Uyq2XTHFUwLK1Oo8lg7FKsBv4wRAQ8%3D threadKey="$CI_COMMIT_SHORT_SHA'-'$CI_PIPELINE_IID"
[ -z ${threadKey+x} ] || threadKey="&threadKey=${threadKey:-}"; [ -z ${requestId+x} ] || requestId="&requestId=${requestId:-}"
[ "$STATUS_MESSAGE" = 'Passed' ] && { COL='00ff00'; IU='PHN2ZyB3aWR0aD0iMTQiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNCAxNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxwYXRoIGQ9Ik0wIDdhNyA3IDAgMSAxIDE0IDBBNyA3IDAgMCAxIDAgN3oiLz48cGF0aCBkPSJNMTMgN0E2IDYgMCAxIDAgMSA3YTYgNiAwIDAgMCAxMiAweiIgZmlsbD0iI0ZGRiIgc3R5bGU9ImZpbGw6IHZhcigtLXN2Zy1zdGF0dXMtYmcsICNmZmYpOyIvPjxwYXRoIGQ9Ik02LjI3OCA3LjY5N0w1LjA0NSA2LjQ2NGEuMjk2LjI5NiAwIDAgMC0uNDItLjAwMmwtLjYxMy42MTRhLjI5OC4yOTggMCAwIDAgLjAwMi40MmwxLjkxIDEuOTA5YS41LjUgMCAwIDAgLjcwMy4wMDVsLjI2NS0uMjY1TDkuOTk3IDYuMDRhLjI5MS4yOTEgMCAwIDAtLjAwOS0uNDA4bC0uNjE0LS42MTRhLjI5LjI5IDAgMCAwLS40MDgtLjAwOUw2LjI3OCA3LjY5N3oiLz48L2c+PC9zdmc+Cg=='; } || { COL='ff0000'; IU='PHN2ZyB3aWR0aD0iMTQiIGhlaWdodD0iMTQiIHZpZXdCb3g9IjAgMCAxNCAxNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxwYXRoIGQ9Ik0wIDdhNyA3IDAgMSAxIDE0IDBBNyA3IDAgMCAxIDAgN3oiLz48cGF0aCBkPSJNMTMgN0E2IDYgMCAxIDAgMSA3YTYgNiAwIDAgMCAxMiAweiIgZmlsbD0iI0ZGRiIgc3R5bGU9ImZpbGw6IHZhcigtLXN2Zy1zdGF0dXMtYmcsICNmZmYpOyIvPjxwYXRoIGQ9Ik03IDUuOTY5TDUuNTk5IDQuNTY4YS4yOS4yOSAwIDAgMC0uNDEzLjAwNGwtLjYxNC42MTRhLjI5NC4yOTQgMCAwIDAtLjAwNC40MTNMNS45NjggN2wtMS40IDEuNDAxYS4yOS4yOSAwIDAgMCAuMDA0LjQxM2wuNjE0LjYxNGMuMTEzLjExNC4zLjExNy40MTMuMDA0TDcgOC4wMzJsMS40MDEgMS40YS4yOS4yOSAwIDAgMCAuNDEzLS4wMDRsLjYxNC0uNjE0YS4yOTQuMjk0IDAgMCAwIC4wMDQtLjQxM0w4LjAzMiA3bDEuNC0xLjQwMWEuMjkuMjkgMCAwIDAtLjAwNC0uNDEzbC0uNjE0LS42MTRhLjI5NC4yOTQgMCAwIDAtLjQxMy0uMDA0TDcgNS45Njh6Ii8+PC9nPjwvc3ZnPgo='; }
[ -z $LINK_ARTIFACT ] || [ $LINK_ARTIFACT = false ] || ARTIFACTS='{ "keyValue": { "topLabel": "Artifacts: '$CI_JOB_ID'", "content": " ", "contentMultiline": "false", "onClick": { "openLink": { "url": "'$ARTIFACT_URL'" } }, "button": { "imageButton": { "name": "Artifacts: '$CI_JOB_ID'", "iconUrl": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTEuNSA0LjV2LTJoMTN2MmgtMTNaTTEgNmExIDEgMCAwIDEtMS0xVjJhMSAxIDAgMCAxIDEtMWgxNGExIDEgMCAwIDEgMSAxdjNhMSAxIDAgMCAxLTEgMXY4YTEgMSAwIDAgMS0xIDFIMmExIDEgMCAwIDEtMS0xVjZabTEuNSAwdjcuNWgxMVY2aC0xMVpNNCA4Ljc1QS43NS43NSAwIDAgMSA0Ljc1IDhoNi41YS43NS43NSAwIDAgMSAwIDEuNWgtNi41QS43NS43NSAwIDAgMSA0IDguNzVaIiBmaWxsPSIjMDAwIi8+PC9zdmc+", "onClick": { "openLink": { "url": "'$ARTIFACT_URL'" } } } } } },'
GCHAT_WEBHOOK_DATA='{
  "name": "'$CI_COMMIT_SHORT_SHA'-'$CI_PIPELINE_IID'", "text": "", "previewText": "preview", "fallbackText": "fallback", "argumentText": "argument",
  "cards": [
    {
      "name": "'$CI_COMMIT_SHORT_SHA'-'$CI_PIPELINE_IID'",
      "header": {
        "title": "Pipeline #'$CI_PIPELINE_IID' - '$STATUS_MESSAGE'", "subtitle": "'$CI_PROJECT_PATH_SLUG'",
        "imageUrl": "https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png",
        "imageStyle": "AVATAR", "imageAltText": "GitLab Icon"
      },
      "sections": [
        {
          "collapsable": false, "uncollapsableWidgetsCount": 0, "header": "",
          "widgets": [
            {
              "keyValue": {
                "topLabel": "Commit: '$CI_COMMIT_SHORT_SHA'",
                "content": "Subject: '"$CI_COMMIT_TITLE"'<br>Message:<br><i>'"${CI_COMMIT_DESCRIPTION//+($'\n')/<br>}"'</i>",
                "bottomLabel": "Committer: '"${CI_COMMIT_AUTHOR:-$AUTHOR_NAME}"'",
                "contentMultiline": "true", "onClick": { "openLink": { "url": "'$CI_PROJECT_URL'/commit/'$CI_COMMIT_SHA'" } },
                "button": { "imageButton": { "name": "Commit: '$CI_COMMIT_SHORT_SHA'", "iconUrl": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTggMTAuNWEyLjUgMi41IDAgMSAwIDAtNSAyLjUgMi41IDAgMCAwIDAgNVpNOCAxMmMxLjk1MyAwIDMuNTc5LTEuNCAzLjkzLTMuMjVoMy4zMmEuNzUuNzUgMCAwIDAgMC0xLjVoLTMuMzJhNC4wMDEgNC4wMDEgMCAwIDAtNy44NiAwSC43NWEuNzUuNzUgMCAwIDAgMCAxLjVoMy4zMkE0LjAwMSA0LjAwMSAwIDAgMCA4IDEyWiIgZmlsbD0iIzAwMCIvPjwvc3ZnPg==", "onClick": { "openLink": { "url": "'$CI_PROJECT_URL'/commit/'$CI_COMMIT_SHA'" } } } }
              }
            },
            {
              "keyValue": {
                "topLabel": "Branch: '$CI_COMMIT_REF_NAME'", "content": "Project: '$CI_PROJECT_PATH_SLUG'", "bottomLabel": "Author: '"$AUTHOR_NAME"'",
                "contentMultiline": "false", "onClick": { "openLink": { "url": "'$CI_PROJECT_URL'/tree/'$CI_COMMIT_REF_NAME'" } },
                "button": { "imageButton": { "name": "Branch: '$CI_COMMIT_REF_NAME'", "iconUrl": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTExLjUgNC41YTEgMSAwIDEgMCAwLTIgMSAxIDAgMCAwIDAgMlptMi41LTFhMi41MDEgMi41MDEgMCAwIDEtMS44NzIgMi40MkEzLjUwMiAzLjUwMiAwIDAgMSA4Ljc1IDguNWgtMS41YTIgMiAwIDAgMC0xLjk2NSAxLjYyNiAyLjUwMSAyLjUwMSAwIDEgMS0xLjUzNS0uMDExdi00LjIzYTIuNTAxIDIuNTAxIDAgMSAxIDEuNSAwdjEuNzQyYTMuNDg0IDMuNDg0IDAgMCAxIDItLjYyN2gxLjVhMiAyIDAgMCAwIDEuODIzLTEuMTc3QTIuNSAyLjUgMCAxIDEgMTQgMy41Wm0tOC41IDlhMSAxIDAgMSAxLTIgMCAxIDEgMCAwIDEgMiAwWm0wLTlhMSAxIDAgMSAxLTIgMCAxIDEgMCAwIDEgMiAwWiIgZmlsbD0iIzAwMCIvPjwvc3ZnPg==", "onClick": { "openLink": { "url": "'$CI_PROJECT_URL'/tree/'$CI_COMMIT_REF_NAME'" } } } }
              }
            },'"$ARTIFACTS"'
            {
              "keyValue": {
                "topLabel": "Pipeline: '$CI_PIPELINE_IID'", "content": "<b><font color=\"#'$EMBED_COLOR'\">'$STATUS_MESSAGE'</font></b>", "bottomLabel": "",
                "contentMultiline": "false", "onClick": { "openLink": { "url": "'$CI_PIPELINE_URL'" } },
                "button": { "imageButton": { "name": "Pipeline: '$CI_PIPELINE_IID'", "iconUrl": "data:image/svg+xml;base64,'"$IU"'", "onClick": { "openLink": { "url": "'$CI_PIPELINE_URL'" } } } }
              }
            }
] } ] } ] }'
#-----

for ARG in "$@"; do
  echo -e "[Webhook]: Sending webhook to Discord...\\n";
  (curl -f -A "GitLabCI-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$DISCORD_WEBHOOK_DATA" "$ARG") \
   && echo -e "\\n[Webhook]: Successfully sent Discord webhook." || echo -e "\\n[Webhook]: Unable to send Discord webhook."

  echo -e "[Webhook]: Sending webhook to Google Chat...\\n";
  (curl -f -H 'Content-Type: application/json' -X POST  -d "$GCHAT_WEBHOOK_DATA" 'https://chat.googleapis.com/v1/'${parent}'/messages?key='${key}'&token='${token}${threadKey}${requestId}) \
   && echo -e "\\n[Webhook]: Successfully sent Google Chat webhook." || echo -e "\\n[Webhook]: Unable to send Google Chat webhook."
done
