module AlfaInsurance
  class Response
    def initialize(soap_response)
      @raw_response = soap_response
    end

    def success?
      body.dig(:return_code, :code) == 'OK'
    end

    def error_code
      body.dig(:return_code, :code) unless success?
    end

    def error_description
      body.dig(:return_code, :error_message) unless success?
    end

    def body
      @body ||= @raw_response.body.values.first
    end

    private

    def risk_values_from(data, currency: nil)
      raw_values = data[:risk_value]
      raw_values = [raw_values] unless raw_values.is_a?(Array)

      raw_values.each_with_object({}) do |item, result|
        risk_type = item[:@risk_type]
        risk_value = item[:@value]
        value_currency = currency || risk_currency(risk_type)
        result[risk_type] = to_money(risk_value, value_currency)
      end
    end

    def to_money(amount, currency)
      Money.from_amount(amount.to_f, currency)
    end

    def risk_currency(risk_type)
      risk_currency_data = policy.dig(:risk_currency)
      if risk_currency_data.is_a?(Array)
        risk_currency_data.find { |currency_hash| currency_hash[:@risk_type] == risk_type }[:@value]
      else
        risk_currency_data[:@value]
      end
    end
  end
end
