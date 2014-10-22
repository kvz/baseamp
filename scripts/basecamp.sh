#!/usr/bin/env bash
# Transloadit API2. Copyright (c) 2014, Transloadit Ltd.
#
# This file
#  - Requires your BASECAMP_USERNAME and BASECAMP_PASSWORD as env vars
#  - Takes the arguments:
#     $name (kevin)
#     $due_date (2014-10-26 or 0000-00-00 for none)
#     $content (Fix the tests in API2)
#  - Saves it as a Basecamp Uncategorized Todo
#
# Depends on
#  - https://raw.githubusercontent.com/dominictarr/JSON.sh/master/JSON.sh
#
# More info
#  - https://github.com/basecamp/bcx-api/blob/master/sections/todos.md
#
# Hints
#
#  - If you don't care about remaining/completed: |egrep '\["todos","[^"]*",\d+,"content"\]'
#
# Authors:
#  - Kevin van Zonneveld <kevin@transloadit.com>

set -o pipefail
set -o errexit
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"


account_id=xxx
project_id=xxx
todolist_id=xxx

name="${1}"
due_at="${2}"
content="${*:3}"

if [ "${name}" = "kevin" ]; then
  person_id=xxx
elif [ "${name}" = "tim" ]; then
  person_id=xxx
else
  echo "Please let me know ${name}'s id (https://basecamp.com/${account_id}/people)"
  exit 1
fi


payload=""
payload="${payload}{"
payload="${payload}  \"content\": \"${content}\","
if [ "${due_at}" != "0000-00-00" ]; then
  payload="${payload}  \"due_at\": \"${due_at}\","
fi
payload="${payload}  \"assignee\": {"
payload="${payload}    \"id\": ${person_id},"
payload="${payload}    \"type\": \"Person\""
payload="${payload}  }"
payload="${payload}}"

# Add
curl \
  --silent \
  --user "${BASECAMP_USERNAME}:${BASECAMP_PASSWORD}" \
  --header "Content-Type: application/json" \
  --header "User-Agent: Transloadit Basecamp Client (support@transloadit.com)" \
  --request "POST" \
  --data "${payload}" \
https://basecamp.com/${account_id}/api/v1/projects/${project_id}/todolists/${todolist_id}/todos.json \
  |./JSON.sh -b |egrep '\["todos","remaining",\d+,"content"\]'


# Index
curl \
  --silent \
  --user "${BASECAMP_USERNAME}:${BASECAMP_PASSWORD}" \
  --header "Content-Type: application/json" \
  --header "User-Agent: Transloadit Basecamp Client (support@transloadit.com)" \
  --request "GET" \
https://basecamp.com/${account_id}/api/v1/projects/${project_id}/todolists/${todolist_id}.json \
  |./JSON.sh -b |egrep '\["todos","remaining",\d+,"content"\]'
