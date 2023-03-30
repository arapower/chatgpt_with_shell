#!/bin/sh
set -u

# Usage:
#   Start new conversation
#     ./chat.sh -n ${path_of_message_file}
#
#   Continue last conversation
#     ./chat.sh ${path_of_message_file}

error_exit()
{
	printf "%s\n" "[ERROR] $*" >&2
	exit 1
}

: 'Setup' && {
	: 'Import API key' && {
		[ ! -f ./config/api_key ] && error_exit './config/api_key is required.'
		. ./config/api_key
	}
	[ ! -d ./log ] && error_exit 'Directory ./log is required.'
	[ ! -f ./config/base_input ] && error_exit 'File ./config/base_input is required.'
	LFs=$(printf '\\\n_');LFs=${LFs%_}
}

: 'Get arguments' && {
	: 'Set message log' && {
		if [ "$1" = '-n' ]; then
			message_log="./log/message_log_$(date +%s).jsonnet"
			shift
		else
			message_log=$(
				find ./log -type f |
				sort -nr |
				grep '^\./log/message_log_[0-9][0-9]*.jsonnet$' |
				awk 'NR==1'
			)
			[ "_${message_log}" = '_' ] && {
				message_log="./log/message_log_$(date +%s).jsonnet"
			}
		fi
	}

	next_message="$1"
	base_input="./config/base_input"
}

: 'Main' && {
	: 'Create next request' && {
		request=$(mktemp)

		: 'Add next message' && {
			cat "${next_message}" |
			# 改行をエスケープ
			sed 's/$/\\n/' |
			tr -d '\n' |
			# JSON用に特殊文字のエスケープ
			sed 's/"/\\"/g' |
			sed 's/\t/\\t/g' |
			sed 's;/;\\/;g' |
			sed 's/\b/\\b/g' |
			sed 's/\f/\\f/g' |
			sed 's/\r/\\r/g' |
			# 余分な末尾改行を削除
			sed 's/\\n$//' |
			# JSON形式に変換
			sed 's/^/{"role": "user", "content": "/' |
			sed 's/$/"}/' >> "${message_log}"
		}
		: 'Request base' && {
			cat "${base_input}" |
			sed 's/,*$//' |
			sed 's/$/,/' |
			tr -d '\n' |
			sed 's/^/{/' > "${request}"
		}

		: 'Messages' && {
			cat "${message_log}" |
			sed 's/$/,/' |
			sed '$s/,$//' |
			tr -d '\n' |
			sed 's/^/"messages": [/' |
			sed 's/$/]/' |
			sed 's/$/}/' >> "${request}"
		}
	}

	: 'Request' && {
		response=$(mktemp)
		curl -s https://api.openai.com/v1/chat/completions \
			-H "Content-Type: application/json" \
			-H "Authorization: Bearer $OPENAI_API_KEY" \
			-d "@${request}" > "${response}"
	}

	: 'Extract response message' && {
		jq -c '.choices[0].message' "${response}" |
		sed 's/^/'"$LFs"'/' |
		tee -a "${message_log}" |
		jq -r '.content'
	}
}
