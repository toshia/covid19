# frozen_string_literal: true

module Plugin::Covid19
  # 罹患者詳細
  # /patients/data/0/
  class Patient < Diva::Model
    include Diva::Model::MessageMixin

    register :covid19_patients, name: "罹患者", timeline: true, reply: false, myself: false

    field.int :number, required: true
    field.time :リリース日, required: true
    field.string :居住地, required: false
    field.string :年代, required: false
    field.string :性別, required: false
    field.string :属性, required: false
    field.string :備考, required: false
    field.string :補足, required: false
    field.string :退院, required: false

    def user
      Plugin::Covid19::User.new(name: "#{cure_sign}#{属性} #{年代}#{性別}")
    end

    def description
      [
        "居住地: #{居住地 || '-'}",
        "備考: #{備考 || '-'}",
        "補足: #{補足 || '-'}",
        "退院: #{退院 || '未'}",
      ].join("\n")
    end

    def created
      リリース日
    end

    def cure_sign
      if 退院 == '○'
        '【退院済み】'
      end
    end

    def path
      "/#{number}"
    end
  end
end
