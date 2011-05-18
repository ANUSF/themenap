require 'nokogiri'
require 'net/http'

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

    def fetch(uri_str, limit = 10)
      raise 'HTTP redirect too deep' if limit == 0

      uri = URI.parse(uri_str)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.port == 443

      unless Themenap::Config.verify_ssl
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(Net::HTTP::Get.new(uri.request_uri))

      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
  end
end
