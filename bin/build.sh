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

add_links() {
    sed -E 's~ (http(s)://[^ ]+)~ <a href="\1">\1</a>~g'
}

update_donations() {
    local feed
    feed=$(cat <&0)

    local donated
    donated=$(echo "$feed" \
        | awk '/[0-9]+ EUR$/ { sum+=$(NF-1);  } END { print sum  }')

    local target
    target=$(echo "$feed" \
        | grep -E "\* target.+[0-9]+" \
        | grep -Eo "[0-9]+"
        )

    local status
    status=$(($donated-$target))

    echo "$feed" \
        | sed -E "s~( donated[^0-9]+)([0-9]+)~\1$donated~" \
        | sed -E "s~( status[^-0-9]+)(-?[0-9]+)~\1$status~"
}


main() {
    add_links | add_pr_links | add_user_links | build_html | update_donations
}

main "$@"
