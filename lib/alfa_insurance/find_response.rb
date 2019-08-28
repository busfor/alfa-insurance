module AlfaInsurance
  class FindResponse < CalculateResponse
    def insurance_id
      policy[:policy_id].to_i
    end

    def state
      policy[:policy_status]
    end

    def cost
      @cost ||= to_money(policy[:rate], policy[:currency])
    end

    def risk_type
      warn "[DEPRECATION] `risk_type` is deprecated.  Please use `risk_types` instead."
      risk_types.first
    end

    def risk_types
      [policy[:risk_list]].flatten
    end

    def risk_value
      @risk_value ||= risk_values.values.inject(&:+)
    end

    def risk_values
      @risk_values ||= risks_from_raw(policy)
    end

    private

    def risks_from_raw(data)
      risk_types = [data[:risk_list]].flatten
      raw_values = [data[:risk_value]].flatten
      raw_currencies = [data[:risk_currency]].flatten

      risk_types.each_with_object({}) do |risk_type, result|
        risk_value = raw_values.find { |raw| raw[:@risk_type] == risk_type }.fetch(:@value)
        risk_currency = raw_currencies.find { |raw| raw[:@risk_type] == risk_type }.fetch(:@value)
        result[risk_type] = to_money(risk_value, risk_currency)
      end
    end

    def policy
      @policy ||= body[:policy_information] || {}
    end
  end
end
