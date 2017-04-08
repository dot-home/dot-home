load 'test-lib'

setup() {
    test_lib_setup
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dot-home-setup" --define-functions-only
}

@test "warn" {
    # Cannot use run because it combines stdout and stderr
    output=$(warn "world will end" 2>&1 >/dev/null)
    assert_output '.home WARNING: world will end'
}

@test "set_dest_target" {
    local src dest target

    set_dest_target           'a/bin'
    assert_equal    "$dest"     'bin'
    assert_equal    "$target"   '.home/a/bin'

    set_dest_target           'a/bin/file'
    assert_equal    "$dest"     'bin/file'
    assert_equal    "$target"   '../.home/a/bin/file'

    set_dest_target         'a b/bin/dir/sub dir/sub file'
    assert_equal    "$dest"     'bin/dir/sub dir/sub file'
    assert_equal    "$target"   '../../../.home/a b/bin/dir/sub dir/sub file'

    set_dest_target         'a/dot/file'
    assert_equal    "$dest"     '.file'
    assert_equal    "$target"   '.home/a/dot/file'

    set_dest_target         'a/dot/b/c/d/file'
    assert_equal    "$dest"     '.b/c/d/file'
    assert_equal    "$target"   '../../../.home/a/dot/b/c/d/file'
}
