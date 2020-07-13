#!/bin/bash

set -euo pipefail

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
    author=$(echo "$line" \
        | sed -E 's/.+\.{2,}//' \
        | awk '{ print $0 }' \
        | awk '{ $1 = $1; print $0 }' \
    )

    local topic
    topic=$(echo "$line" \
        | sed -E 's/\.{2,}.+//' \
        | awk '{ $1 = ""; print $0 }' \
        | awk '{ $1 = $1; print $0 }' \
    )

    local page_width=80
    local pr_width=7
    awk \
        -v pr="$pr" \
        -v author="$author" \
        -v topic="$topic" \
        -v page_width="$page_width" \
        -v pr_width="$pr_width" \
        'BEGIN {
            len_author=length(author)
            len_topic=length(topic)
            content_width=page_width-pr_width
            if (len_topic + len_author > content_width) {
                len_topic=content_width-len_author-3
                topic=substr(topic, 1, len_topic)
            }
            printf "  %-4s %s ", pr, topic
            for (i = 0; i < content_width-len_author-len_topic-2; i++) {
                printf "."
            }
            printf " %s\n", author
        }'
}

main() {
    update_donations | justify_text
}

main "$@"
