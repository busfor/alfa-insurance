module AlfaInsurance
  class BusClient < BaseClient
    def calculate(total_cost)
      response = send_soap_request(:create_policy) do |xml|
        xml.operator { xml.code(operator) }
        xml.product { xml.code(product_code) }
        xml.policyParameters {
          xml.ticketInformation {
            xml.ticketTotalValue(total_cost.to_f)
          }
        }
      end
      CalculateResponse.new(response)
    end

    def create(insurance_object)
      raise ArgumentError, "BusInsuranceRequest is expected" unless insurance_object.is_a?(BusInsuranceRequest)
      response = send_soap_request(:create_policy) do |xml|
        xml.operator { xml.code(operator) }
        xml.product { xml.code(product_code) }
        xml.policyParameters { insurance_object.generate_xml(xml) }
      end
      CreateResponse.new(response)
    end
  end
end
