module AlfaInsurance
  class BasePolicy
    SANDBOX_WSDL = 'https://uat-tes.alfastrah.ru/travel-ext-services/TravelExtService?wsdl'.freeze

    attr_accessor :log, :log_level, :operator, :product_code, :wsdl

    def initialize(debug: false, wsdl: SANDBOX_WSDL, operator:, product_code:)
      if debug
        @log_level = :debug
        @log = true
      else
        @log = false
      end
      @wsdl = wsdl
      @operator = operator
      @product_code = product_code
    end

    def calculate(*)
      raise NotImplementedError
    end

    def create(*)
      raise NotImplementedError
    end

    def confirm(insurance_id)
      response = send_soap_request(:confirm_policy) do |xml|
        xml.operator { xml.code(operator) }
        xml.policyId(insurance_id)
      end
      ConfirmResponse.new(response)
    end

    def cancel(insurance_id)
      response = send_soap_request(:cancel_policy) do |xml|
        xml.operator { xml.code(operator) }
        xml.policyId(insurance_id)
      end
      Response.new(response)
    end

    def find(insurance_id)
      response = send_soap_request(:get_policy) do |xml|
        xml.operator { xml.code(operator) }
        xml.policyId(insurance_id)
      end
      FindResponse.new(response)
    end

  private

    def send_soap_request(action_name)
      message = Nokogiri::XML::Builder.new do |xml|
        xml.root {
          yield(xml)
        }
      end
      payload = apply_namespace(message, action_name)
      soap_client.call(action_name, message: payload)
    end

    def soap_client
      @client ||= Savon.client(wsdl: wsdl, log_level: log_level, log: log)
    end

    def action_namespace(action)
      soap_client.wsdl.operations[action][:namespace_identifier]
    end

    def apply_namespace(xml_builder, action)
      namespace = action_namespace(action)

      xml_text = xml_builder.doc.root.inner_html
      xml_text.gsub!('</', "</#{namespace}:")
      xml_text.gsub!(%r{<(?!/)}, "<#{namespace}:")
      xml_text
    end
  end
end
