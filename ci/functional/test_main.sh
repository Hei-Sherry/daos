#!/bin/bash

test_tag=$(git show -s --format=%%B | sed -ne "/^Test-tag%s:/s/^.*: *//p")
if [ -z "$test_tag" ]; then
    # shellcheck disable=SC2153
    test_tag=$TEST_TAG
fi

tnodes=$(echo $NODELIST | cut -d ',' -f 1-%d)
first_node=${NODELIST%%,*}

clush -B -S -o '-i ci_key' -l root -w "${first_node}" \
    "NODELIST=${NODELIST} ci/functional/setup_nfs.sh"

clush -B -S -o '-i ci_key' -l root -w "${tnodes}" \
  "OPERATIONS_EMAIL=${OPERATIONS_EMAIL} " +
  "FIRST_NODE=${first_node} " +
  "TEST_RPMS=${test_rpms} ci/functional/test_main_prep_nodes.sh"

trap 'clush -B -S -o "-i ci_key" -l root -w "${tnodes}" \
      "set -x; umount /mnt/share"' EXIT

# set DAOS_TARGET_OVERSUBSCRIBE env here
export DAOS_TARGET_OVERSUBSCRIBE=1
rm -rf install/lib/daos/TESTING/ftest/avocado ./*_results.xml
mkdir -p install/lib/daos/TESTING/ftest/avocado/job-results
ftest_arg="$FTEST_ARG"
if $TEST_RPMS; then
    ssh -i ci_key -l jenkins "${first_node}" \
      "TEST_TAG=$test_tag " +
      "TNODES=$tnodes " +
      "FTEST_ARG=$ftest_arg ci/functional/test_main_node.sh"
    # now collect up the logs and store them like non-RPM test does
    mkdir -p install/lib/daos/TESTING/
    # scp doesn't copy symlinks, it resolves them
    ssh -i ci_key -l jenkins "${first_node}" tar -C /var/tmp/ -czf - ftest | tar -C install/lib/daos/TESTING/ -xzf -
else
    ./ftest.sh "$test_tag" "$tnodes" "$ftest_arg"
fi