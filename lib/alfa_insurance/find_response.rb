module AlfaInsurance
  class FindResponse < CalculateResponse
    def insurance_id
      result[:policy_id].to_i
    end

    def state
      result[:policy_status]
    end

    def cost
      @cost ||= to_money(result[:rate], result[:currency])
    end

    def risk_type
      warn "[DEPRECATION] `risk_type` is deprecated.  Please use `risk_types` instead."
      risk_types.first
    end

    def risk_value
      @risk_value ||= risk_values.values.inject(&:+)
    end

    private

    def result
      @result ||= body[:policy_information] || {}
    end
  end
end
