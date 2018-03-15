require 'test_helper'

describe AlfaInsurance do
  before(:each) do
    @client = AlfaInsurance::BusPolicy.new(operator: 'TestBusOperator', product_code: 'TEST-BUS', debug: true)
  end

  it '#calculate' do
    VCR.use_cassette("calculate") do
      response = @client.calculate(480)
      assert_equal AlfaInsurance::CalculateResponse, response.class
      assert_equal true, response.success?
      assert_equal Money.new(20, 'RUB'), response.cost
      assert_equal Money.new(100000, 'RUB'), response.risk_value
      assert_equal 'RISK_NS', response.risk_type
    end
  end

  it '#create' do
    VCR.use_cassette("create") do
      insurance_request = AlfaInsurance::BusInsuranceRequest.new(
        insured_first_name: 'Vassily',
        insured_last_name: 'Poupkine',
        insured_patronymic: 'Petrovitch',
        insured_birth_date: '1980-01-01',
        bus_segments: [
          AlfaInsurance::BusSegment.new(
            number: 1,
            route_number: 33,
            place_number: 14,
            arrival_station: 'Kiev',
            arrival_at: DateTime.parse('2018-03-25 00:00:00+03:00'),
            departure_station: 'Moscow',
            departure_at: DateTime.parse('2018-03-24 12:00:00+03:00')
          )
        ],
        total_value: Money.new(480, 'RUB'),
        customer_phone: '+79161234567',
        customer_email: 'text@example.com'
      )
      response = @client.create(insurance_request)
      assert_equal AlfaInsurance::CreateResponse, response.class
      assert_equal true, response.success?
      assert_equal Money.new(20, 'RUB'), response.cost
      assert_equal Money.new(100000, 'RUB'), response.risk_value
      assert_equal 'RISK_NS', response.risk_type
      assert_equal 26613228, response.insurance_id
    end
  end

  it '#find' do
    VCR.use_cassette("find") do
      response = @client.find(26609882)
      assert_equal true, response.success?
      assert_equal AlfaInsurance::FindResponse, response.class
      assert_equal Money.new(20, 'RUB'), response.cost
      assert_equal Money.new(100000, 'RUB'), response.risk_value
      assert_equal 'RISK_NS', response.risk_type
      assert_equal 26609882, response.insurance_id
      assert_equal 'ISSUING', response.state
    end
  end

  it '#confirm' do
    VCR.use_cassette("confirm") do
      response = @client.confirm(26609882)
      assert_equal true, response.success?
      assert_equal AlfaInsurance::ConfirmResponse, response.class
      assert_equal 26609882, response.insurance_id
      assert_equal 'https://uat-tes.alfastrah.ru/travel-ext-services/reports?parameters=F30036CA8C9702F23851FC1FD42C48DFBCA1659A0596B2CBC20E3B1DA245709EAAC3034F9B0B6E263831B22E793C176A', response.document_url
    end
  end

  it '#cancel' do
    VCR.use_cassette("cancel") do
      response = @client.cancel(26609882)
      assert_equal true, response.success?
      assert_equal AlfaInsurance::Response, response.class
    end
  end

  describe "errors" do
    it 'in find' do
      VCR.use_cassette("find_error") do
        response = @client.find(123)
        assert_equal false, response.success?
        assert_equal 'POLICY_NOT_FOUND', response.error_code
        assert_equal 'Can`t find policy with UID: 123 or Policy not allowed to Agent with Code: TestBusAgent', response.error_description
      end
    end

    it 'in confirm' do
      VCR.use_cassette("confirm_error") do
        response = @client.confirm(123)
        assert_equal false, response.success?
        assert_equal 'POLICY_NOT_FOUND', response.error_code
        assert_equal 'Can`t find policy with UID: 123 or Policy not allowed to Agent with Code: TestBusAgent', response.error_description
      end
    end

    it 'in calculate' do
      VCR.use_cassette("calculate_error") do
        response = @client.calculate(-100)
        assert_equal false, response.success?
        assert_equal 'CALCULATION_ERROR', response.error_code
        assert_equal 'Error: Can`t calculate policy', response.error_description
      end
    end

    it 'in create' do
      VCR.use_cassette("create_error") do
    
        response = @client.create(AlfaInsurance::BusInsuranceRequest.new(bus_segments: []))
        assert_equal false, response.success?
        assert_equal 'BAD_PARAMETER', response.error_code
        assert_equal 'List of INSURED_FIRST_NAME contains null or empty values', response.error_description
      end
    end
  end
end
