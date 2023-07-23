#!/bin/bash

set -euo pipefail

update_donations() {
    local feed
    feed=$(cat <&0)

    local donated
    donated=$(echo "$feed" \
        | awk '/[0-9]+(\.[0-9]+)? EUR$/ { sum+=$(NF-1);  } END { print sum  }')

    local target
    target=$(echo "$feed" \
        | awk '/\* target.*([0-9]+)/ {print $4}' | tr -d €)

    local status
    status=$(echo "$donated-$target" | bc)

    echo "$feed" \
        | sed -E "s~( donated[^0-9]+)([0-9]+)~\1$donated~" \
        | sed -E "s~( status[^-0-9]+)(-?[0-9]+)~\1$status~"
}

justify_text() {
    local topic_pattern="^[[:blank:]]+PR[[:digit:]]+ "
    while IFS='$\n' read -r line; do
        if [[ "$line" =~ $topic_pattern ]]; then
            format_topic "$line"
        else
            echo "$line"
        fi
    done
}

format_topic() {
    local line=$1

    local pr
    pr=$(echo "$line" \
        | grep -E "PR[[:digit:]]+" -o \
        | head -1)

    local author
    author=$(get_author "$line")

    local topic
    topic=$(get_topic "$line" "$author")

    local page_width=80
    local pr_width=8
    local len_author
    len_author=${#author}
    local len_topic
    len_topic=${#topic}
    awk \
        -v pr="$pr" \
        -v author="$author" \
        -v topic="$topic" \
        -v page_width="$page_width" \
        -v pr_width="$pr_width" \
        -v len_author="$len_author" \
        -v len_topic="$len_topic" \
        'BEGIN {
            content_width=page_width-pr_width
            if (len_topic + len_author >= content_width) {
                len_topic=content_width-len_author-1
                topic=sprintf("%s…", substr(topic, 1, len_topic-1))
            }
            printf "  %-5s %s ", pr, topic
            for (i = 0; i < content_width-len_author-len_topic-2; i++) {
                printf "."
            }
            printf " %s\n", author
        }'
}

get_author() {
    local line=$1
    local author
    author=$(echo "$line" | \
        grep -Eo "\@[-_a-zA-Z0-9]+$"
    )
    if [[ -z "$author" ]]; then
        author=$(
            echo "$line" \
                | sed -E 's/.+\.{2,}//' \
                | awk '{ print $0 }' \
                | awk '{ $1 = $1; print $0 }'
        )
    fi

    echo "$author"
}

get_topic() {
    local line=$1
    local author=$2
    local topic
    topic=$(echo "$line" \
        | sed -E "s%${author}$%%" \
        | sed -E "s/[ \. ]+$//" \
        | awk '{ $1 = ""; print $0 }' \
        | awk '{ $1 = $1; print $0 }' \
    )
    echo "$topic"
}

main() {
    update_donations | justify_text
}

main "$@"
