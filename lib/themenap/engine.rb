require "themenap"
require "themenap/nap"
require "rails"

module Themenap
  class Config
    class << self
      attr_accessor :active, :server, :server_path, :verify_ssl, :layout_name,
                    :snippets
    end
    Themenap::Config.active = true
    Themenap::Config.server = 'http://www.gavrog.org'
    Themenap::Config.server_path = ''
    Themenap::Config.verify_ssl = true
    Themenap::Config.layout_name = 'theme'
    Themenap::Config.snippets =
      [ { :css => 'title', :text => '<%= yield :title %>' },
        { :css => 'body', :text => '<%= yield %>' } ]
  end

  class Engine < Rails::Engine
    initializer 'themenap.set_view_path' do |app|
      ActionController::Base.append_view_path(File.join(Rails.root, 'tmp'))
    end

    config.to_prepare do
      if Themenap::Config.active
        server      = Themenap::Config.server
        layout_name = Themenap::Config.layout_name
        layout_path = File.join('tmp', 'layouts')
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
          Rails.logger.error "Couldn't load theme from #{server} - #{ex}"
        end
        if theme and theme.exists?(layout_path, layout_name)
          ApplicationController.layout layout_name
        else
          ApplicationController.layout 'themenap'
        end
      end
    end
  end
end
