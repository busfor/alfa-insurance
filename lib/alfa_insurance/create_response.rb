module AlfaInsurance
  class CreateResponse < CalculateResponse
    def insurance_id
      body[:policy_id].to_i
    end
  end
end
