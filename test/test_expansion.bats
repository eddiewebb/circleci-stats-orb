#!/usr/bin/env bats

# load custom assertions and functions
load bats_helper


# setup is run beofre each test
function setup {
  INPUT_PROJECT_CONFIG=${BATS_TMPDIR}/input_config-${BATS_TEST_NUMBER}
  PROCESSED_PROJECT_CONFIG=${BATS_TMPDIR}/packed_config-${BATS_TEST_NUMBER} 
  JSON_PROJECT_CONFIG=${BATS_TMPDIR}/json_config-${BATS_TEST_NUMBER} 
	echo "#using temp file ${BATS_TMPDIR}/"

  # the name used in example config files.
  INLINE_ORB_NAME="stats"
}


@test "Command: full job expands properly " {
  # given
  process_config_with test/inputs/simple.yml

  # when
  assert_jq_match '.jobs | length' 1
  assert_jq_match '.jobs["stats/with_stats"].steps | length' 6
  assert_jq_match '.jobs["stats/with_stats"].steps[0]' 'checkout'
  assert_jq_match '.jobs["stats/with_stats"].steps[1].run.background' 'true'
  assert_jq_match '.jobs["stats/with_stats"].steps[2].run.command' 'sudo apt-get update && sudo apt-get install -y stress'
  assert_jq_match '.jobs["stats/with_stats"].steps[3].run.command' 'stress --vm 4 --timeout 30'
}









