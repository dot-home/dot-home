load 'test-lib'

setup() {
    test_lib_setup
    source bin/dot-home-setup --define-functions-only
}

assert_run_inb4check_pass_stderr() {
    pushd "$test_home/.home" >/dev/null
    run_inb4check_pass >$test_scratch_dir/stdout 2>$test_scratch_dir/stderr
    assert_equal "$(cat $test_scratch_dir/stdout)" ''
    assert_equal "$(cat $test_scratch_dir/stderr)" "$1"
    popd >/dev/null
}

@test "inb4check: ∄ installed ⇒ build it" {
    create_test_home <<.
        .home/A/dot/one.inb4        # source
        .home/,inb4/dot/one         # built
      # .home/_inb4/dot/one         # missing installed
        .home/A/dot/two.inb4        # ensure we return array
        .home/,inb4/two
.
    assert_run_inb4check_pass_stderr
    assert_equal "${#inb4_outputs[@]}"  2
    assert_equal "${inb4_outputs[0]}"   dot/one
    assert_equal "${inb4_outputs[1]}"   dot/two
}

@test "inb4check: built = installed ⇒ build it" {
    create_test_home <<.
        .home/A/dot/one.inb4        # source
        .home/,inb4/dot/one         # built
        .home/_inb4/dot/one         # installed
.
    (cd "$test_home/.home" \
        && echo "Same-old same-old." > ,inb4/dot/one \
        && echo "Same-old same-old." > _inb4/dot/one \
    )

    assert_run_inb4check_pass_stderr
    assert_equal "${#inb4_outputs[@]}"  1
    assert_equal "${inb4_outputs[0]}"   dot/one
}

@test "inb4check: built ≠ installed ⇒ complain" {
    create_test_home <<.
        .home/A/dot/one.inb4        # source
        .home/,inb4/dot/one         # built
        .home/_inb4/dot/one         # installed
.
    (cd "$test_home/.home" \
        && echo "Something old and borrowed." > ,inb4/dot/one \
        && echo "Something new and blue."     > _inb4/dot/one \
    )

    assert_run_inb4check_pass_stderr \
        '.home WARNING: dot/one has been changed from version built by inb4'
    assert_equal "${#inb4_outputs[@]}"  0
}

@test "inb4check: ∄ built ⇒ complain" {
    create_test_home <<.
        .home/A/dot/one.inb4        # source
      # .home/,inb4/dot/one         # missing built
        .home/_inb4/dot/one         # installed
.
    assert_run_inb4check_pass_stderr \
        '.home WARNING: dot/one has no previously built version to check'
    assert_equal "${#inb4_outputs[@]}"  0
}
