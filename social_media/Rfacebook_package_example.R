# ==== Facebook example ==== #

# Set working directory
wd_path <- "..."
setwd(wd_path)

# Load packages
# If you need to install packages run the following line
# install.packages("Rfacebook","dplyr","readr")
library(Rfacebook)
library(dplyr)
library(readr)

# OAuth authentication
# Set up Facebook developer account to get this
# app_id <- 'your_app_id'
# app_secret <- 'your_secret'
# fb_oauth <- fbOAuth(app_id = app_id,
#                     app_secret = app_secret,
#                     extended_permissions = TRUE)

# That didn't work

# Try with a token from: https://developers.facebook.com/tools/explorer
# You will need to refresh this for subsequent runs
token <- "..."

# === Pull the posts from pages === #
pageName <- "UTSEngage"
page.df <- getPage(pageName, token, n = 50)

# Inspect
str(page)

# Create a posts data frame with only relevant fields
posts.df <- page.df %>%
    mutate(post_date_GMT = as.POSIXct(page.df$created_time,
                                      format = "%Y-%m-%dT%H:%M:%S+0000",
                                      tz = "GMT")) %>%
    select(id,
           from_id,
           from_name,
           message,
           link,
           type,
           post_date_GMT,
           likes_count,
           comments_count,
           shares_count) %>%
    arrange(id)
# Export the posts
write_csv(posts.df, "data_out/posts.csv")

# == Now pull the comments == #
# Will need to do this as a loop

# Initialise
comments.df <- data.frame(
    post_id = character(0),
    comment_id = character(0),
    comment_from_name = character(0),
    comment_message = character(0),
    comment_likes_count = numeric(0),
    stringsAsFactors = FALSE)

# Pull the post details (without likes)
for (post in posts.df$id) {
    # Pull the post details (without likes)
    post_tmp.ls <- getPost(post, token, comments = TRUE, likes = FALSE)
    # Merge the comments into the comments data frame (if they exist)
    if (nrow(post_tmp.ls$comments)) {
        comments.df <- bind_rows(comments.df,
                                 data.frame(post_id = post_tmp.ls$post$id,
                                            comment_id = post_tmp.ls$comments$id,
                                            comment_from_name = post_tmp.ls$comments$from_name,
                                            comment_message = post_tmp.ls$comments$message,
                                            comment_likes_count = post_tmp.ls$comments$likes_count,
                                            stringsAsFactors = FALSE))
    }
}

# Export the comments
write_csv(comments.df, "data_out/comments.csv")