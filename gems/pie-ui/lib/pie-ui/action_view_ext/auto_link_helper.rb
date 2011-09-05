module PieUi
  module AutoLinkHelper
    AUTO_LINK_RE = %r{
                          (                          # leading text
                            <\w+.*?>|                # leading HTML tag, or
                            [^=!:'"/]|               # leading punctuation, or
                            ^                        # beginning of line
                          )
                          (
                            (?:https?://)            # protocol spec, or
                          )
                          (
                            [-0-9A-Za-z_]+           # subdomain or domain
                            (?:\.[-0-9A-Za-z_]+)*    # remaining subdomains or domain
                            (?::\d+)?                # port
                            (?:/(?:(?:[~0-9A-Za-z_\+%-]|(?:[,.;:][^\s$]))+)?)* # path
                            (?:\?[0-9A-Za-z_\+%&=.;-]+)?     # query string
                            (?:\#[0-9A-Za-z_\-]*)?   # trailing anchor
                          )
    }x unless const_defined?(:AUTO_LINK_RE)

    # $2
    # (?:www\.) www开头的就不转换了

    def auto_link_urls(text, href_options = {})
      extra_options = tag_options(href_options.stringify_keys) || ""
      text.gsub(AUTO_LINK_RE) do
        all, a, b, c = $&, $1, $2, $3
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all
        else
          text = b + c
          text = yield(text) if block_given?
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>)
        end
      end
    end
  end
end
