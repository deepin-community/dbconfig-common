#!/bin/sh

# get some common functions
. $(dirname "$0")/functions
. $(dirname "$0")/common

setUp(){
    # Overload the setUp function from ./functions, but make sure
    # we still perform those two commands it contains by
    # copying them here
    purge_tmp
    tc_case_no=0

    dbc_dbname="testdbname"
    dbc_dbuser="testdbuser"
    dbc_dbadmin="testadmin"
    dbc_dbpass="testdbpass"
    dbc_dbadmpass="testadmpass"
    dbc_authmethod_admin="password"
    dbc_authmethod_user="password"
    dbc_dbserver="testserver"
    dbc_dbport="testport"
    test_dbtype="pgsql"
    mock_command="psql"
    nodb_command="SELECT datname FROM pg_database;"
    withdb_command="\d"
    skip_mock=""

    # For testing with a real database
    dbc_dbadmin_real="postgres"
    dbc_dbadmpass_real="" # Must be empty to have the default peer login
    dbc_authmethod_admin_real="ident"
    dbc_dbserver_real=""
    dbc_dbport_real=""

    . ${_dbc_root}/internal/pgsql
}

# make sure the correct local username is used for all variations
test__dbc_psql_local_username(){
    local _dbc_asuser dbc_authmethod_user dbc_authmethod_admin dbc_dbserver
    local output stderr dbc_dbuser

    dbc_dbuser=""
    dbc_authmethod_admin=""
    dbc_dbserver=""

    log_tc "_dbc_asuser='' dbc_authmethod_admin='' dbc_dbserver=''"
    output=$(_dbc_psql_local_username)
    assertTrue "_dbc_psql_local_username failed" $?
    assertEquals "root" "$output"

    log_tc "_dbc_asuser='' dbc_authmethod_admin='password' dbc_dbserver=''"
    dbc_authmethod_admin="password"
    output=$(_dbc_psql_local_username)
    assertTrue "_dbc_psql_local_username failed" $?
    assertEquals "root" "$output"

    log_tc "_dbc_asuser='' dbc_authmethod_admin='ident' dbc_dbserver=''"
    dbc_dbserver=""
    dbc_authmethod_admin="ident"
    output=$(_dbc_psql_local_username)
    assertTrue "_dbc_psql_local_username failed" $?
    assertEquals "$dbc_dbadmin" "$output"

    log_tc "_dbc_asuser='yes' dbc_dbuser='' dbc_authmethod_user='ident' dbc_dbserver=''"
    _dbc_asuser="yes"
    dbc_authmethod_user="ident"
    dbc_dbserver=""
    output=$(_dbc_psql_local_username 2>/dev/null)
    assertFalse "_dbc_psql_local_username should have failed" $?
    assertEquals "" "$output"

    dbc_dbuser=$(id -un)
    log_tc "_dbc_asuser='yes' dbc_dbuser='$dbc_dbuser' dbc_authmethod_user='ident' dbc_dbserver=''"
    _dbc_asuser="yes"
    dbc_authmethod_user="ident"
    dbc_dbserver=""
    output=$(_dbc_psql_local_username)
    assertTrue "_dbc_psql_local_username failed" $?
    assertEquals "$dbc_dbuser" "$output"

    log_tc "_dbc_asuser='yes' dbc_dbuser='' dbc_authmethod_user='password' dbc_dbserver=''"
    dbc_dbuser=""
    _dbc_asuser="yes"
    dbc_authmethod_user="password"
    dbc_dbserver=""
    output=$(_dbc_psql_local_username)
    assertTrue "_dbc_psql_local_username failed" $?
    assertEquals "root" "$output"
}

test__dbc_psql_remote_username(){
    local output _dbc_asuser

    log_tc "_dbc_asuser=''"
    output=$(_dbc_psql_remote_username)
    assertTrue "_dbc_psql_remote_username failed" $?
    assertEquals "$dbc_dbadmin" "$output"

    log_tc "_dbc_asuser='yes'"
    _dbc_asuser="yes"
    output=$(_dbc_psql_remote_username)
    assertTrue "_dbc_psql_remote_username failed" $?
    assertEquals "$dbc_dbuser" "$output"
    _dbc_asuser=""
}

#test_psql_check_connect_mock(){
#    common_check_connect
#}

test_psql_check_connect_real(){
    _run_for_real && common_check_connect
}

#test_dbc_psql_exec_file_mock(){
#    dbc_common_exec_file
#}

test_dbc_psql_exec_file_real(){
    # second testcase failing until createdb fixed
    _run_for_real && dbc_common_exec_file
}

