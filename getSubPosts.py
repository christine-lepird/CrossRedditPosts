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

# Delete any existing data.
curr.execute("truncate table comments;")
conn.commit()
curr.execute("truncate table posts cascade;")
conn.commit()

for sub in reddit.subreddits.popular():
	for post in sub.hot(limit = 100):

		# Display 
		print "%s %s %d" % (sub.display_name, post.url, post.score)
		pid = post.id

		# Conditionally insert data if it doens't already exist
		curr.execute("""
			insert into posts (id, sub, url, score, posted)
			select %s, %s, %s, %s, %s
			where not exists (
				select id from posts where id = %s
			);
			""", (pid, sub.display_name, post.url, post.score, datetime.fromtimestamp(post.created), pid))
		# Upload the changes to the DB.
		conn.commit()
