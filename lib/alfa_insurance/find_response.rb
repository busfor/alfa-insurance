module AlfaInsurance
  class FindResponse < CalculateResponse
    def insurance_id
      body.dig(:policy_information, :policy_id).to_i
    end

    def cost
      Money.new(body.dig(:policy_information, :rate), currency)
    end

    def risk_value
      Money.new(body.dig(:policy_information, :risk_value, :@value), risk_currency)
    end

    def risk_type
      body.dig(:policy_information, :risk_value, :@risk_type)
    end

    def state
      body.dig(:policy_information, :policy_status)
    end

  private

    def risk_currency
      @risk_currency ||= body.dig(:policy_information, :risk_currency, :@value)
    end

    def currency
      @currency ||= body.dig(:policy_information, :currency)
    end
  end
end
