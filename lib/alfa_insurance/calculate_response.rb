module AlfaInsurance
  class CalculateResponse < Response
    def cost
      Money.from_amount(body.dig(:calculation_result, :premium).to_f, currency)
    end

    def risk_value
      Money.from_amount(body.dig(:calculation_result, :risk_value_sum).to_f, currency)
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
