require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_uri, options = {})
      path = options[:path] || File.join('tmp', 'layouts')
      name = options[:name] || 'theme.html.erb'
      include_cmd = options[:include] || 'yield'

      response = Net::HTTP.get URI.parse(server_uri)

      doc = Nokogiri::HTML(response)
      doc.css('article').each do |article|
        article.content = "{{= #{include_cmd} }}"
      end

      ['src', 'href'].each do |attr|
        doc.css("*[#{attr}]").each do |node|
          link = node[attr]
          node[attr] = "#{server_uri}#{link}" if link.start_with? '/'
        end
      end

      FileUtils.mkpath(path)
      open(File.join(path, name), 'w') do |fp|
        fp.write doc.to_html.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>')
      end
    end
  end
end
