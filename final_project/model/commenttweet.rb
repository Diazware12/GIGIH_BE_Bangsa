require './db/db_connector'
require_relative 'user'
require_relative 'tweet'
require_relative 'commenthashtag'

class CommentTweet
  attr_reader :commentTweetId, :userId, :tweetId, :comment_tweet, :hashtags, :dtm_crt, :attachment

  def initialize(params)
    @commentTweetId = params[:commentTweetId]
    @userId = params[:userId]
    @tweetId = params[:tweetId]
    @comment_tweet = params[:comment_tweet]
    @hashtags = params[:hashtags]
    @dtm_crt = params[:dtm_crt]
    @attachment = params[:attachment]
  end

  def self.commentTweetListById(id)
    client = create_db_client
    rawData = client.query("select * from commenttweets where tweetId = #{id}")
    commentList = []
    rawData.each do |data|
      user = User.getUserById(data['userId'])
      tweet = CommentTweet.new(
        commentTweetId: data['commentTweetId'],
        userId: user,
        tweetId: data['tweetId'],
        comment_tweet: data['comment_tweet'],
        hashtags: CommentHashtag.getHashtagByCommentTweet(data['commentTweetId']),
        dtm_crt: data['dtm_crt'],
        attachment: data['attachment']
      )
      commentList.push(tweet)
    end
    commentList
  end

  def self.commentTweetListByHashtag(id)
    client = create_db_client
    rawData = client.query("select ct.commentTweetId, ct.userId, ct.tweetId, ct.comment_tweet, ct.dtm_crt, ct.attachment from commenttweets as ct join commentHashtag as ch on ct.commentTweetId = ch.commentTweetId where ch.hashtagId = #{id}")
    commentList = []
    rawData.each do |data|
      user = User.getUserById(data['userId'])
      tweet = CommentTweet.new(
        commentTweetId: data['commentTweetId'],
        userId: user,
        tweetId: Tweet.getTweet(data['tweetId']),
        comment_tweet: data['comment_tweet'],
        hashtags: CommentHashtag.getHashtagByCommentTweet(data['commentTweetId']),
        dtm_crt: data['dtm_crt'],
        attachment: data['attachment']
      )
      commentList.push(tweet)
    end
    commentList
  end

  def save
    return false unless valid?
    client = create_db_client

    if @attachment.nil?
      rawData = client.query("insert into commenttweets (userId,tweetId,comment_tweet,dtm_crt) values (#{@userId},#{@tweetId},'#{@comment_tweet}',curdate());")
    else
      rawData = client.query("insert into commenttweets (userId,tweetId,comment_tweet,dtm_crt,attachment) values (#{@userId},#{@tweetId},'#{@comment_tweet}',curdate(),'/transaction/#{@attachment}');")
    end

    commentId = client.last_id
    if !@hashtags.nil? || !@hashtags == ''
      insertHashtag = CommentHashtag.saveToHashtag(@hashtags, commentId)
    end
  end

  def valid?
    return false if @userId.nil?
    return false if @tweetId.nil?
    return false if @comment_tweet.nil?
    true
  end
end
