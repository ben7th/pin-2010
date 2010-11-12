module LightviewHelper

  def lightview_a(options,&block)
    href = options[:href]
    rel = options[:parent] ? "#{options[:parent].class}_#{options[:parent].id}" : randstr
    str_before = %`
      <a id="#{id}" class="lightview" href="#{href}" rel="set[#{rel}]">
    `
    str_after = %`
        </a>
    `
    concat(str_before)
    concat(capture(&block))
    concat(str_after)
  end
end