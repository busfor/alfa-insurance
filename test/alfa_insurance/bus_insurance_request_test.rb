require 'test_helper'

describe AlfaInsurance::BusInsuranceRequest do
  describe '#generate_xml' do
    before do
      @segment_data = {
        route_number: '33',
        place_number: '14',
        departure_station: 'Moscow',
        departure_at: DateTime.parse('2018-03-24 12:00:00+03:00'),
        arrival_station: 'Kiev',
        arrival_at: DateTime.parse('2018-03-25 10:00:00+03:00'),
        number: 1,
      }
      @request_data = {
        insured_first_name: 'Vassily',
        insured_last_name: 'Poupkine',
        insured_patronymic: 'Petrovitch',
        insured_birth_date: '1980-01-01',
        insured_document_type: 'passport',
        insured_document_number: '111222',
        insured_ticket_number: '444555',
        total_value: Money.from_amount(480, 'RUB'),
        customer_email: 'test@example.com',
        customer_phone: '+79161234567',
      }
      @ticket_issue_date = Date.parse('2018-03-23')
    end

    def build_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.root {
          yield(xml)
        }
      end
      builder.to_xml
    end

    it 'generates XML with all fields' do
      segment = AlfaInsurance::BusSegment.new(**@segment_data)
      request =
        AlfaInsurance::BusInsuranceRequest.new(
          **@request_data,
          bus_segments: [segment],
        )

      actual_xml = build_xml do |xml|
        request.generate_xml(xml, @ticket_issue_date)
      end

      expected_xml = <<~XML
        <?xml version="1.0"?>
        <root>
          <insuredFirstName>Vassily</insuredFirstName>
          <insuredLastName>Poupkine</insuredLastName>
          <insuredPatronymic>Petrovitch</insuredPatronymic>
          <insuredBirthDate>1980-01-01</insuredBirthDate>
          <insuredTicketNumber>444555</insuredTicketNumber>
          <insuredCount>1</insuredCount>
          <busSegmentRouteNumber seqNo="0">
            <value>33</value>
          </busSegmentRouteNumber>
          <busSegmentPlaceNumber seqNo="0">
            <value>14</value>
          </busSegmentPlaceNumber>
          <busSegmentDepartureStation seqNo="0">
            <value>Moscow</value>
          </busSegmentDepartureStation>
          <busSegmentDepartureDate seqNo="0">
            <value>2018-03-24</value>
          </busSegmentDepartureDate>
          <busSegmentDepartureTime seqNo="0">
            <value>12:00:00</value>
          </busSegmentDepartureTime>
          <busSegmentArrivalStation seqNo="0">
            <value>Kiev</value>
          </busSegmentArrivalStation>
          <busSegmentArrivalDate seqNo="0">
            <value>2018-03-25</value>
          </busSegmentArrivalDate>
          <busSegmentArrivalTime seqNo="0">
            <value>10:00:00</value>
          </busSegmentArrivalTime>
          <busSegmentNumber seqNo="0">
            <value>1</value>
          </busSegmentNumber>
          <busSegmentsCount>1</busSegmentsCount>
          <ticketInformation>
            <ticketTotalValue>480.0</ticketTotalValue>
            <ticketIssueDate>2018-03-23</ticketIssueDate>
          </ticketInformation>
          <customerPhoneType>MOBILE</customerPhoneType>
          <customerPhone>+79161234567</customerPhone>
          <customerEmail>test@example.com</customerEmail>
        </root>
      XML

      assert_equal expected_xml, actual_xml
    end

    it 'skips value tags for empty fields' do
      # запрос не содержит arrival_at
      segment_data = @segment_data.merge(arrival_at: nil)
      segment = AlfaInsurance::BusSegment.new(**segment_data)
      request =
        AlfaInsurance::BusInsuranceRequest.new(
          **@request_data,
          bus_segments: [segment],
        )

      actual_xml = build_xml do |xml|
        request.generate_xml(xml, @ticket_issue_date)
      end

      # busSegmentArrivalDate и busSegmentArrivalTime не должны содержать тега value
      expected_xml = <<~XML
        <?xml version="1.0"?>
        <root>
          <insuredFirstName>Vassily</insuredFirstName>
          <insuredLastName>Poupkine</insuredLastName>
          <insuredPatronymic>Petrovitch</insuredPatronymic>
          <insuredBirthDate>1980-01-01</insuredBirthDate>
          <insuredTicketNumber>444555</insuredTicketNumber>
          <insuredCount>1</insuredCount>
          <busSegmentRouteNumber seqNo="0">
            <value>33</value>
          </busSegmentRouteNumber>
          <busSegmentPlaceNumber seqNo="0">
            <value>14</value>
          </busSegmentPlaceNumber>
          <busSegmentDepartureStation seqNo="0">
            <value>Moscow</value>
          </busSegmentDepartureStation>
          <busSegmentDepartureDate seqNo="0">
            <value>2018-03-24</value>
          </busSegmentDepartureDate>
          <busSegmentDepartureTime seqNo="0">
            <value>12:00:00</value>
          </busSegmentDepartureTime>
          <busSegmentArrivalStation seqNo="0">
            <value>Kiev</value>
          </busSegmentArrivalStation>
          <busSegmentArrivalDate seqNo="0"/>
          <busSegmentArrivalTime seqNo="0"/>
          <busSegmentNumber seqNo="0">
            <value>1</value>
          </busSegmentNumber>
          <busSegmentsCount>1</busSegmentsCount>
          <ticketInformation>
            <ticketTotalValue>480.0</ticketTotalValue>
            <ticketIssueDate>2018-03-23</ticketIssueDate>
          </ticketInformation>
          <customerPhoneType>MOBILE</customerPhoneType>
          <customerPhone>+79161234567</customerPhone>
          <customerEmail>test@example.com</customerEmail>
        </root>
      XML

      assert_equal expected_xml, actual_xml
    end
  end
end
