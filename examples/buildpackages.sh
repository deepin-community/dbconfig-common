#!/bin/sh

set -e

packages="db-test-mysql-2.0 db-test-mysql-2.1 db-test-mysql-frontend-2.0 \
          db-test-mysql-perl-2.0 db-test-pgsql-2.0 db-test-pgsql-2.1 db-test-pgsql-2.2 \
          db-test-pgsql-migration-1.9 db-test-pgsql-migration-2.0 \
          db-test-multidbtype-2.0
          db-test-sqlite3-2.0 "

echo -n "building packages:"
for f in $packages; do
	echo -n " ($f)"	
	( 
		cd $f; 
		fakeroot debian/rules binary >/dev/null;
		fakeroot debian/rules clean >/dev/null;
	) 
done
echo " done.  have fun :)"
