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
    dbc_dbserver="testserver"
    dbc_dbport="testport"
    dbc_dballow="testserver2"
    test_dbtype="mysql"
    mock_command="mysql"
    nodb_command="show databases;"
    withdb_command="show tables;"
    skip_mock=""

    # For testing with a real database
    dbc_dbadmin_real="Could not determine admin"
    dbc_dbadmpass_real="Could not determine admin password"
    dbc_dbserver_real=""
    dbc_dbport_real=""
    dbc_dballow_real="localhost"
    if [ "${dbc_test_with_client:-}" ] && [ -f /etc/mysql/debian.cnf ] ; then
        dbc_dbadmin_real="$(sed -n 's/^[     ]*user *= *// p' /etc/mysql/debian.cnf | head -n 1)"
        dbc_dbadmpass_real="$(sed -n 's/^[     ]*password *= *// p' /etc/mysql/debian.cnf | head -n 1)"
        if [ ! ${dbc_dbadmpass_real} ] ; then
            dbc_dbadmpass_real="Could not determine admin password (permissions?)"
        fi
    fi

    . ${_dbc_root}/internal/mysql
}

test_generate_mycnf(){
    local cnf DIFF

    DIFF='diff -b -u -I "^# generated on"'

    cnf=$(_dbc_generate_mycnf)
    assertTrue "_dbc_generate_mycnf returned error" $?
    assertFilesEqual ./data/generate_mycnf.txt "$cnf"
    rm -f "$cnf"

    _dbc_asuser="yes"
    cnf=$(_dbc_generate_mycnf)
    assertTrue "_dbc_generate_mycnf returned error" $?
    assertFilesEqual ./data/generate_mycnf_asuser.txt "$cnf"
    rm -f "$cnf"
    _dbc_asuser=""
}

test_mysql_check_connect_mock(){
    _is_posh_real || common_check_connect
}

test_mysql_check_connect_real(){
    _run_for_real && common_check_connect
}

test_dbc_mysql_exec_file_mock(){
    _is_posh_real || dbc_common_exec_file
}

test_dbc_mysql_exec_file_real(){
    _run_for_real && dbc_common_exec_file
}

# The following tests would need themselves to pass to be able
# to test them and if they fail a lot of other tests already fail

test_mysql_exec_command(){
    _is_posh_real || common_exec_command
}

test_dbc_mysql_check_database(){
    _is_posh_real || dbc_common_check_database
}

test_dbc_mysql_check_user(){
    _is_posh_real || dbc_common_check_user
}

# Continue with mock/real couples

test_dbc_mysql_createdb_mock(){
    _is_posh_real || dbc_common_createdb
}

test_dbc_mysql_createdb_real(){
    _run_for_real && dbc_common_createdb
}

test_dbc_mysql_dropdb_mock(){
    _is_posh_real || dbc_common_dropdb
}

test_dbc_mysql_dropdb_real(){
    _run_for_real && dbc_common_dropdb
}

test_dbc_mysql_createuser_mock(){
    _is_posh_real || dbc_common_createuser
}

test_dbc_mysql_createuser_real(){
    _run_for_real && dbc_common_createuser
}

test_dbc_mysql_dropuser_mock(){
    _is_posh_real || dbc_common_dropuser
}

test_dbc_mysql_dropuser_real(){
    _run_for_real && dbc_common_dropuser
}

test_dbc_mysql_dump_mock(){
    _is_posh_real || dbc_common_dump
}

test_dbc_mysql_dump_real(){
    _run_for_real && dbc_common_dump
}

test_dbc_mysql_db_installed_mock(){
    _is_posh_real || dbc_common_db_installed
}

test_dbc_mysql_db_installed_real(){
    _run_for_real && dbc_common_db_installed
}

test_dbc_mysql_escape_str(){
    dbc_common_escape_str
}


_real_connect_vars(){
    dbc_dbadmin=$dbc_dbadmin_real
    dbc_dbadmpass=$dbc_dbadmpass_real
    dbc_dballow=$dbc_dballow_real
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

_is_posh_real(){
    # Until I figure out why running mock tests first and then the real test
    # after that with posh fails, lets skip mocked test when we also tests for
    # real anyways
    if [ "${dbc_test_with_client:-}" ] && [ $(readlink /bin/sh) = posh ] ; then
        echo "  Skipped"
        return 0
    else
        return 1
    fi
}

. /usr/share/shunit2/shunit2
