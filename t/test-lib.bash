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

    test_home="$test_scratch_dir/home"
}

# A specification may have leading spaces, trailing spaces, blank
# lines and comments (either at the beginning of a line or preceeded
# by at least one space). All these are removed. We match spaces only,
# and not general "whitespace", for simplicity.
#
trim_spec() {
    sed 's/^ *//;               # Remove leading spaces
         s/^#.*//;              # Remove comments at beginning of line
         s/ * #.*//;            # Remove space-lead comments in line
         /^$/d;                 # Remove empty lines
         '
}

create_test_home_with_test_suite_data() {
    mkdir -p "$test_scratch_dir"
    cp -R "$test_suite_path.home" "$test_home"
}

create_test_home() {
    mkdir -p "$test_home"
    home_expected="$test_scratch_dir/home.expected"

    local path target
    while read path; do
        # Short-cut to include "non-build/install" .home files in expected
        # output so we don't have to do so manually in the expected output
        # in the tests.
        [[ "$path" =~ ^.home/[A-Za-z0-9] ]] && echo "$path" >> "$home_expected"

        if [[ "$path" =~ ' -> ' ]]; then
            target="${path##* -> }"
            path="${path%% -> *}"
        fi

        local abs_path="$test_home/$path"
        mkdir -p "$(dirname "$abs_path")"

        if [ -n "$target" ]; then
            ln -s "$target" "$abs_path"
        else
            echo "Content of $path" > "$abs_path"
        fi
    done < <(trim_spec)
}

run_setup_on_test_home() {
    HOME="$test_home" run "$base_dir/bin/dot-home-setup" "$@"
}

assert_success_and_diff_test_home_with() {
    assert_success
    diff_test_home_with "$@"
}

diff_test_home_with() {
    local home_actual="$test_scratch_dir/home.actual"
    (cd $test_home && find . \
               -type l  -exec bash -c 'echo -n {} "-> "; readlink "{}"' \; \
            -o -type d \! -empty -true \
            -o          -print \
        | sed -e 's,^\./,,' | sort >"$home_actual")

    trim_spec >> "$home_expected"
    sort -o "$home_expected" "$home_expected"

    test_home_diffed_ok=true
    diff --suppress-common-lines -u \
        --label expected "$home_expected" \
        --label actual "$home_actual" || test_home_diffed_ok=false
}

# We separate the diff and the assertion so that we can display the
# diff without (yet) failing, so that other assertions can also
# display their results.
#
assert_test_home() {
    $test_home_diffed_ok
}

assert_function() {
    [ -n "$1" ] || fail "assert_function: missing function name"
    local fut="$1"; shift   # function under test
    [ -z "$1" ] || fail "assert_function: too many parameters"

    local failures=0

    while read spec; do
        [[ "$spec" =~ (.*)⇒\ *(.*) ]]
        local expected="${BASH_REMATCH[2]}"
        local param_spec="${BASH_REMATCH[1]}"
        local oldifs="$IFS"; IFS='∙'
        read -a params \
            < <(echo "${param_spec}∙" | sed -e 's/ *∙ */∙/g' -e 's/ *$//')
        IFS="$oldifs"

        local actual="$($fut "${params[@]}" < /dev/null)"
        [ "$expected" = "$actual" ] || {
            failures=$(($failures+1))
            [ $failures -eq 1 ] \
                && echo >&2 "-- assert_function '$fut' failure(s) --"
            echo >&2 "spec   : $spec"
            echo >&2 "actual : $actual"
        }
    done < <(trim_spec)

    [ $failures -eq 0 ] || {
        echo >&2 '--'
        fail "$failures specifications failed"
    }
}
