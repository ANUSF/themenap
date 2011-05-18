require 'nokogiri'
require 'httparty'

module Themenap
  class Nap
    def initialize(server_base, server_path = '')
      server_uri = server_base + '/' + (server_path || '').sub(/^\//, '')

      # -- grab the HTML page from the server and parse it
      @doc = Nokogiri::HTML HTTParty.get(server_uri)

      # -- globalize links contained in the document
      ['src', 'href'].each do |attr|
        @doc.css("*[#{attr}]").each do |node|
          link = node[attr]
          #TODO parse the link properly
          unless link =~ /^https?:\/\//
            node[attr] = "#{server_base}/#{link.sub(/^\//, '')}"
          end
        end
      end
    end

    def replace(css, text)
      @doc.css(css).each do |node|
        node.content = encode(text)
      end
      self
    end

    def append(css, text)
      @doc.css(css).each do |node|
        node.add_child Nokogiri::XML::Text.new(encode(text), @doc)
      end
      self
    end

    def setattr(css, key, value)
      @doc.css(css).each do |node|
        node[key] = value
      end
      self
    end

    def write_to(path = File.join('tmp', 'layouts'), name = 'theme')
      FileUtils.mkpath(path)
      open(File.join(path, "#{name}.html.erb"), 'w') do |fp|
        fp.write decode(@doc.to_html)
      end
    end

    def exists?(path = File.join('tmp', 'layouts'), name = 'theme')
      File.exist? File.join(path, "#{name}.html.erb")
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
