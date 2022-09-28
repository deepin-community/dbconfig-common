#!/bin/sh

# get some common functions
. $(dirname "$0")/functions
. ${_dbc_root}/dpkg/postinst

dbc_share="$TMPDIR/share"
dbc_basepackage=foo
dbc_dbtype=mysql
dbc_oldversion=1.7.6

test_dbc_find_upgrades(){
    local res
    mkdir -p "$dbc_share/data/$dbc_basepackage/upgrade/$dbc_dbtype"
    mockup -o data/dbc_find_upgrades.find.print0.txt find
    res=$(_dbc_find_upgrades)
    assertEquals "1.8 1.10 1.10.1 1.10.2 1.11 1.12" "$res"
    rm -rf "$dbc_share"
}

. /usr/share/shunit2/shunit2
