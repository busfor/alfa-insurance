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

    def to_money(amount, currency)
      Money.from_amount(amount.to_f, currency)
    end
  end
end
