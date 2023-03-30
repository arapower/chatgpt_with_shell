# Run ChatGPT with shell script

This script is PoC.

## How to setup

```sh
# Set OpenAI API Key
$ echo "OPENAI_API_KEY='${YOUR_OPENAI_API_KEY}'" > ./app/config/api_key
```

### Required command

- `jq`: for handling JSON

## How to use

```sh
# Change current directory
$ cd ./app

# Content of message file
$ cat "${path_of_message_file}"
Output "Yes"

# Start conversation
$ ./chat.sh ${path_of_message_file}
Yes

# Edited message file
$ cat "${path_of_message_file}"
What's your previous output?

# Continue conversation
$ ./chat.sh ${path_of_message_file}
My previous output was "Yes".
```

```
# Start new conversation
$ ./chat.sh -n "${path_of_message_file}"
```

## Other features

- Logs conversations in JSON like format
  - `app/log/`
  - The log with the latest file name is used
  - Resume conversation based on previous log
  - The conversation log can be edited
- The "randomness" of ChatGPT's generated text can be specified with parameters (` temperature ` and ` top_p `)
  - `app/config/base_input`
