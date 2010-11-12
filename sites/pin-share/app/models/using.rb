class Using < ActiveRecord::Base

  belongs_to :share
  belongs_to :entry

  validates_presence_of :share
  validates_presence_of :entry

  VIDEO = "VIDEO"
  AUDIO = "AUDIO"
  HTML = 'HTML'

  module ShareMethods
    def self.included(base)
      base.has_many :usings
      base.has_many :entries,:through => :usings
    end
    
    def url_kind(url)
      bentries = self.entries.bookmark_url_is(url)
      return nil if bentries.blank?
      bme = bentries[0].resource
      return VIDEO if bme.is_video_url?
      return AUDIO if bme.is_audio_url?
      return HTML
    end
  end

  module EntryMethods
    def self.included(base)
      base.has_many :usings
      base.has_many :shares,:through => :usings
    end
  end

end
