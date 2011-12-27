require "spree_aprova_facil/version"
require 'active_merchant/billing/gateways/aprova_facil'
require 'aprova_facil'

module SpreeAprovaFacil
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)


    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      Gateway::CobreBemAprovaFacil.register
    end

    config.to_prepare &method(:activate).to_proc
  end
end

