require 'nokogiri'
require 'httparty'
require 'highline'
require 'themenap/config'

module Themenap
  class Server
    include HTTParty

    def initialize(user = nil, pass = nil)
      self.class.basic_auth(user, pass) unless user.nil?
    end

    def get(*args)
      self.class.get *args
    end
  end

  class Nap
    def initialize(server_base, server_path = '')
      server_uri = server_base + '/' + (server_path || '').sub(/^\//, '')
      if Themenap::Config.use_basic_auth
        puts "HTTP authentication needed for #{server_uri}"
        h = HighLine.new
        user = h.ask("User: ")
        pass = h.ask("Password: ") { |q| q.echo = '*' }
        server = Server.new user, pass
      else
        server = Server.new
      end

      # -- grab the HTML page from the server and parse it
      @doc = Nokogiri::HTML server.get server_uri

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
        node[key] = encode(value)
      end
      self
    end

    def remove(css)
      @doc.css(css).remove
      self
    end

    def write_to(path, name)
      FileUtils.mkpath(path)
      open(File.join(path, "#{name}.html.erb"), 'w') do |fp|
        fp.write decode(@doc.to_html)
      end
    end

    def exists?(path, name)
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

  def nap
    server      = Themenap::Config.server
    layout_name = Themenap::Config.layout_name
    layout_path =
      File.join Themenap::Config.layout_root, Themenap::Config.layout_path
    begin
      theme = Themenap::Nap.new(server, Themenap::Config.server_path)
      for snip in Themenap::Config.snippets
        case (snip[:mode] || :replace).to_sym
        when :append  then theme.append(snip[:css], snip[:text])
        when :replace then theme.replace(snip[:css], snip[:text])
        when :remove then theme.remove(snip[:css])
        when :setattr
          theme.setattr(snip[:css], snip[:key], snip[:value])
        end
        theme.write_to(layout_path, layout_name)
      end
    rescue Exception => ex
      puts "Couldn't load theme from #{server} - #{ex}"
    end
  end
end
