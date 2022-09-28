#!/bin/sh

. $(dirname $0)/functions
. ${_dbc_root}/internal/common

test_dbc_logline(){
    local output

    # test echoing one line to user and logfile
    output=$(dbc_logline foo 2>&1 >/dev/null)
    assertTrue "dbc_logline foo returned error" $?
    assertEquals foo. "$output"
    assertFilesEqual $_dbc_logfile ./data/dbc_logline.simple.txt

    # test that a second line is logged appropriately
    dbc_logline bar >/dev/null 2>&1
    assertFilesEqual $_dbc_logfile ./data/dbc_logline.twolines.txt

    # test that multiple arguments are logged appropriately
    cat /dev/null > $_dbc_logfile
    output=$(dbc_logline foo bar 2>&1 >/dev/null)
    assertTrue "dbc_logline foo bar returned error" $?
    assertEquals "foo bar." "$output"
    assertFilesEqual $_dbc_logfile ./data/dbc_logline.twowords.txt

    # assure that quoting and escaping are handled properly
    output=$(dbc_logline "\"foobar's\ttab\"" 2>&1 >/dev/null)
    assertTrue "dbc_logline (with escaping) returned error" $?
    assertEquals "\"foobar's	tab\"." "$output"
}

test_dbc_logpart(){
    # make sure it properly logs partial lines
    dbc_logpart foo >/dev/null 2>&1
    assertTrue "dbc_logpart foo returned error" $?
    assertFilesEqual $_dbc_logfile ./data/dbc_logpart.noeol.txt

    # ...and that it completes them with the next logline.
    dbc_logline bar >/dev/null 2>&1
    assertFilesEqual $_dbc_logfile ./data/dbc_logline.twowords.txt
}

test_dbc_debug(){
    local olddebug
    if [ "${dbc_debug:-}" ]; then olddebug=$dbc_debug; else olddebug=""; fi

    # make sure it doesn't do anything by default
    dbc_debug=""
    _dbc_debug foo bar >/dev/null 2>&1
    assertTrue "_dbc_debug foo bar returned error" $?
    assertFilesEqual $_dbc_logfile /dev/null

    # ...and that it completes them with the next logline.
    dbc_debug=1
    _dbc_debug foo bar >/dev/null 2>&1
    assertTrue "_dbc_debug foo bar returned error" $?
    assertFilesEqual $_dbc_logfile ./data/dbc_logline.twowords.txt

    dbc_debug=$olddebug
}

test_dbc_mktemp(){
    local t
    # try making a temp file w/out arguments
    t=$(dbc_mktemp)
    assertTrue "dbc_mktemp (no args) failed" $?
    assertTrue "dbc_mktemp (no args) file $t nonexistant" '[ -f "$t" ]'
    assertTrue "dbc_mktemp (no args) file $t nonempty" '[ ! -s "$t" ]'
    rm -f "$t"

    # try making a temp file with arguments
    t=$(dbc_mktemp foo.XXXXXX)
    assertTrue "dbc_mktemp (no args) failed" $?
    assertTrue "dbc_mktemp (no args) file $t nonexistant" '[ -f "$t" ]'
    assertTrue "dbc_mktemp (no args) file $t nonempty" '[ ! -s "$t" ]'
    rm -f "$t"
}

. /usr/share/shunit2/shunit2
