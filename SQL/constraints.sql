create table product
(pid number(2) not null,
pname varchar2(10));

create table product
(pid number(2) unique,
pname varchar2(10));

create table product
(pid number(2) not null unique,
pname varchar2(10));

create table student
(sno number(2) unique not null,
sname varchar2(10),
dob date,
doj date,
check ( dob < doj ));

insert into student values (1,'A',sysdate-100,sysdate-2);
insert into student values (2,'B', sysdate-2,sysdate-100);

create table dept10
(deptno number,
dname varchar2(10),
check (deptno=10));


create table product
(pid number(2) primary key,
pname varchar2(10) 
);


create table product_list
(pid number(2),
quantity number(10),
price number(6,2),
foreign key (pid) references product(pid) on delete cascade /set null/set default
);

insert into product values (1,'pen');
insert into product values (2,'pencil');
insert into product values (3,'marker');


insert into product_list values (1,10,5.00);

insert into product_list values (4,20,200.00);
