require "themenap"
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

    config.to_prepare do
      #TODO load and process the theme here
      ApplicationController.layout 'themenap'
    end
  end
end
