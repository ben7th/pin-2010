module TagHelper

  def tag_label(tag)
    tag_full_name = tag.full_name

    tag_namespace_label = tag.namespace.blank? ? '':"<span class='namespace'>#{tag.namespace}</span>"
    tag_name_label = "<span class='tag-name'>#{tag.name}<span>"

    if tag.has_logo?
      tag_logo_label = logo(tag,:mini)
      link_to "#{tag_namespace_label}#{tag_logo_label}#{tag_name_label}","/tags/#{tag_full_name}",:class=>'tag has-logo'
    else
      link_to "#{tag_namespace_label}#{tag_name_label}","/tags/#{tag_full_name}",:class=>'tag'
    end

  rescue Exception => ex
    return ''
  end

end
