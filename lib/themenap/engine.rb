require "themenap"
require "themenap/nap"
require "rails"

module Themenap
  class Config
    class << self
      attr_accessor :active, :server, :server_path, :verify_ssl,
                    :layout_name, :layout_path, :snippets
    end
    Themenap::Config.active = false
    Themenap::Config.server = 'http://www.gavrog.org'
    Themenap::Config.server_path = ''
    Themenap::Config.layout_path = File.join 'app', 'views', 'layouts'
    Themenap::Config.verify_ssl = true
    Themenap::Config.layout_name = 'theme'
    Themenap::Config.snippets =
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
