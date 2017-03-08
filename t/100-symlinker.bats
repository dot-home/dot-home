load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    test_suite_name="$(basename "$BATS_TEST_FILENAME" .bats)"
    test_suite_path="$BATS_TEST_DIRNAME/$test_suite_name"
    test_name="${BATS_TEST_NAME//test_/}"       # Still has other Bats changes
    test_scratch_dir="$build_t_dir/$test_suite_name/$test_name"

    # Tests must create $test_scratch_dir if they want it.
    # We assert it's not there to avoid collisions between tests.
    [ ! -d "$test_scratch_dir" ] || {
        echo >&2 "test_scratch_dir collision: ${test_scratch_dir/$base_dir?}"
        false
    }
}

setup_test_home() {
    test_home="$test_scratch_dir/home"
    mkdir -p "$test_scratch_dir"
    cp -r "$test_suite_path.home" "$test_home"
}

@test "symlinker" {
    setup_test_home
    HOME="$test_home" run "$BATS_TEST_DIRNAME/../bin/dot-home-setup"

    local expected="$test_scratch_dir/home.expected"
    sed -e '/^#/d' "$BATS_TEST_DIRNAME/100-symlinker.expected" >"$expected"

    local actual="$test_scratch_dir/home.actual"
    (cd $test_home && find . \
               -type l  -exec bash -c 'echo -n {} "-> "; readlink "{}"' \; \
            -o -type d  -true  \
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
