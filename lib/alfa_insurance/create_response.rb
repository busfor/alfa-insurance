module AlfaInsurance
  class CreateResponse < CalculateResponse
    def insurance_id
      body[:policy_id].to_i
    end

    def cost
      Money.new(body.dig(:calculation_result, :premium), currency)
    end

    def risk_value
      Money.new(body.dig(:calculation_result, :risk_value_sum), currency)
    end

    def risk_type
      body.dig(:calculation_result, :risk_value, :@risk_type)
    end

  private

    def currency
      @currency ||= body.dig(:calculation_result, :currency)
    end
  end
end
