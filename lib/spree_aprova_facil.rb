require 'spree_core'
require 'spree_aprova_facil_hooks'
require 'active_merchant/billing/gateways/aprova_facil'
require 'aprova_facil'

module SpreeAprovaFacil
  class Engine < Rails::Engine

    require 'active_merchant'
    ActiveMerchant::Billing::AprovaFacilGateway


    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      Gateway::ExperiaAprovaFacil.register
    end

    config.to_prepare &method(:activate).to_proc
  end
end
