# frozen_string_literal: true

require_relative 'model/contacts'
require_relative 'model/querents'
require_relative 'model/patient'
require_relative 'model/patients_summary'
require_relative 'model/user'

Plugin.create(:covid19) do
  @url = Diva::URI('https://raw.githubusercontent.com/tokyo-metropolitan-gov/covid19/staging/data/data.json')
  @datasources = {
    covid19_contacts:         '新型コロナコールセンター相談件数',
    covid19_querents:         '帰国者・接触者センター相談件数',
    covid19_patients:         '罹患者',
    covid19_patients_summary: '陽性患者数',
  }.freeze

  defspell(:around_message, :covid19_patient) do |patient|
    Delayer::Deferred.new(true).tap do |promise|
      promise.call(patient.around)
    end
  end

  filter_extract_datasources do |dss|
    [{ **dss,  **@datasources }]
  end

  filter_skin_get do |fn, fallback_dirs|
    if File.basename(fn, '.*') == 'covid19'
      fallback_dirs << File.join(__dir__, 'skin')
    end
    [fn, fallback_dirs]
  end

  def update(res)
    case JSON.parse(res.body, symbolize_names: true)
    in {
      contacts:         {data: contacts},
      querents:         {data: querents},
      patients:         {data: patients},
      patients_summary: {data: patients_summaries} }
      Plugin.call(:extract_receive_message, :covid19_contacts, contacts.map{|c| Plugin::Covid19::Contact.new(c) })
      Plugin.call(:extract_receive_message, :covid19_querents, contacts.map{|c| Plugin::Covid19::Querent.new(c) })

      Plugin.call(:extract_receive_message, :covid19_patients, gen_patients(patients))
      Plugin.call(:extract_receive_message, :covid19_patients_summary, patients_summaries.map{|c| Plugin::Covid19::PatientsSummary.new(c) })
    end
  end

  def gen_patients(source)
    patients = source.map.with_index{|c, i| Plugin::Covid19::Patient.new({**c, number: i + 1}) }.to_a
    patients.each do |patient|
      patient.receive_user_idnames.each { |number| notice number;patient.add_parent(patients[number - 1]) }
    end
    patients
  end

  def create_tab(name, datasources)
    Plugin.call(:extract_tab_create, {
                  name: name,
                  slug: SecureRandom.uuid,
                  sources: datasources,
                  icon: Skin[:covid19].uri,
                })
  end

  def polling
    Delayer.new do
      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = @url.scheme == 'https'

      res = http.request(Net::HTTP::Get.new(@url.path))
      case res
      when Net::HTTPSuccess     # 2xx
        update(res)
      else                      # それ以外の場合、人類が滅びたことにする
        Plugin.call(:apocalypse)
      end

      Reserver.new(3600, &method(:polling))
    end
  end
  polling

  unless at(:infected)
    create_tab('COVID19', @datasources.keys)
    store(:infected, true)
  end
end
