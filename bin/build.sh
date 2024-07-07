#!/bin/bash

set -euo pipefail

readonly PROJECT_URL="https://github.com/ntacamp/404.notrollsallowed.com"

build_html() {
    readonly replace_keyword="_CONTENT_"
    readonly template_file="bin/index.tpl"

    # Load stdin into variable.
    feed=$(cat <&0)
    template=$(cat < "$template_file")
    echo "${template/$replace_keyword/$feed}"
}

add_pr_links() {
    sed -E "s~([[:space:]]+)PR([0-9]+)~\1<a href=\"${PROJECT_URL}/pull/\2\">PR\2</a>~g"
}

add_user_links() {
    sed -E "s~@(\b.+\b)~<a href=\"https://github.com/\1\">@\1</a>~g"
}

add_links() {
    sed -E 's~ (http(s)://[^ ]+)~ <a href="\1">\1</a>~g'
}

main() {
    add_links | add_pr_links | add_user_links | build_html
}

main "$@"
