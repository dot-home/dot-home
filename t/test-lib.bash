load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

#
# You must be sure to call `test_lib_setup` if you override setup().
#
setup() { test_lib_setup; }

test_lib_setup() {
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

setup_test_suite_home() {
    test_home="$test_scratch_dir/home"
    mkdir -p "$test_scratch_dir"
    cp -R "$test_suite_path.home" "$test_home"
}
