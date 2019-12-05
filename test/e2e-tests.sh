#!/usr/bin/env bash

# shellcheck disable=SC1091,SC1090
source "$(dirname "${BASH_SOURCE[0]}")/lib.bash"

set -Eeuo pipefail

register_teardown || exit $?
scale_up_workers || exit $?
create_namespaces || exit $?
create_htpasswd_users && add_roles || exit $?

failed=0

(( !failed )) && install_service_mesh_operator || failed=2
(( !failed )) && install_catalogsource || failed=3
(( !failed )) && logger.success 'Cluster prepared for testing.'

# Run serverless-operator specific tests.
(( !failed )) && run_e2e_tests || failed=4

# Run upstream knative serving tests
RUN_KNATIVE_SERVING_UPGRADE_TESTS=false
RUN_KNATIVE_SERVING_E2E=true

(( !failed )) && ensure_serverless_installed || failed=5
(( !failed )) && run_knative_serving_tests "v0.10.0" || failed=6
(( !failed )) && teardown_serverless || failed=7

(( failed )) && dump_state
(( failed )) && exit $failed

success
