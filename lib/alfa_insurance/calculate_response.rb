module AlfaInsurance
  class CalculateResponse < Response
    def cost
      Money.from_amount(body.dig(:calculation_result, :premium).to_f, currency)
    end

    def risk_value
      Money.from_amount(body.dig(:calculation_result, :risk_value_sum).to_f, currency)
    end

    def risk_type
      warn "[DEPRECATION] `risk_type` is deprecated.  Please use `risk_types` instead."
      risk_types.first
    end

    def risk_types
      risk_values = body.dig(:calculation_result, :risk_value)
      risk_values = [risk_values] unless risk_values.is_a?(Array)
      risk_values.compact.map { |item| item[:@risk_type] }
    end

  private

    def currency
      @currency ||= body.dig(:calculation_result, :currency)
    end
  end
end
