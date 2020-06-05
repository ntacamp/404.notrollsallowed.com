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


main() {
    update_donations
}

main "$@"
