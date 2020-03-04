# frozen_string_literal: true

module Plugin::Covid19
  # 陽性患者数
  # /patients_summary/data/0/
  class PatientsSummary < Diva::Model
    include Diva::Model::MessageMixin

    register :covid19_contact, name: "陽性患者数", timeline: true, reply: false, myself: false

    field.time :日付, required: true
    field.int :小計, required: true

    def user
      Plugin::Covid19::User.new(name: "陽性患者数")
    end

    def description
      [
        '%{amount} 人' % {amount: 小計},
      ].join("\n")
    end

    def created
      日付
    end

    def path
      '/%{year}/%{month}/%{day}' % {year: 日付.year, month: 日付.month, day: 日付.day}
    end
  end
end
