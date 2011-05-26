require "themenap"
require "themenap/nap"
require "rails"

module Themenap
  class Config
    class << self
      attr_accessor :active, :server, :server_path, :verify_ssl, :use_basic_auth,
                    :layout_name, :layout_path, :snippets

      def configure
        yield self if block_given?
      end
    end
  end

  Themenap::Config.configure do |c|
    c.active = false
    c.server = 'http://www.gavrog.org'
    c.server_path = ''
    c.verify_ssl = true
    c.use_basic_auth = false
    c.layout_name = 'theme'
    c.layout_path = File.join 'app', 'views', 'layouts'
    c.snippets =
      [ { :css => 'title', :text => '<%= yield :title %>' },
        { :css => 'body', :text => '<%= yield %>' } ]
  end

  class Engine < Rails::Engine
    config.to_prepare do
      nap if Themenap::Config.active
    end
  end

  def nap
    server      = Themenap::Config.server
    layout_name = Themenap::Config.layout_name
    layout_path = File.join Rails.root, Themenap::Config.layout_path
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
