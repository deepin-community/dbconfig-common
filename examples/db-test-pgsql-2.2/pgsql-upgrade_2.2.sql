-- this sql should automatically be sourced for upgrades from pre-2.1 versions
update mytable set version='2.2';
insert into foo (id, name) values (3, 'DBCONFFIG TEST');
insert into foo (id, name) values (4, '_DBC_DBUSER_');

