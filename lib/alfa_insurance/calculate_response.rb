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

    def risk_values
      @risk_values ||= risk_values_from(result)
    end

    def risk_types
      @risk_types ||= begin
        raw_values = result[:risk_value]
        raw_values = [raw_values] unless raw_values.is_a?(Array)
        raw_values.map { |raw_value| raw_value[:@risk_type] }
      end
    end

    private

    def risk_values_from(data)
      raw_values = [data[:risk_value]].flatten
      raw_currencies = [data[:risk_currency]].flatten

      risk_types.each_with_object({}) do |risk_type, result|
        value = raw_values.find { |raw| raw[:@risk_type] == risk_type }.fetch(:@value)
        currency = raw_currencies.find { |raw| raw[:@risk_type] == risk_type }.fetch(:@value)
        result[risk_type] = to_money(value, currency)
      end
    end

    def currency
      result[:currency]
    end

    def result
      @result ||= body[:calculation_result] || {}
    end
  end
end
