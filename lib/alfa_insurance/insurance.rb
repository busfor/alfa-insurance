module AlfaInsurance
  class BusSegment
    attr_reader :route_number,
                :place_number,
                :departure_station,
                :departure_at,
                :arrival_station,
                :arrival_at,
                :number

    def initialize(params = {})
      params.each do |attr, value|
        instance_variable_set("@#{attr}", value)
      end
    end

    def departure_date
      departure_at && departure_at.to_date.iso8601
    end

    def departure_time
      departure_at && departure_at.strftime("%H:%M:%S")
    end

    def arrival_date
      arrival_at && arrival_at.to_date.iso8601
    end

    def arrival_time
      arrival_at && arrival_at.strftime("%H:%M:%S")
    end
  end

  class BusInsuranceRequest
    attr_reader :insured_first_name,
                :insured_last_name,
                :insured_patronymic,
                :insured_birth_date,
                :insured_document_type,
                :insured_document_number,
                :insured_ticket_number,
                :bus_segments,
                :total_value,
                :customer_email,
                :customer_phone

    def initialize(params = {})
      params.each do |attr, value|
        instance_variable_set("@#{attr}", value)
      end
    end

    def generate_xml(xml, ticket_issue_date)
      xml.insuredFirstName(insured_first_name)
      xml.insuredLastName(insured_last_name)
      xml.insuredPatronymic(insured_patronymic)
      xml.insuredBirthDate(insured_birth_date)
      xml.insuredTicketNumber(insured_ticket_number)
      xml.insuredCount(1)
      bus_segments.each_with_index do |segment, index|
        xml.busSegmentRouteNumber(seqNo: index) {
          xml.value(segment.route_number) if present?(segment.route_number)
        }
        xml.busSegmentPlaceNumber(seqNo: index) {
          xml.value(segment.place_number) if present?(segment.place_number)
        }
        xml.busSegmentDepartureStation(seqNo: index) {
          xml.value(segment.departure_station) if present?(segment.departure_station)
        }
        xml.busSegmentDepartureDate(seqNo: index) {
          xml.value(segment.departure_date) if present?(segment.departure_date)
        }
        xml.busSegmentDepartureTime(seqNo: index) {
          xml.value(segment.departure_time) if present?(segment.departure_time)
        }
        xml.busSegmentArrivalStation(seqNo: index) {
          xml.value(segment.arrival_station) if present?(segment.arrival_station)
        }
        xml.busSegmentArrivalDate(seqNo: index) {
          xml.value(segment.arrival_date) if present?(segment.arrival_date)
        }
        xml.busSegmentArrivalTime(seqNo: index) {
          xml.value(segment.arrival_time) if present?(segment.arrival_time)
        }
        xml.busSegmentNumber(seqNo: index) {
          xml.value(segment.number) if present?(segment.number)
        }
      end
      xml.busSegmentsCount(bus_segments.size)
      xml.ticketInformation {
        xml.ticketTotalValue(total_value.to_f)
        xml.ticketIssueDate(ticket_issue_date.iso8601)
      }
      xml.customerPhoneType 'MOBILE'
      xml.customerPhone customer_phone
      xml.customerEmail customer_email
      xml
    end

    private

    def present?(value)
      !value.nil? && value != ''
    end
  end
end
