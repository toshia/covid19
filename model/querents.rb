# frozen_string_literal: true

module Plugin::Covid19
  # 帰国者・接触者センター相談件数
  # /querents/data/0/
  class Querent < Diva::Model
    ESTIMATE_FIELDS = %w[9-17時 17-翌9時]
    include Diva::Model::MessageMixin

    register :covid19_querent, name: "帰国者・接触者センター相談件数", timeline: true, reply: false, myself: false

    field.time :日付, required: true
    field.int :小計, required: true

    def user
      Plugin::Covid19::User.new(name: "帰国者・接触者センター相談件数")
    end

    def description
      [
        '%{amount} 件' % {amount: 小計},
        *ESTIMATE_FIELDS.map { |ef| "%{time} : %{amount}" % {time: ef, amount: self[ef]} }
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
