# ==== TwitteR example ==== #

# Set working directory
wd_path <- "..."
setwd(wd_path)

# Load packages
# If you need to install packages run the following line
# install.packages("twitteR","lubridate","readr")
library(twitteR)
library(lubridate)
library(readr)

# OAuth authentication
# Necessary file for Windows
#download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

# To get your consumerKey and consumerSecret, see the twitteR
# documentation for instructions
consumer_key <- 'your_key'
consumer_secret <- 'your_secret'
access_token <- 'your_access_token'
access_secret <- 'your_access_secret'
setup_twitter_oauth(consumer_key,
                    consumer_secret,
                    access_token,
                    access_secret)

# === Pull all tweets, via a twitter search query === #
# Search query parameters (see https://dev.twitter.com/rest/public/search for syntax)
query_string <- "#utsmdsi"

# == Run the search == #
# Note the search will only return for the last 7 days

# Manual date start
since_date_chr <- 'yyyy-mm-dd'

# If you are running this pull over several days and have
# the latest tweet_id from a previous date
# latest_tweet_id <- "..."

# Pull the tweets (assuming a n = 1000 limit)
tweets.ls <- searchTwitter(query_string, n = 1000,
                           #since = since_date_chr,
                           #sinceID = latest_tweet_id,
                           resultType = "recent",
                           retryOnRateLimit = 100)
# Convert to a data frame
tweets.df <- twListToDF(tweets.ls)

# Clean up
rm(tweets.ls)

# Convert created date to Sydney time
tweets.df$created <- with_tz(ymd_hms(tweets.df$created, tz = "UTC"),
                             tz = "Australia/Sydney")

# Write out the tweets to a file
write_csv(tweets.df, "data_out/tweets.csv")

# === Get users=== #
# Get unique users from the tweets
unique_users.chr <- unique(tweets.df$screenName)

# Get the user objects
users.ls <- lookupUsers(unique_users.chr)

# Create a data frame of target users
users.df <- twListToDF(users.ls)

# Write out the users
write_csv(users.df, "data_out/users.csv")

# Clean up
rm(users.ls)