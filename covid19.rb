# frozen_string_literal: true

require_relative 'model/contacts'
require_relative 'model/patient'
require_relative 'model/patients_summary'
require_relative 'model/user'

Plugin.create(:covid19) do
  @url = Diva::URI('https://raw.githubusercontent.com/tokyo-metropolitan-gov/covid19/staging/data/data.json')

  filter_extract_datasources do |dss|
    [{
       **dss,
       covid19_contacts:         '新型コロナコールセンター相談件数',
       covid19_patients:         '罹患者',
       covid19_patients_summary: '陽性患者数',
     }]
  end

  def update(res)
    case JSON.parse(res.body, symbolize_names: true)
    in {
      contacts:         {data: contacts},
      patients:         {data: patients},
      patients_summary: {data: patients_summaries} }
      Plugin.call(:extract_receive_message, :covid19_contacts, contacts.map{|c| Plugin::Covid19::Contact.new(c) })
      Plugin.call(:extract_receive_message, :covid19_patients, patients.map.with_index{|c, i| Plugin::Covid19::Patient.new({**c, number: i + 1}) })
      Plugin.call(:extract_receive_message, :covid19_patients_summary, patients_summaries.map{|c| Plugin::Covid19::PatientsSummary.new(c) })
    end
  end

  def polling
    Delayer.new do
      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = @url.scheme == 'https'

      res = http.request(Net::HTTP::Get.new(@url.path))
      case res
      when Net::HTTPSuccess     # 2xx
        update(res)
      else
        post_apocalypse
      end

      Reserver.new(3600, &method(:polling))
    end
  end
  polling
end
