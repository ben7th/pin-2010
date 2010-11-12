class User < UserBase
  has_many :browse_histories,:order=>"updated_at desc"
  has_many :browse_histories_limited,:class_name=>"BrowseHistory",:order=>"updated_at desc",:limit=>20
  has_many :web_site_visits
  has_many :web_site_visits_by_time,:class_name=>'WebSiteVisit',:order=>"updated_at desc",:limit=>15
  has_many :web_site_visits_by_count,:class_name=>'WebSiteVisit',:order=>"count desc",:limit=>15
  has_many :web_sites,:through=>:web_site_visits
end