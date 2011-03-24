require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_uri)
      response = Net::HTTP.get URI.parse(server_uri)

      doc = Nokogiri::HTML(response)
      doc.css('article').each { |article| article.content = '{{= yield }}' }

      ['src', 'href'].each do |attr|
        doc.css("*[#{attr}]").each do |node|
          link = node[attr]
          node[attr] = "#{server_uri}#{link}" if link.starts_with? '/'
        end
      end

      path = File.join(Rails.root, 'tmp', 'layouts')
      FileUtils.mkpath(path)
      open(File.join(path, 'theme.html.erb'), 'w') do |fp|
        fp.write doc.to_html.gsub(/{{/, '<%').gsub(/}}/, '%>')
      end
    end
  end
end
