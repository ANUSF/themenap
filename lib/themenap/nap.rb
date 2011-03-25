require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_uri, options = {})
      # -- process the option value passed
      path   = options[:path] || File.join('tmp', 'layouts')
      name   = options[:name] || 'theme.html.erb'

      snippets = options[:snippets]  || {}
      title = encode(snippets[:title] || '<%= yield :title %>')
      head  = encode(snippets[:head]  || '')
      links = encode(snippets[:links] || '')
      main  = encode(snippets[:main]  || '<%= yield %>')

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
      doc.css('title').each do |node|
        node.content = title
      end

      doc.css('head').each do |node|
        node.add_child(Nokogiri::XML::Text.new(head, doc))
      end

      doc.css('nav.subnav').each do |node|
        node.content = links
      end

      doc.css('article').each do |node|
        node.content = main
      end

      # -- write the result to a file
      FileUtils.mkpath(path)
      open(File.join(path, name), 'w') do |fp|
        fp.write decode(doc.to_html)
      end
    end

    protected
    def decode(s)
      s.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>')
    end

    def encode(s)
      s.gsub(/<%/, '{{').gsub(/%>/, '}}')
    end
  end
end
