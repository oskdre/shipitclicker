#!/usr/bin/env bash
set -euo pipefail

# Podziękowania dla https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEST_DIR="$DIR/../src/test/k6"

${DEBUG:-false} && set -vx
# Podziękowania dla  https://stackoverflow.com/a/17805088
# i http://wiki.bash-hackers.org/scripting/debuggingtips
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

TARGET=${1:?$0: Parametr docelowego adresu URL jest wymagany.}
USERS=${USERS:-1}   # Liczba jednoczesnych użytkowników wirtualnych do symulacji.
DURATION=${DURATION:-60}  # Liczba sekund.
MOVES=${MOVES:-200} # Liczba ruchów / kliknięć do symulacji na wirtualnego użytkownika.
STAGES=${STAGES:-""}

if [ "STAGES" == "" ]; then
    TYPE="SOAK"
    ARG_DURATION="--duration ${DURATION}s"
    ARG_STAGE=""
else
    TYPE="STRESS"
    DURATION=""
    ARG_DURATION=""
    ARG_STAGE="--stage $STAGES"
fi

cat <<EOF
*** Starting k6.io
Target         : $TARGET
Test Type      : $TYPE
Virtual Users  : $USERS
Moves per Game : $MOVES
Total duration : $DURATION seconds
EOF

# shellcheck disable=SC2086
docker run \
       --rm \
       -i \
       --name k6 \
       -eDEBUG="${DEBUG:-}" \
       -eTARGET="$TARGET" \
       -eK6_STAGES="$STAGES" \
       -eMOVES="$MOVES" \
       loadimpact/k6 \
       run \
       --vus "$USERS" \
       $ARG_DURATION \
       $ARG_STAGE    \
       - \
       < "$TEST_DIR/test.js"
