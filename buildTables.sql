drop table if exists posts cascade; 
create table posts (
	id varchar(512) primary key,
	sub varchar(100),
	url varchar(512),
	score int,
	posted timestamp);

drop table if exists comments;
create table comments (
	id varchar(512) references posts,
	comment varchar(1000), 
	score int, 
	posted timestamp);

select * from posts;

select * from posts right outer join comments on posts.id = comments.id;