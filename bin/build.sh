#!/bin/bash

set -euo pipefail

readonly PROJECT_URL="https://github.com/ntacamp/404.notrollsallowed.com"

build_html() {
    sed '1s/^/\<pre\>\n/'
    echo '</pre>'
}

add_pr_links() {
    sed -E "s~([[:space:]]+)PR([0-9]+)~\1<a href=\"${PROJECT_URL}/pull/\2\">PR\2</a>~g"
}

add_user_links() {
    sed -E "s~@(\b.+\b)~<a href=\"https://github.com/\1\">@\1</a>~g"
}

add_markdown_links() {
    sed -r -e 's/(.*)\[(([[:alnum:]]|[[:space:]])+)\]\((http([[:alnum:]]|[[:punct:]])+)\)(.*)/\1<a href="\4" target="_blank">\2<\/a>\6/g'
}

add_links() {
    sed -E 's~ (http(s)://[^ ]+)~ <a href="\1">\1</a>~g'
}

main() {
    add_links | add_pr_links | add_user_links | add_markdown_links | build_html
}

main "$@"
