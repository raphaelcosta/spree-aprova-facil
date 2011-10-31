module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class AprovaFacilGateway < Gateway

      self.supported_countries = ['BR']
      self.supported_cardtypes = [:visa, :master, :american_express, :dinners_club]

      def initialize(options = {})
        @options = options
      end

      def authorize(money, creditcard, options = {})
        card = add_creditcard(creditcard,options)

        approval_response = gateway.aprovar(card)

        if success?(approval_response)
          Response.new(
          approval_response[:aprovada],
          approval_response[:resultado],
          { :transaction_id => approval_response[:transacao] },
          :authorization => approval_response[:codigo_autorizacao]
        )
        else
          Response.new(
            approval_response[:aprovada],
            approval_response[:resultado],
            { :transaction_id => approval_response[:transacao] },
            :authorization => approval_response[:codigo_autorizacao]
          )
        end
      end

      def capture(money, authorization, options = {})
        binding.pry
          capture_response = gateway.capturar(authorization)
          if success?(capture_response)
            #response_to_spree(approval_response,capture_response)
          else
            Response.new false, approval_response[:resultado]
          end

      end

      def purchase(money, creditcard, options = {})
        approves_transaction(creditcard, options)
      end

      # testar ainda
      def credit(money, creditcard, options = {})
        credit_response = gateway.cancelar(creditcard.transacao_anterior)
        if credited?(credit_response)
          response_to_spree_to_credit(credit_response)
        else
          response_to_spree_to_credit(credit_response)
        end
      end

      #def create_profile(creditcard, gateway_options)
      #  if creditcard.gateway_customer_profile_id.nil?
      #    profile_hash = create_customer_profile(creditcard, gateway_options)
      #    creditcard.update_attributes(:gateway_customer_profile_id => profile_hash[:customer_profile_id], :gateway_payment_profile_id => profile_hash[:customer_payment_profile_id])
      #  end
      #end


  private

      def success?(response)
        response[:aprovada] || response[:capturado]
      end

      def gateway
        @gateway ||= AprovaFacil.new
      end

      def code_for_brand_of(creditcard)
        case CreditCard.type? creditcard.number
        when 'visa'             then AprovaFacil::CartaoCredito::Bandeira::VISA
        when 'master'           then AprovaFacil::CartaoCredito::Bandeira::MASTERCARD
        when 'american_express' then AprovaFacil::CartaoCredito::Bandeira::AMEX
        when 'diners_club'      then AprovaFacil::CartaoCredito::Bandeira::DINERS
        end
      end

      def last_digits_from(string)
        string[-2,2]
      end

      def creditcard_month(month)
        if month.to_i < 10
          "0#{month}"
        else
          month
        end
      end

      def full_name_from(creditcard)
        "#{creditcard[:first_name]} #{creditcard[:last_name]}"
      end

      def add_creditcard(creditcard, options = {})
        AprovaFacil::CartaoCredito.new(
         :valor            => options[:subtotal].to_f / 100,
         :numero_cartao    => creditcard.number,
         :codigo_seguranca => creditcard.verification_value,
         :mes_validade     => creditcard_month(creditcard.month),
         :ano_validade     => last_digits_from(creditcard.year),
         :bandeira         => code_for_brand_of(creditcard),
         :ip_comprador     => options[:ip],
         :nome_portador    => full_name_from(creditcard)
        )
      end

      def response_to_spree(approval_response,capture_response)
        Response.new(
          capture_response[:capturado],
          capture_response[:resultado],
          { :transaction_id => approval_response[:transacao] },
          :authorization => approval_response[:codigo_autorizacao]
        )
      end

      def approves_transaction(creditcard, options)
        card = add_creditcard(creditcard,options)

        approval_response = gateway.aprovar(card)
        if success?(approval_response)
          capture_response = gateway.capturar(approval_response[:transacao])
          if success?(capture_response)
            response_to_spree(approval_response,capture_response)
          else
            response_to_spree(approval_response,capture_response)
          end
        else
          Response.new false, approval_response[:resultado]
        end
      end

    end
  end
end

