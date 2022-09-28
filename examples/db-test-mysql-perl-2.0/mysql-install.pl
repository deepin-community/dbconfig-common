#!/usr/bin/perl

use DBI;
use strict;


# this is the value of the config file passed to us by dbconfig-common
my $conffile = $ENV{'dbc_config_include'};
# these are the default names of the variables in the config file
our ($dbname, $dbuser, $dbpass, $dbserver, $dbtype);

# load 'er up.
require $conffile;

my $dsn = "DBI:$dbtype:database=$dbname;host=$dbserver";

# error checking here would be a plus.
my $dbh = DBI->connect($dsn, $dbuser, $dbpass);

# error checking here would be a plus too.
$dbh->do("CREATE TABLE IF NOT EXISTS versiontable ( version varchar(32) PRIMARY KEY NOT NULL )");

$dbh->do("DELETE FROM versiontable");
$dbh->do("INSERT INTO versiontable VALUES ( '2.1' )");

$dbh->disconnect();

exit 0;
