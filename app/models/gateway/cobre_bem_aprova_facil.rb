class Gateway::CobreBemAprovaFacil < Gateway
  preference :login, :string

  def provider_class
    ActiveMerchant::Billing::AprovaFacilGateway
  end

  def options
    # add :test key in the options hash, as that is what the ActiveMerchant::Billing::AuthorizeNetGateway expects
    if self.prefers? :test_mode
      self.class.default_preferences[:test] = true
    else
      self.class.default_preferences.delete(:test)
    end

    super
  end
end
