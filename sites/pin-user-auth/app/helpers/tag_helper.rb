module TagHelper

  def tag_label(tag)
    tag_name = tag.name
    tag_full_name = tag.full_name

    tag_namespace_label = tag.namespace.blank? ? '':"<span class='namespace'>#{tag.namespace}</span>"

    if tag.has_logo?
      link_to "#{tag_namespace_label}#{logo tag,:mini}#{tag_name}","/tags/#{tag_full_name}",:class=>'tag has-logo'
    else
      link_to "#{tag_namespace_label}#{tag_name}","/tags/#{tag_full_name}",:class=>'tag'
    end

  rescue Exception => ex
    return ''
  end

end
