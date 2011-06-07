class TagShare < UserAuthAbstract
  belongs_to :tag
  belongs_to :creator,:class_name=>"User"
  validates_presence_of :tag
  validates_presence_of :creator

  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :description

  module TagMethods
    def self.included(base)
      base.has_many :tag_shares
    end

    def add_share(user,content_options)
      self.tag_shares.create(:url=>content_options[:url],:creator=>user,
        :title=>content_options[:title],:description=>content_options[:description]
      )
    end
  end
end
