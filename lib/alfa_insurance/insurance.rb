module AlfaInsurance
  class BusSegment
    attr_accessor :route_number,
                  :place_number,
                  :departure_station,
                  :departure_at,
                  :arrival_station,
                  :arrival_at,
                  :number

    def initialize(params = {})
      params.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
  end

  class BusInsuranceRequest
    attr_accessor :insured_first_name,
      :insured_last_name,
      :insured_patronymic,
      :insured_birth_date,
      :insured_document_type,
      :insured_document_number,
      :bus_segments,
      :total_value,
      :customer_email,
      :customer_phone

    def initialize(params = {})
      params.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end

    def generate_xml(xml)
      xml.insuredFirstName(insured_first_name)
      xml.insuredLastName(insured_last_name)
      xml.insuredPatronymic(insured_patronymic)
      xml.insuredBirthDate(insured_birth_date)
      xml.insuredCount(1)
#      xml.insuredDocumentType(insured_document_type)
#      xml.insuredDocumentNumber(insured_document_number)
      bus_segments.each_with_index do |segment, index|
        xml.busSegmentRouteNumber(seqNo: index) {
          xml.value(segment.route_number)
        }
        xml.busSegmentPlaceNumber(seqNo: index) {
          xml.value(segment.place_number)
        }
        xml.busSegmentDepartureStation(seqNo: index) {
          xml.value(segment.departure_station)
        }
        xml.busSegmentDepartureDate(seqNo: index) {
          xml.value(segment.departure_at.to_date.iso8601)
        }
        xml.busSegmentDepartureTime(seqNo: index) {
          xml.value(segment.departure_at.strftime("%H:%M:%S"))
        }
        xml.busSegmentArrivalStation(seqNo: index) {
          xml.value(segment.arrival_station)
        }
        xml.busSegmentArrivalDate(seqNo: index) {
          xml.value(segment.arrival_at.to_date.iso8601)
        }
        xml.busSegmentArrivalTime(seqNo: index) {
          xml.value(segment.arrival_at.strftime("%H:%M:%S"))
        }
        xml.busSegmentNumber(seqNo: index) {
          xml.value(segment.number)
        }
      end
      xml.busSegmentsCount(bus_segments.size)
      xml.ticketInformation {
          xml.ticketTotalValue(total_value.to_f)
        }
      xml.customerPhoneType 'MOBILE'
      xml.customerPhone customer_phone
      xml.customerEmail customer_email
      xml
    end
  end
end
