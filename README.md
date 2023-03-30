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

## Data interpreter

```sh
$ aws iam list-users --output json | ./cli/data_interpreter.sh '以下のJSONの"UserName"が"this-is-target-user"のオブジェクトを抽出して。'
####
Prompt: /var/folders/5y/c4t_qkhs5m1f39rfv1hwjnhc0000gp/T/tmp.usJhZVXC
####
抽出されたオブジェクトは以下の通りです。

\```
{
    "Path": "/",
    "UserName": "this-is-target-user",
    "UserId": "AIDA4YL2BYZSUYNJ6ZYXO",
    "Arn": "arn:aws:iam::844584310928:user/this-is-target-user",
    "CreateDate": "2023-02-25T02:04:46+00:00"
}
\```
```

## Other features

- Logs conversations in JSON like format
  - `app/log/`
  - The log with the latest file name is used
  - Resume conversation based on previous log
  - The conversation log can be edited
- The "randomness" of ChatGPT's generated text can be specified with parameters (` temperature ` and ` top_p `)
  - `app/config/base_input`
