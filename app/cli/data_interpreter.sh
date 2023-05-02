#!/bin/sh

: 'Setup' && {
	current_dir="$(
		d=${0%/*}/
		[ "_${d}" = "_${0}/" ] && d='./'
		# shellcheck disable=SC2164
		cd "${d}"
		pwd
	)"

	: 'Create prompt file' && {
		tmp_message=$(mktemp)
		echo "$1" > "${tmp_message}"
		echo '```' >> "${tmp_message}"
		cat - >> "${tmp_message}"
	}
}

: 'Execute' && {
	echo '####' >&2
	echo "Prompt: ${tmp_message}" >&2
	echo '####' >&2

	"${current_dir}/../chat.sh" -n "${tmp_message}"
}
