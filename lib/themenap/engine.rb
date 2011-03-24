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
      Themenap::Nap.new('http://testada')
      okay = true #TODO actually test if a theme was loaded successfully

      if okay 
        ApplicationController.layout 'theme'
      else
        ApplicationController.layout 'themenap'
      end
    end
  end
end
