module TagHelper

  def tag_label(tag_name)
    tag = Tag.find_by_name(tag_name)

    if tag.has_logo?
      link_to "#{logo tag,:mini}#{tag_name}","/tags/#{tag_name}",:class=>'tag has-logo'
    else
      link_to tag_name,"/tags/#{tag_name}",:class=>'tag'
    end

  rescue Exception => ex
    return ''
  end

end
