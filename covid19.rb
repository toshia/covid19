# frozen_string_literal: true

require_relative 'model/contacts'
require_relative 'model/user'

Plugin.create(:covid19) do
  @url = Diva::URI('https://raw.githubusercontent.com/tokyo-metropolitan-gov/covid19/staging/data/data.json')

  filter_extract_datasources do |dss|
    [{
       **dss,
       covid19_contacts: '新型コロナコールセンター相談件数',
     }]
  end

  def polling
    Delayer.new do
      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = @url.scheme == 'https'

      res = http.request(Net::HTTP::Get.new(@url.path))
      case res
      when Net::HTTPSuccess     # 2xx
        contacts = JSON.parse(res.body, symbolize_names: true).dig(:contacts, :data)
        Plugin.call(:extract_receive_message, :covid19_contacts, contacts.map{|c| Plugin::Covid19::Contact.new(c) })
      else
        post_apocalypse
      end

      Reserver.new(3600, &method(:polling))
    end
  end
  polling
end
