module TagHelper

  def tag_label(tag,klass='')
    tag_full_name = tag.full_name

    tag_namespace_label = tag.namespace.blank? ? '':"<span class='namespace'>#{tag.namespace}</span>"
    tag_name_label = "<span class='tag-name'>#{tag.name}<span>"

    if tag.has_logo?
      tag_logo_label = logo(tag,:mini)
      link_to "#{tag_namespace_label}#{tag_logo_label}#{tag_name_label}",
        "/tags/#{tag_full_name}",
        :class=>['tag has-logo',klass]*' ',
        :rel=>'tag',
        :'data-name'=>tag.full_name
    else
      link_to "#{tag_namespace_label}#{tag_name_label}",
        "/tags/#{tag_full_name}",
        :class=>['tag',klass]*' ',
        :rel=>'tag',
        :'data-name'=>tag.full_name
    end

  rescue Exception => ex
    return ''
  end

end
