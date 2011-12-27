#encoding: utf-8
begin
  require "aprova_facil"
rescue LoadError
  raise "Could not load the aprova_facil gem.  Use `gem install aprova_facil` to install it."
end
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class AprovaFacilGateway < Gateway
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = ['BR']
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = [:visa, :master, :american_express, :discover]
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.cobrebem.com/'
      
      # The name of the gateway
      self.display_name = 'Aprova Fácil'
      
      def initialize(options = {})
        requires!(options, :login)
        @options = options
        super

        AprovaFacil::Config.usuario = @options[:login]
        
        if @options[:test]
          AprovaFacil::Config.teste = true
        end
      end  
      
      def authorize(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)             
        add_customer_data(post, options)
        
        commit('authonly', money, post)
      end
      
      def purchase(money, creditcard, options = {})
        post = {}
        add_invoice(post, options)
        add_creditcard(post, creditcard)        
        add_customer_data(post, options)
             
        commit('sale', money, post)
      end                       
    
      def capture(money, authorization, options = {})
        post = {:transaction => authorization}
        commit('capture', money, post)
      end

      def void(authorization, options = {})
        post = {:transaction => authorization}
        commit('void', nil, post)
      end
    
      private                       
      
      def add_customer_data(post, options)
        if options.has_key? :email
          post[:email] = options[:email]
          post[:email_customer] = false
        end

        if options.has_key? :ip
          post[:ip_comprador] = options[:ip]
        end
      end

      def add_invoice(post, options)
        post[:documento] = options[:order_id]
      end
      
      def add_creditcard(post, creditcard)  
        post[:numero_cartao]   = creditcard.number
        post[:codigo_seguranca]  = creditcard.verification_value if creditcard.verification_value?
        post[:ano_validade]   = creditcard.year.to_s[-2,2]
        post[:mes_validade]   = sprintf("%.2i",creditcard.month).to_s
        post[:nome_portador] = "#{creditcard.first_name}  #{creditcard.last_name}"
        post[:bandeira] = code_for_brand_of creditcard
      end


      
      def commit(action, money, parameters)

        parameters[:valor] = format_amount(money.to_f)

        cartao = AprovaFacil::CartaoCredito.new(parameters)

        case action
        when 'authonly'
          resultado = gateway.aprovar(cartao)
          parameters[:transaction] = resultado[:transacao]
        when 'sale'
          resultado = gateway.aprovar(cartao)
          if resultado[:aprovada]
            resultado = resultado.merge gateway.capturar(resultado[:transacao])
            parameters[:transaction] = resultado[:transacao]
          end

        when 'capture'
          resultado = gateway.capturar(parameters[:transaction])
        when 'void'
          resultado = gateway.cancelar parameters[:transaction]
        end


        Response.new(success?(resultado), resultado[:resultado], {:transaction_id => parameters[:transaction]} , 
          :test => test?, 
          :authorization => resultado[:codigo_autorizacao]
        )
      end

      def message_from(response)
      end
      
      def post_data(action, parameters = {})
      end

      private

      def gateway
        @gateway ||= AprovaFacil.new
      end

      def success?(response)
        response[:aprovada] || response[:capturado] || response[:cancelado]
      end

      def format_amount(amount)
        amount / 100
      end

      def code_for_brand_of(creditcard)
        case CreditCard.type? creditcard.number
        when 'visa'             then AprovaFacil::CartaoCredito::Bandeira::VISA
        when 'master'           then AprovaFacil::CartaoCredito::Bandeira::MASTERCARD
        when 'american_express' then AprovaFacil::CartaoCredito::Bandeira::AMEX
        when 'diners_club'      then AprovaFacil::CartaoCredito::Bandeira::DINERS
        end
      end
    end
  end
end
