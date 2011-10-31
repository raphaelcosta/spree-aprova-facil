class Gateway::ExperiaAprovaFacil < Gateway
  def provider_class
    ActiveMerchant::Billing::AprovaFacilGateway
  end
end
