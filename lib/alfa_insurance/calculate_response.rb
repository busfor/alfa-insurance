module AlfaInsurance
  class CalculateResponse < Response
    def cost
      @cost ||= to_money(result[:premium], currency)
    end

    def risk_value
      @risk_value ||= to_money(result[:risk_value_sum], currency)
    end

    def risk_type
      warn "[DEPRECATION] `risk_type` is deprecated.  Please use `risk_types` instead."
      risk_types.first
    end

    def risk_types
      risk_values.keys
    end

    def risk_values
      @risk_values ||= risk_values_from(result, currency: currency)
    end

  private

    def currency
      result[:currency]
    end

    def result
      @result ||= body[:calculation_result] || {}
    end
  end
end
