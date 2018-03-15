module AlfaInsurance
  class ConfirmResponse < CalculateResponse
    def insurance_id
      body[:full_number].to_i
    end

    def document_url
      body.dig(:policy_document, :url)
    end
  end
end
