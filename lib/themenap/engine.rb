require "themenap"
require "themenap/nap"
require "rails"

module Themenap
  class Config
    class << self
      attr_accessor :dummy
    end
  end

  class Engine < Rails::Engine
    initializer 'themenap.configure' do |app|
      Themenap::Config.dummy = 'test'
    end

    initializer 'themenap.set_view_path' do |app|
      ActionController::Base.append_view_path(File.join(Rails.root, 'tmp'))
    end

    config.to_prepare do
      server = 'http://testada'
      begin
        Themenap::Nap.new(server).
          replace('title',   '<%= yield :title %>').
          #append('head',     '<%= render "layout/includes" %>').
          replace('article', '<%= yield %>').
          write_to(File.join('tmp', 'layouts'))
        ApplicationController.layout 'theme'
      rescue
        Rails.logger.error("Couldn't load theme from #{server}.")
        ApplicationController.layout 'themenap'
      end
    end
  end
end
