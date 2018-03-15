module AlfaInsurance
  class CalculateResponse < Response
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
