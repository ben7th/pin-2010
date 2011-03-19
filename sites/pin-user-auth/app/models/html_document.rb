class HtmlDocument < ActiveRecord::Base
  belongs_to :feed
  validates_presence_of :feed
  validates_presence_of :html

  module FeedMethods
    def self.included(base)
      base.has_many :html_documents
    end

    def html
      hd = self.html_documents.first
      return nil if hd.blank?
      return hd.html
    end
  end

end
