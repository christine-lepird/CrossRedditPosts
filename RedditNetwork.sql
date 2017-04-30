drop table scored_posts;
create table scored_posts as
select *,
	count(id)over(partition by url) as Frequency
from posts;

--create table top_100_by_100_scored as
--create table scored_posts_old as

drop table duplicate_posts;
create table duplicate_posts as
select * 
from scored_posts
where frequency > 1;

select * 
from duplicate_posts;

select * 
from comments;

--drop table duplicate_posts_comments;
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

drop table comment_sentiment_nondistinct;
create table comment_sentiment_nondistinct as
select id, 
	sub,
	url,
	postscore,
	postposted,
	frequency,
	comment,
	count(*) over(partition by id) as num_comments,
	avg(anger) over(partition by id) as avg_anger,
	avg(anticipation) over(partition by id) as avg_anticipation,
	avg(disgust) over(partition by id) as avg_disgust,	
	avg(fear) over(partition by id) as avg_fear,
	avg(joy) over(partition by id) as avg_joy,
	avg(sadness) over(partition by id) as avg_sadness,
	avg(surprise) over(partition by id) as avg_surprise,
	avg(trust) over(partition by id) as avg_trust,
	avg(negative) over(partition by id) as avg_negative,
	avg(positive) over(partition by id) as avg_positive
from comment_sentiment;

create table comment_sentiment_nondistinct_ranked as
select *,
	rank() over(partition by id ORDER BY comment) as rank
from comment_sentiment_nondistinct;

create table post_sentiment as
select id,
	sub,
	url,
	postscore,
	postposted,
	frequency,
	num_comments,
	avg_anger,
	avg_anticipation,
	avg_disgust,
	avg_fear,
	avg_joy,
	avg_sadness,
	avg_surprise,
	avg_trust,
	avg_negative,
	avg_positive
from comment_sentiment_nondistinct_ranked
where rank = 1;

drop table post_pos_neg_rank;
create table post_pos_neg_rank as
select url,
	sub,
	avg_positive,
	avg_negative,
	rank() over(partition by url ORDER BY sub) as sub_rank
from post_sentiment;

create table pos_neg_edgelist as
select a.url,
	a.sub as sub1,
	b.sub as sub2,
	a.avg_positive - a.avg_negative as sub1_pos_minus_neg,
	b.avg_positive - b.avg_negative as sub2_pos_minus_neg
from post_sentiment a
inner join post_sentiment b on a.url=b.url
where a.sub!=b.sub;

drop table post_agreement;
create table post_agreement as
select sub1,
	sub2,
	case when sub1_pos_minus_neg>0 AND sub2_pos_minus_neg>0 THEN 1 
		when sub1_pos_minus_neg<0 AND sub2_pos_minus_neg<0 THEN 1
		else 0 end as agreement
from pos_neg_edgelist;

select * 
from post_agreement;

copy post_agreement TO '/Users/sowacm1/Desktop' DELIMITER ',' CSV HEADER;