test_dbc_psql_admin_passwd_real(){
    local sqlcmd dbc_dbadmpass_real
    if _run_for_real ; then
        # First we have to make sure that the postgresql user actually
        # has a password with which it can log in
        dbc_dbadmpass_real="$(date | md5sum)"
        sqlcmd=$(mktemp -t)
        echo "alter user postgres with password '$dbc_dbadmpass_real';" > "$sqlcmd"
        _dbc_nodb=true
        dbc_pgsql_exec_file "$sqlcmd"
        _dbc_nodb=
        assertTrue "Must be able to change password before next test" $?
        rm -f "$sqlcmd"

        # Then we use that new password to try and log in (mind that
        # defining a dbadmpass already makes the switch from peer to passwd
        dbc_dbadmpass="$dbc_dbadmpass_real"
        dbc_common_exec_file

        # And check that it fails with the wrong password (so we are sure
        # it is really done via password auth).
        dbc_dbadmpass="wrongPassWord"
        _dbc_pgsql_check_connect 2>/dev/null
        assertFalse "Connecting with wrong password should have failed" $?
    fi
}

# The following tests would need themselfs to pass to be able
# to test them and if they fail a lot of other tests already fail

#test_psql_exec_command(){
#    common_exec_command
#}
#
#test_dbc_psql_check_database(){
#    dbc_common_check_database
#}
#
#test_dbc_psql_check_user(){
#    dbc_common_check_user
#}

#test_dbc_pgsql_createdb_mock(){
#    dbc_common_createdb
#}

test_dbc_pgsql_createdb_real(){
    _run_for_real && dbc_common_createdb
}

test_dbc_pgsql_createdb__with_encoding(){
    . ${_dbc_root}/internal/pgsql
    local dbsqlfile dbargsfile dbc_pgsql_createdb_encoding
    log_tc "encoding not specified"
    mockup _dbc_sanity_check
    mockup _dbc_pgsql_check_connect
    mockup -r 1 _dbc_pgsql_check_database
    mockup -i _dbc_psql
    dbargsfile="$mockup_cmdline"
    dbsqlfile="$mockup_inputfile"
    mockup _dbc_pgsql_check_database
    dbc_pgsql_createdb >/dev/null 2>&1
    assertTrue "dbc_pgsql_createdb failed" $?
    assertFilesEqual "_dbc_createdb without encoding" "./data/dbc_pgsql_createdb.psql.noencoding.cmdline" "$dbargsfile"
    assertFilesEqual "_dbc_createdb input without encoding" "./data/dbc_pgsql_createdb.psql.noencoding.sql" "$dbsqlfile"

    log_tc "encoding specified"
    dbc_pgsql_createdb_encoding="UTF-8"
    mockup _dbc_sanity_check
    mockup _dbc_pgsql_check_connect
    mockup -r 1 _dbc_pgsql_check_database
    mockup -i _dbc_psql
    dbargsfile="$mockup_cmdline"
    dbsqlfile="$mockup_inputfile"
    mockup _dbc_pgsql_check_database
    dbc_pgsql_createdb >/dev/null 2>&1
    assertTrue "dbc_pgsql_createdb failed" $?
    assertFilesEqual "_dbc_createdb with encoding" "./data/dbc_pgsql_createdb.psql.encoding.cmdline" "$dbargsfile"
    assertFilesEqual "_dbc_createdb input with encoding" "./data/dbc_pgsql_createdb.psql.encoding.sql" "$dbsqlfile"
}

#test_dbc_psql_dropdb_mock(){
#    dbc_common_dropdb
#}

test_dbc_psql_dropdb_real(){
    _run_for_real && dbc_common_dropdb
}

#test_dbc_psql_createuser_mock(){
#    dbc_common_createuser
#}

test_dbc_psql_createuser_real(){
    _run_for_real && dbc_common_createuser
}

#test_dbc_psql_dropuser_mock(){
#    dbc_common_dropuser
#}

test_dbc_psql_dropuser_real(){
    _run_for_real && dbc_common_dropuser
}

#test_dbc_psql_dump_mock(){
#    dbc_common_dump
#}

test_dbc_psql_dump_real(){
    _run_for_real && dbc_common_dump
}

# The common test for this doesn't work for postgresql as it fails
# to find /usr/bin/find
#test_dbc_psql_db_installed_mock(){
#    dbc_common_db_installed
#}

test_dbc_psql_db_installed_real(){
    _run_for_real && dbc_common_db_installed
}

test_dbc_psql_escape_str(){
    dbc_common_escape_str
}


_real_connect_vars(){
    dbc_dbadmin=$dbc_dbadmin_real
    dbc_dbadmpass=${dbc_dbadmpass_real:-}
    dbc_authmethod_admin=$dbc_authmethod_admin_real
    dbc_dbserver=$dbc_dbserver_real
    dbc_dbport=$dbc_dbport_real
    mockup_cmdline=x
    mockup_inputfile=y
}

_run_for_real(){
    if [ "${dbc_test_with_client:-}" ] ; then
        skip_mock=true
        _real_connect_vars
    else
        echo "  Skipped"
        return 1
    fi
}

. /usr/share/shunit2/shunit2
