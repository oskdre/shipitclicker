#!/usr/bin/env bash
set -euo pipefail

# Podziękowania dla https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEST_DIR="$DIR/../src/test/k6"

${DEBUG:-false} && set -vx
# Podziękowania dla https://stackoverflow.com/a/17805088
# i http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

USERS=${USERS:-1}   # Liczba jednoczesnych użytkowników wirtualnych do symulacji.
DURATION=${DURATION:-60}  # Liczba sekund.

if [ "STAGES" == "" ]; then
    TYPE="SOAK"
else
    TYPE="STRESS"
fi

cat <<EOF
*** Starting k6.io
Virtual Users  : $USERS
Total duration : $DURATION seconds
EOF

docker run \
    --rm \
    -i \
    --name k6-har \
    loadimpact/k6 \
    run \
    --vus "$USERS" \
    --duration "$DURATION"s \
    - \
    < "$TEST_DIR/har-session.js"
