require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_uri, options = {})
      # -- process the option value passed
      path   = options[:path] || File.join('tmp', 'layouts')
      name   = options[:name] || 'theme.html.erb'

      snippets = options[:snippets]  || {}
      yield_main   = snippets[:main]  || 'yield'
      yield_title  = snippets[:title] || 'yield :title'
      head_content = snippets[:head]  || ''
      yield_css    = snippets[:css]   || 'yield :css'
      yield_js     = snippets[:js]    || 'yield :js'

      # -- grab the HTML page from the server and pass it
      response = Net::HTTP.get URI.parse(server_uri)
      doc = Nokogiri::HTML(response)

      # -- globalize links contained in the document
      ['src', 'href'].each do |attr|
        doc.css("*[#{attr}]").each do |node|
          link = node[attr]
          node[attr] = "#{server_uri}#{link}" if link.start_with? '/'
        end
      end

      # -- turn into a template
      doc.css('head').each do |node|
        node.add_child(Nokogiri::XML::Text.new("\n#{head_content}", doc))
        node.add_child(Nokogiri::XML::Text.new("\n{{= #{yield_css} }}", doc))
        node.add_child(Nokogiri::XML::Text.new("\n{{= #{yield_js} }}", doc))
      end

      doc.css('title').each do |title|
        title.content = "{{= #{yield_title} }}"
      end

      doc.css('article').each do |article|
        article.content = "{{= #{yield_main} }}"
      end

      # -- write the result to a file
      FileUtils.mkpath(path)
      open(File.join(path, name), 'w') do |fp|
        fp.write doc.to_html.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>')
      end
    end
  end
end
