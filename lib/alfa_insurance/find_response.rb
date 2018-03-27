module AlfaInsurance
  class FindResponse < CalculateResponse
    def insurance_id
      body.dig(:policy_information, :policy_id).to_i
    end

    def cost
      Money.from_amount(body.dig(:policy_information, :rate).to_f, currency)
    end

    def risk_value
      Money.from_amount(body.dig(:policy_information, :risk_value, :@value).to_f, risk_currency)
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
