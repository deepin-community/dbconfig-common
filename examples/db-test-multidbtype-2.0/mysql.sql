create table foo (
	id	int not null primary key,
	name	varchar(32)
);

create table mytable (
	version	varchar(32) not null primary key
);

insert into foo values (1, 'foo');
insert into foo values (2, 'bar');
delete from mytable;
insert into mytable values ('2.0');
