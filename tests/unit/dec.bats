#!/usr/bin/env bats

load '../lib/helper'
load '../bats/extensions/bats-support/load'
load '../bats/extensions/bats-assert/load'
load '../bats/extensions/bats-file/load'

@test "dec: helm dec" {
    run helm secrets dec
    assert_failure
    assert_output --partial 'Error: secrets file required.'
}

@test "dec: helm dec --help" {
    run helm secrets dec --help
    assert_success
    assert_output --partial 'Decrypt secrets'
}

@test "dec: File not exits" {
    run helm secrets dec nonexists
    assert_failure
    assert_output --partial 'File does not exist: nonexists'
}

@test "dec: Decrypt secrets.yaml" {
    run helm secrets dec "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_success
    assert_output "Decrypting ${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_file_exist "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.dec"

    run cat "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.dec"
    assert_success
    assert_output --partial 'global_secret: '
    assert_output --partial 'global_bar'
}

@test "dec: Decrypt secrets.yaml + special char directory name" {
    run helm secrets dec "${SPECIAL_CHAR_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_success
    assert_output "Decrypting ${SPECIAL_CHAR_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_file_exist "${SPECIAL_CHAR_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.dec"

    run cat "${SPECIAL_CHAR_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.dec"
    assert_success
    assert_output --partial 'global_secret: '
    assert_output --partial 'global_bar'
}

@test "dec: Decrypt secrets.yaml + HELM_SECRETS_DEC_SUFFIX" {
    HELM_SECRETS_DEC_SUFFIX=.yaml.test
    export HELM_SECRETS_DEC_SUFFIX

    run helm secrets dec "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_success
    assert_output "Decrypting ${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert [ -e "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.test" ]

    run cat "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml.test"
    assert_success
    assert_output --partial 'global_secret: '
    assert_output --partial 'global_bar'
}

@test "dec: Decrypt secrets.yaml + HELM_SECRETS_DEC_DIR" {
    HELM_SECRETS_DEC_DIR="$(mktemp -d)"
    export HELM_SECRETS_DEC_DIR

    run helm secrets dec "${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_success
    assert_output "Decrypting ${TEST_TEMP_DIR}/values/${HELM_SECRETS_DRIVER}/secrets.yaml"
    assert_file_exist "${HELM_SECRETS_DEC_DIR}/secrets.yaml.dec"

    run cat "${HELM_SECRETS_DEC_DIR}/secrets.yaml.dec"
    assert_success
    assert_output --partial 'global_secret: '
    assert_output --partial 'global_bar'
}
