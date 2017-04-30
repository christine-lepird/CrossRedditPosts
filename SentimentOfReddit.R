#install.packages("RPostgreSQL")
library(igraph)
require("RPostgreSQL")
pw <- {
  "postgres"
}

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "postgres",
                 host = "146.148.104.137", port = 5432,
                 user = "postgres", password = pw)
rm(pw) # removes the password

dbExistsTable(con, "duplicate_posts_comments")
df_postgres <- dbGetQuery(con, "SELECT * from duplicate_posts_comments")

getsentiment <- function(tweets.df){
  tweets.df$text <- sapply(tweets.df$comment,function(row) iconv(row, "latin1", "ASCII", sub=""))
  mySentiment <- get_nrc_sentiment(tweets.df$comment)
  tweets.df.senti <<- cbind(tweets.df, mySentiment)
}

comment_sentiment <- getsentiment(df_postgres)

dbWriteTable(con, "comment_sentiment", 
             value = comment_sentiment, append = TRUE, row.names = FALSE)

dbExistsTable(con, "post_agreement")
df_agreement <- dbGetQuery(con, "SELECT sub1, sub2, agreement from post_agreement")

write.csv(file="/Users/sowacm1/Desktop/agreement.csv", x=df_agreement, row.names=FALSE)

agreement.matrix <- as.matrix(df_agreement)

g=graph.edgelist(agreement.matrix[,1:2]) 
E(g)$
E(g)$weight=as.numeric(el[,3])
