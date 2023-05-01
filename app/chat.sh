#!/bin/sh
set -u

usage () {
	this_script="$0"
	cat <<-EOF
		Usage:
		  # Start new conversation
		  ${this_script} -n \${path_of_message_file}
		
		  # Continue last conversation
		  ${this_script} \${path_of_message_file}
	EOF
}

error_exit()
{
	printf "%s\n" "[ERROR] $*" >&2
	exit 1
}

: 'Setup' && {
	current_dir="$(
		d=${0%/*}/
		[ "_${d}" = "_${0}/" ] && d='./'
		# shellcheck disable=SC2164
		cd "${d}"
		pwd
	)"

	: 'Import API key' && {
		[ ! -f "${current_dir}/config/api_key" ] && error_exit "${current_dir}/config/api_key is required."
		. "${current_dir}/config/api_key"
	}
	[ ! -d "${current_dir}/log" ] && error_exit "Directory ${current_dir}/log is required."
	[ ! -f "${current_dir}/config/base_input" ] && error_exit "File ${current_dir}/config/base_input is required."
	LFs=$(printf '\\\n_');LFs=${LFs%_}
	FF=$(printf '\f')
}

: 'Get arguments' && {
	# Argument is required
	if [ $# -eq 0 ]; then
		usage 
		exit 1
	fi
	: 'Set message log' && {
		if [ "$1" = '-n' ]; then
			message_log="${current_dir}/log/message_log_$(date +%s).jsonnet"
			shift
		else
			message_log=$(
				find "${current_dir}/log" -type f |
				sort -nr |
				grep "^${current_dir}/log/message_log_[0-9][0-9]*.jsonnet$" |
				awk 'NR==1'
			)
			[ "_${message_log}" = '_' ] && {
				message_log="${current_dir}/log/message_log_$(date +%s).jsonnet"
			}
		fi
	}

	next_message="$1"
	base_input="${current_dir}/config/base_input"
}

: 'Main' && {
	: 'Create next request' && {
		request=$(mktemp)

		: 'Add next message' && {
			cat "${next_message}" |
			# JSON用に特殊文字のエスケープ
			# バックスラッシュ(\) : \\
			sed 's/\\/\\\\/g' |
			# ダブルクォーテーション(") : \"
			sed 's/"/\\"/g' |
			# タブ文字(\t) : \\t
			sed 's/\t/\\t/g' |
			# スラッシュ(/) : \\/
			sed 's;/;\\/;g' |
			# 復帰文字(\r) : \\r
			sed 's/\r/\\r/g' |
			# バックスペース(\b) : \\b
			sed 's/\x08/\\b/g' |
			# フォームフィード(\f) : \\f
			sed "s/$FF/\\f/g" |
			# 改行文字(\n) : \\n
			sed 's/$/\\n/' |
			tr -d '\n' |
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

	: 'Error' && {
		finish_reason=$(cat "$response" | jq -r '.choices[0].finish_reason')

		if [ "$finish_reason" = "content_filter" ]; then
			response_content="$(cat "$response")"
			error_exit "Omitted content due to a flag from content filters" "API Response: ${response_content}"
		elif [ "$finish_reason" = "null" ]; then
			response_content="$(cat "$response")"
			error_exit "API response still in progress or incomplete" "API Response: ${response_content}"
		fi

		if [ "$finish_reason" != "stop" ]; then
			response_content="$(cat "$response")"
			error_exit "Unknown finish_reason" "API Response: ${response_content}"
		fi
	}

	: 'Extract response message' && {
		jq -c '.choices[0].message' "${response}" |
		sed 's/^/'"$LFs"'/' |
		tee -a "${message_log}" |
		jq -r '.content'
	}
}
