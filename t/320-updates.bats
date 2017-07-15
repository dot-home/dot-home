load 'test-lib'

setup() {
    test_lib_setup
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dh" --define-functions-only
}

# Notes on first update pass; these need to move elsewhere:
# 1. Update everything that's present
#       a) execute dh/update if it exists, otherwise
#       b) loop through update-tryers until one succeeds

@test 'no updater' {
    run find_updater_for "$base_dir/bin"
    assert_output ''
}

@test 'dh/update updater' {
    local module="$test_home/.home/module"

    mkdir -p "$module/dh"
    touch "$module/dh/update"
    chmod +x "$module/dh/update"
    run find_updater_for "$module"

    assert_output "dh/update"
}

build_test_repo() {
    local module="$1"
    mkdir -p "$module"
    (   cd "$module"
        git init
        git config --local user.email 'test@dot-home'
        git config --local user.name 'test'
        echo stuff > foo
        git add foo
        git commit -m 'a commit' foo
    )
}

@test 'git updater without upstream' {
    local module="$test_home/module"
    build_test_repo "$module"
    run find_updater_for "$module"
    assert_output ''
}

@test 'git updater with upstream' {
    local module="$test_home/module"
    build_test_repo "$module"
    (   cd "$module"
        git checkout -b newbranch --track
    )
    run find_updater_for "$module"
    #(cd "$module" && git status)
    assert_output 'git pull'
}
