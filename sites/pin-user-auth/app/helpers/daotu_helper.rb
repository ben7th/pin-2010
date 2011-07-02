module DaotuHelper

#  def daotu_user_homepage_nurl(user)
#    pin_url_for("pin-daotu","users/#{user.id}")
#  end
#
#  def daotu_mindmaps_nurl
#    pin_url_for("pin-daotu")
#  end
#
#  def daotu_mindmaps_public_nurl
#    pin_url_for("pin-daotu","public")
#  end
#
#  def daotu_mindmaps_import_file_nurl
#    pin_url_for("pin-daotu","import_file")
#  end
#
#  def daotu_mindmaps_aj_words_nurl
#    pin_url_for("pin-daotu","aj_words")
#  end
#
#  def daotu_mindmaps_cooperates_nurl
#    pin_url_for("pin-daotu","cooperates")
#  end
#
#  def daotu_mindmaps_search_nurl
#    pin_url_for("pin-daotu","search")
#  end
#
  def daotu_mindmap_info_nurl(mindmap)
    pin_url_for("pin-daotu","#{mindmap.id}/info")
  end

  def daotu_mindmap_nurl(mindmap)
    pin_url_for("pin-daotu",mindmap.id)
  end
#
#  def daotu_mindmap_newest_nurl(mindmap)
#    pin_url_for("pin-daotu","#{mindmap.id}/newest")
#  end


  #  map.resources :mindmaps,:collection=>{
  #    :import_file=>:post,
  #    :aj_words=>:get,
  #    :cooperates=>:get,
  #    :search=>:get
  #  },:member=>{
  #    :change_title=>:put,
  #    :clone_form=>:get,
  #    :do_clone=>:put,
  #    :do_private=>:put,
  #    :info=>:get,
  #    :fav=>:post,
  #    :unfav=>:delete,
  #    :comments=>:post,
  #    :newest=>:get
  #  }
end