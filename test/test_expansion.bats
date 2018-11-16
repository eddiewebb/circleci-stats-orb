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
  assert_jq_match '.jobs["stats/with_stats"].steps | length' 8
  assert_jq_match '.jobs["stats/with_stats"].steps[0]' 'checkout'
  assert_jq_match '.jobs["stats/with_stats"].steps[2].run.background' 'true'
  assert_jq_match '.jobs["stats/with_stats"].steps[3].run.command' 'sudo apt-get -y update && sudo apt-get -y install stress'
  assert_jq_match '.jobs["stats/with_stats"].steps[4].run.command' 'stress --vm 4 --timeout 30'
}


@test "Command: full job runs properly (needs docker/locl builds) " {
  # given
  process_config_with test/inputs/simple.yml

  # when
  cp ${PROCESSED_PROJECT_CONFIG} proc.yml
  run circleci build -c proc.yml --job stats/with_stats



  assert_contains_text 'Start background stats'
  assert_contains_text 'Stats Summary'
  assert_contains_text 'Stats Summary'
  assert_contains_text 'Success'
  
}









