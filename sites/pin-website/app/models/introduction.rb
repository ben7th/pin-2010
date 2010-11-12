class Introduction < ActiveRecord::Base

  belongs_to :user
  belongs_to :introductable,:polymorphic => true

  validates_presence_of :user
  validates_presence_of :introductable
  validates_presence_of :content

  before_create :set_default_checked
  def set_default_checked
    self.checked = false
    return true
  end

  require "bluecloth"
  def content_with_html
    BlueCloth::new(content).to_html
  end

  def paragraphs
    self.content.markdown_paragraphs
  end

  def find_content_of_paragraphs(section)
    return self.content if section.nil?
    return self.paragraphs[section.to_i]
  end

  def edit_content_of_paragraphs(section,content,user)
    if section.blank?
      return Introduction.new(:user=>user,:content=>content,:introductable=>self.introductable)
    end
    paragraphs = self.paragraphs
    paragraphs[section.to_i] = content + "\n"
    Introduction.new(:user=>user,:content=>paragraphs.join,:introductable=>self.introductable)
  end

  module IntroductableMethods
    def self.included(base)
      base.has_many :introductions,:as=>:introductable
    end

    def introduction
      return self.introductions.last
    end
  end

end
