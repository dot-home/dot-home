load 'test-lib'

@test "symlinker" {
    setup_test_home
    HOME="$test_home" run "$BATS_TEST_DIRNAME/../bin/dot-home-setup"

    local expected="$test_scratch_dir/home.expected"
    sed -e '/^#/d' "$BATS_TEST_DIRNAME/100-symlinker.expected" >"$expected"

    local actual="$test_scratch_dir/home.actual"
    (cd $test_home && find . \
               -type l  -exec bash -c 'echo -n {} "-> "; readlink "{}"' \; \
            -o -type d \! -empty -true \
            -o          -print \
        | sed -e 's,^\./,,' | sort >"$actual")

    local diff_ok=true; diff -u "$expected" "$actual" || diff_ok=false
    assert_output <<____
.home WARNING: Conflict: .home/b/bin/a hello world/
.home WARNING: Conflict: .home/b/bin/a hello world/.keep
.home WARNING: Conflict: .home/b/bin/in-home conflict
.home WARNING: Conflict: .home/b/bin/out-home conflict
____
    assert $diff_ok
}

@test "set_dest_target" {
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dot-home-setup" --define-functions-only

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
