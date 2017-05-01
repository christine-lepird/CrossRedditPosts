--adds a column with the frequency of each post across multiple reddits
drop table if exists scored_posts;
create table scored_posts as
select *,
	count(id)over(partition by url) as Frequency
from posts;

--filters down to only the posts on more than one subreddit
drop table if exists duplicate_posts;
create table duplicate_posts as
select * 
from scored_posts
where frequency > 1;

--send this back to python to get the comments from the post

