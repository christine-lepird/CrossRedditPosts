--takes the comments table and joins it in with the posts
drop table if exists duplicate_posts_comments;
create table duplicate_posts_comments as
select a.id,
	a.sub, 
	a.url,
	a.score as postscore,
	a.posted as postposted,
	a.frequency,
	b.comment,
	b.score as commentscore,
	b.posted as commentposted
from duplicate_posts a 
left outer join comments b on a.id=b.id;

--send this to R to perform sentiment analysis