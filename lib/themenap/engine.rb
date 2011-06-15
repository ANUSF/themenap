require "themenap/config"
require "themenap/nap"
require "rails"

module Themenap
  class Engine < Rails::Engine
    config.to_prepare do
      Themenap::Config.layout_root = Rails.root.to_s

      if Themenap::Config.active
        include Themenap
        nap
      end
    end
  end
end
