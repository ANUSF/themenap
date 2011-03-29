require 'nokogiri'

module Themenap
  class Nap
    def initialize(server_base, server_path = '')
      server_uri = server_base + '/' + (server_path || '').sub(/^\//, '')

      # -- grab the HTML page from the server and parse it
      @doc = Nokogiri::HTML fetch(server_uri)

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

    def set_id(css, text)
      @doc.css(css).each do |node|
        node['id'] = text
      end
      self
    end

    def write_to(path = File.join('tmp', 'layouts'), name = 'theme')
      FileUtils.mkpath(path)
      open(File.join(path, "#{name}.html.erb"), 'w') do |fp|
        fp.write decode(@doc.to_html)
      end
    end

    protected
    def decode(s)
      s.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>')
    end

    def encode(s)
      s.gsub(/<%/, '{{').gsub(/%>/, '}}')
    end

    def fetch(uri_str, limit = 10)
      raise 'HTTP redirect too deep' if limit == 0

      response = Net::HTTP.get_response(URI.parse(uri_str))
      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
  end
end
