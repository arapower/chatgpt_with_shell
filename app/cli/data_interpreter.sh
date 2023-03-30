#!/bin/sh

tmp_message=$(mktemp)
echo "$1" > "${tmp_message}"
echo '```' >> "${tmp_message}"
cat - >> "${tmp_message}"

echo '####'
echo "Prompt: ${tmp_message}"
echo '####'

./chat.sh -n "${tmp_message}"
