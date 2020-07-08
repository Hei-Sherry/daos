#!/bin/bash

function print_header {
  echo
  printf '%80s\n' | tr ' ' =
  echo "          ${1}"
  printf '%80s\n' | tr ' ' =
  echo
}

TEST_DIR=$(mktemp -d)
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function check_retcode(){
  exit_code=${1}
  last_command=${2}

  rm -rf "${TEST_DIR}"

  if [[ ${exit_code} -eq 0 ]] ; then
    exit 0
  fi

  echo "${last_command} command filled with exit code ${exit_code}."
  exit "${exit_code}"
}
trap 'check_retcode $? ${BASH_COMMAND}' EXIT

set -e


print_header "Unit Testing"

python -m pytest -v "${CURRENT_DIR}"


VOS_SIZE="${TEST_DIR}/vos_size_test.yaml"
DFS_SAMPLE="${TEST_DIR}/vos_dfs_sample_test.yaml"

vos_scm_estimator.py -h

vos_scm_estimator.py -h


print_header "SCM Estimator"

vos_scm_estimator.py -h


print_header "create_example"

vos_scm_estimator.py create_example -h
vos_scm_estimator.py create_example -v -m "${VOS_SIZE}" -f "${DFS_SAMPLE}"
diff "${VOS_SIZE}" "${CURRENT_DIR}/vos_size.yaml"


print_header "read_csv"

CLIENT_CSV="${CURRENT_DIR}/test_data.csv"
CLIENT_YAML="${TEST_DIR}/test_data.yaml"

vos_scm_estimator.py read_csv -h
vos_scm_estimator.py read_csv -v "${CLIENT_CSV}" -o "${CLIENT_YAML}"
vos_scm_estimator.py read_yaml -v "${CLIENT_YAML}"

print_header "read_yaml"

vos_scm_estimator.py read_yaml -h
vos_scm_estimator.py create_example -m "${VOS_SIZE}" -f "${DFS_SAMPLE}"
vos_scm_estimator.py read_yaml -v "${DFS_SAMPLE}"
vos_scm_estimator.py read_yaml -v -m "${VOS_SIZE}" "${DFS_SAMPLE}"


print_header "explore_fs"

FS_YAML="${TEST_DIR}/test_fs_data.yaml"

vos_scm_estimator.py explore_fs -h
vos_scm_estimator.py explore_fs -v "${TEST_DIR}"
vos_scm_estimator.py explore_fs -v -m "${VOS_SIZE}" "${TEST_DIR}"
vos_scm_estimator.py explore_fs -v "${TEST_DIR}" -o "${FS_YAML}"
vos_scm_estimator.py read_yaml "${FS_YAML}"
vos_scm_estimator.py explore_fs -v -x "${TEST_DIR}"
vos_scm_estimator.py explore_fs -v -x -m "${VOS_SIZE}" "${TEST_DIR}"
vos_scm_estimator.py explore_fs -v -x "${TEST_DIR}" -o "${FS_YAML}"
vos_scm_estimator.py read_yaml "${FS_YAML}"


print_header "Successful"
