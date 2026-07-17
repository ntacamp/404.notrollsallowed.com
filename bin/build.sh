#!/bin/bash

set -euo pipefail

readonly PROJECT_URL="https://github.com/ntacamp/404.notrollsallowed.com"

build_html() {
    readonly placeholder="_CONTENT_"
    readonly template_file="bin/index.tpl"

    # Print content until placeholder.
    sed "/${placeholder}/Q" "$template_file"
    # Print stdin content.
    echo "$(</dev/stdin)"
    # Print content after placeholder.
    sed -e "1,/${placeholder}/ d" < "$template_file"
}

add_pr_links() {
    sed -E "s~([[:space:]]+)PR([0-9]+)~\1<a href=\"${PROJECT_URL}/pull/\2\">PR\2</a>~g"
}

add_user_links() {
    sed -E 's~@([-_a-zA-Z0-9]+)~<a href="https://github.com/\1">@\1</a>~g'
}

add_links() {
    sed -E 's~ (http(s)://[^ ]+)~ <a href="\1">\1</a>~g'
}

add_footnote_links() {
    local content
    content=$(cat)

    local subs=""
    while IFS= read -r line; do
        if [[ "$line" =~ \[([0-9]+)\][[:space:]]+(https?://[^[:space:]]+) ]]; then
            local ref="${BASH_REMATCH[1]}"
            local url="${BASH_REMATCH[2]}"
            subs+="s~\[${ref}\]~<a href=\"${url}\">[${ref}]</a>~g;"
        fi
    done <<< "$content"

    [[ -z "$subs" ]] && { echo "$content"; return; }

    echo "$content" \
        | sed -E "/^[[:space:]]*\[[0-9]+\][[:space:]]/! { ${subs} }"
}

main() {
    add_footnote_links | add_links | add_pr_links | add_user_links | build_html
}

main "$@"
