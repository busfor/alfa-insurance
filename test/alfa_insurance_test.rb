require 'test_helper'

describe AlfaInsurance do
  before(:each) do
    @client = AlfaInsurance::BusClient.new(operator: 'TestBusOperator', product_code: 'TEST-BUS', debug: false)
  end

  def use_vcr_cassette(name)
    VCR.use_cassette(name, match_requests_on: [:method, :uri, :body]) do
      yield
    end
  end

  it '#calculate' do
    ticket_issue_date = Date.new(2018, 6, 13)
    total_cost = Money.from_amount(480, 'RUB')

    response =
      use_vcr_cassette('calculate') do
        @client.calculate(total_cost, ticket_issue_date)
      end

    assert_equal AlfaInsurance::CalculateResponse, response.class
      assert_equal true, response.success?
      assert_equal 20.0, response.cost.to_f
      assert_equal Money.from_amount(20, 'RUB'), response.cost
      assert_equal Money.from_amount(100_000, 'RUB'), response.risk_value
      assert_equal Money.from_amount(100_000, 'RUB'), response.risk_values['RISK_NS']
      assert_equal ['RISK_NS'], response.risk_types
      assert_equal 'RISK_NS', response.risk_type
  end

  it '#create' do
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
          arrival_at: DateTime.parse('2018-06-25 00:00:00+03:00'),
          departure_station: 'Moscow',
          departure_at: DateTime.parse('2018-06-24 12:00:00+03:00')
        )
      ],
      total_value: Money.from_amount(480, 'RUB'),
      customer_phone: '+79161234567',
      customer_email: 'text@example.com'
    )
    ticket_issue_date = Date.new(2018, 6, 13)

    response =
      use_vcr_cassette('create') do
        @client.create(insurance_request, ticket_issue_date)
      end

    assert_equal AlfaInsurance::CreateResponse, response.class
    assert_equal true, response.success?
    assert_equal Money.from_amount(20, 'RUB'), response.cost
    assert_equal Money.from_amount(100_000, 'RUB'), response.risk_value
    assert_equal Money.from_amount(100_000, 'RUB'), response.risk_values['RISK_NS']
    assert_equal ['RISK_NS'], response.risk_types
    assert_equal 'RISK_NS', response.risk_type
    assert_equal 26784313, response.insurance_id
  end

  it '#find' do
    response =
      use_vcr_cassette('find') do
        @client.find(26784313)
      end

    assert_equal true, response.success?
    assert_equal AlfaInsurance::FindResponse, response.class
    assert_equal Money.from_amount(20, 'RUB'), response.cost
    assert_equal Money.from_amount(100_000, 'RUB'), response.risk_value
    assert_equal Money.from_amount(100_000, 'RUB'), response.risk_values['RISK_NS']
    assert_equal ['RISK_NS'], response.risk_types
    assert_equal 'RISK_NS', response.risk_type
    assert_equal 26784313, response.insurance_id
    assert_equal 'ISSUING', response.state
  end

  it '#find when multiple risc currencies' do
    # used prod config to reproduce a bug and write this case to vcr cassette
    client = AlfaInsurance::BusClient.new(
      operator: 'BUSFOR',
      product_code: 'ON_BUS_BUSFOR_OR',
      wsdl: "https://vesta.alfastrah.ru/travel-ext-services/TravelExtService?wsdl",
      debug: false,
    )

    response =
      use_vcr_cassette('find_with_multiple_risc_currencies') do
        client.find(46596394)
      end

    assert_equal true, response.success?
    assert_equal Money.from_amount(252500, 'RUB'), response.risk_value
    assert_equal ["RISK_NSP", "RISK_NS", "RISK_FLIGHT_DELAYS_PERSONAL"], response.risk_types
    assert_equal 'RISK_NSP', response.risk_type
    assert_equal 46596394, response.insurance_id
    assert_equal 'CONFIRMED', response.state
  end

  it '#confirm' do
    response =
      use_vcr_cassette('confirm') do
        @client.confirm(26784313)
      end

    assert_equal true, response.success?
    assert_equal AlfaInsurance::ConfirmResponse, response.class
    assert_equal 26784313, response.insurance_id
    assert_equal 'https://uat-tes.alfastrah.ru/travel-ext-services/reports?parameters=7962FF73070639FEBDCB65C388E284FC2E5FD14B0EE30AE35817FECB2C91604CAAC3034F9B0B6E263831B22E793C176A', response.document_url
  end

  it '#cancel' do
    response =
      use_vcr_cassette('cancel') do
        @client.cancel(26784313)
      end

    assert_equal true, response.success?
    assert_equal AlfaInsurance::Response, response.class
  end

  describe "errors" do
    it 'in find' do
      response =
        use_vcr_cassette('find_error') do
          @client.find(123)
        end

      assert_equal false, response.success?
      assert_equal 'POLICY_NOT_FOUND', response.error_code
      assert_equal 'Can`t find policy with UID: 123 or Policy not allowed to Agent with Code: TestBusAgent', response.error_description
    end

    it 'in confirm' do
      response =
        use_vcr_cassette('confirm_error') do
          @client.confirm(123)
        end

      assert_equal false, response.success?
      assert_equal 'POLICY_NOT_FOUND', response.error_code
      assert_equal 'Can`t find policy with UID: 123 or Policy not allowed to Agent with Code: TestBusAgent', response.error_description
    end

    it 'in calculate' do
      response =
        use_vcr_cassette('calculate_error') do
          @client.calculate(-100, Date.new(2018, 6, 13))
        end

      assert_equal false, response.success?
      assert_equal 'CALCULATION_ERROR', response.error_code
      assert_equal 'Error: Can`t calculate policy', response.error_description
    end

    it 'in create' do
      response =
        use_vcr_cassette('create_error') do
          @client.create(
            AlfaInsurance::BusInsuranceRequest.new(bus_segments: []),
            Date.new(2018, 6, 13),
          )
        end

      assert_equal false, response.success?
      assert_equal 'BAD_PARAMETER', response.error_code
      assert_equal 'List of INSURED_FIRST_NAME contains null or empty values', response.error_description
    end
  end
end
