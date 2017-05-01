

--takes sentiment score from R and finds average for each post
drop table if exists comment_sentiment_nondistinct;
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

--ranks the comments by post so it can be filtered down later
drop table if exists comment_sentiment_nondistinct_ranked as
create table comment_sentiment_nondistinct_ranked as
select *,
	rank() over(partition by id ORDER BY comment) as rank
from comment_sentiment_nondistinct;

--filters down to make the table post (and subreddit) granular
drop table if exists post_sentiment;
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

--keeps positive and negative attribues while ranking by the url to find duplicates
drop table if exists post_pos_neg_rank;
create table post_pos_neg_rank as
select url,
	sub,
	avg_positive,
	avg_negative,
	rank() over(partition by url ORDER BY sub) as sub_rank
from post_sentiment;

--join the tables on eachother to find a matching of all combinations of subreddits on a given post
drop table if exists pos_neg_edgelist as
create table pos_neg_edgelist as
select a.url,
	a.sub as sub1,
	b.sub as sub2,
	a.avg_positive - a.avg_negative as sub1_pos_minus_neg,
	b.avg_positive - b.avg_negative as sub2_pos_minus_neg
from post_sentiment a
inner join post_sentiment b on a.url=b.url
where a.sub!=b.sub;

--assigns agreement
drop table if exists post_agreement;
create table post_agreement as
select sub1,
	sub2,
	case when sub1_pos_minus_neg>0 AND sub2_pos_minus_neg>0 THEN 1 
		when sub1_pos_minus_neg<0 AND sub2_pos_minus_neg<0 THEN 1
		else 0 end as agreement
from pos_neg_edgelist;

--sends edgelist to local directory as a csv to perform independent visual analysis 
copy post_agreement TO '/Users/sowacm1/Desktop' DELIMITER ',' CSV HEADER;