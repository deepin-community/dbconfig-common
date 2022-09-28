#!/bin/sh

# get some common functions
. $(dirname "$0")/functions

test_mockup_retval(){
    local ret errone errtwo
    mockup -r 1 huh
    errone=$mockup_errorfile
    mockup -r 0 huh
    errtwo=$mockup_errorfile
    huh
    ret=$?
    assertFalse "mockup failed" $ret
    [ $ret -eq 0 ] || cat "$errone"
    huh
    ret=$?
    assertTrue "mockup failed" $ret
    [ $ret -eq 0 ] || cat "$errtwo"
}

test_mockup_save_cmdline(){
    mockup foo
    foo one "two three" four "five'six"
    assertTrue "mockup did not set cmdline file" "test -n '${mockup_cmdline:-}'"
    assertFilesEqual ./data/mock_save_cmdline.cmdline.foo.txt $mockup_cmdline
}

. /usr/share/shunit2/shunit2
