#!/bin/sh

: 'Setup' && {
	current_dir="$(
		d=${0%/*}/
		[ "_${d}" = "_${0}/" ] && d='./'
		# shellcheck disable=SC2164
		cd "${d}"
		pwd
	)"
}

: 'Execute' && {
	node "${current_dir}/count-token.js" "$@"
}
