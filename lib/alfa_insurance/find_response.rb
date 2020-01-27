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
      risk_values.keys
    end

    def risk_value
      @risk_value ||= risk_values.values.inject(&:+)
    end

    def risk_values
      @risk_values ||= risk_values_from(policy)
    end

  private

    def policy
      @policy ||= body[:policy_information] || {}
    end
  end
end
