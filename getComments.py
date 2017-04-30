#!/usr/bin/python2

import praw
import psycopg2
from datetime import datetime
import time

reddit = praw.Reddit(client_id=<<SECRET>>, 
	                 client_secret = <<SECRET>>,
	                 user_agent = <<SECRET>>)

conn = psycopg2.connect(host = <<SECRET>>, user = 'postgres', password='postgres', dbname='postgres')
curr = conn.cursor()

curr.execute("truncate table comments;")
conn.commit()

curr.execute("select id from duplicate_post_ids;")

for row in curr.fetchall():
	print row[0]
	post = reddit.submission(id = row[0])
	post.comments.replace_more(limit=0)
	for comment in post.comments:
		out = ""
		if len(comment.body) > 999:
			out = comment.body[:999]
		else:
			out = comment.body
		curr.execute("insert into comments values (%s, %s, %s, %s);", (row[0], out, comment.score, datetime.fromtimestamp(comment.created)))
	conn.commit()		