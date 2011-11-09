class PostComment < UserAuthAbstract
  belongs_to :post
  belongs_to :user
  belongs_to :reply_to_comment, :class_name=>"PostComment", :foreign_key=>:reply_comment_id
  has_many :reply_comments, :class_name=>"PostComment", :foreign_key=>:reply_comment_id

  validates_presence_of :post
  validates_presence_of :user
  validates_presence_of :content

  module PostMethods
    def self.included(base)
      base.has_many :comments,:class_name=>"PostComment",:order=>"id desc"
    end

    def add_comment(user, content)
      comment = PostComment.new(:post=>self,:user=>user,:content=>content)
      unless comment.save
        raise comment.errors.first[1]
      end
      comment
    end
  end
  include Atme::AtableMethods
  include Atme::PostCommentMethods

  module UserMethods
    # 用户收到的评论
    # 分为，1 用户的主题收到的评论
    # 2 回复给用户的评论
    # 不包括用户自己的评论

    # since_id，可选，如果指定此参数，只返回id大于此id（时间上较早）的评论。
    # max_id，可选，如果指定此参数，只返回id小于或等于此id（时间上较晚）的评论。
    # count，可选，缺省值20，最大200。指定返回的条目数。
    # page，可选，缺省1
    def comments_received(options={})
      count = options[:count] || 20
      page  = options[:page] || 1

      since_id = options[:since_id] || 0
      since_id = since_id.to_i unless since_id.blank?

      max_id = options[:max_id]
      max_id = max_id.to_i unless max_id.blank?

      user_id = self.id

      where_str = "WHERE PC.user_id<>#{user_id} AND PC.id>#{since_id}"
      where_str = "#{where_str} AND PC.id<=#{max_id}" if !max_id.blank?

      PostComment.find_by_sql(%~
        SELECT DISTINCT RES.* FROM
        (
          (
            SELECT DISTINCT PC.*
            FROM post_comments PC
            JOIN posts P ON PC.post_id = P.id AND P.user_id = #{user_id}
            #{where_str}
          )
          UNION
          (
            SELECT DISTINCT PC.*
            FROM post_comments PC
            JOIN post_comments PC1 ON PC.reply_comment_id = PC1.id AND PC1.user_id = #{user_id}
            #{where_str}
          )
        ) AS RES
        ORDER BY RES.id DESC
      ~).paginate(:page=>page, :per_page=>count)
    end
  end

  def add_reply(user, content)
    comment = PostComment.new(:post=>self.post, :user=>user, :content=>content, :reply_comment_id=>self.id)
    unless comment.save
      raise comment.errors.first[1]
    end
    comment
  end
end
