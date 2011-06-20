class TagAnotherName < UserAuthAbstract
  belongs_to :tag

  validates_presence_of :tag
  validates_presence_of :name


  def self.merge_tag(full_name,another_names)
    namespace = Tag.get_namespace_from_tag_full_name(full_name)
    merge_target_name = Tag.get_name_from_tag_full_name(full_name)
    merge_target_tag = Tag.find_by_name_and_namespace(merge_target_name,namespace)

    another_tags = another_names.map do |name|
      Tag.find_by_name_and_namespace(name,namespace)
    end

    ActiveRecord::Base.transaction do
      tags_count = another_tags.length
      another_tags.each_with_index do |tag,tindex|
        feeds = tag.feeds
        count = feeds.length
        feeds.each_with_index do |feed,index|
          p "共#{tags_count}个关键词，正在处理第#{tindex+1}个关键词 #{tag.name} #{index+1}/#{count}"

          # 试图合并至目标tag，先判断当前feed是否已经和目标tag产生关联
          # 如果还没有产生关联，则建立关联对象
          mft = feed.feed_tags.find_by_tag_id(merge_target_tag.id)
          if mft.blank?
            FeedTag.create!(:tag=>merge_target_tag,:feed=>feed)
          end

          ft = feed.feed_tags.find_by_tag_id(tag.id)
          ft.destroy
          
        end
        TagAnotherName.create(:name=>tag.name,:tag=>merge_target_tag)
      end

    end
    
  end

  module TagMethods
    def self.included(base)
      base.has_many :tag_another_names
    end

    def another_name_tags
      self.tag_another_names.map do|tan|
        Tag.find_by_name_and_namespace(tan.name,self.namespace)
      end.compact
    end
  end
end
