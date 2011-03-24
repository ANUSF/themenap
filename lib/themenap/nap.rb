require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_uri, options = {})
      # -- process the option value passed
      path   = options[:path] || File.join('tmp', 'layouts')
      name   = options[:name] || 'theme.html.erb'
      y_ield = options[:yield] || 'yield'
      main   = options[:main] || ''

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
      doc.css('article').each do |article|
        article.content = "{{= #{y_ield} #{main} }}"
      end

      doc.css('title').each do |title|
        title.content = "{{= #{y_ield} :title }}"
      end

      # -- write the result to a file
      FileUtils.mkpath(path)
      open(File.join(path, name), 'w') do |fp|
        fp.write doc.to_html.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>')
      end
    end
  end
end
