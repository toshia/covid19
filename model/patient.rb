# frozen_string_literal: true

module Plugin::Covid19
  # 罹患者詳細
  # /patients/data/0/
  class Patient < Diva::Model
    include Diva::Model::MessageMixin

    register :covid19_patient, name: "罹患者", timeline: true, reply: true, myself: false

    field.int :number, required: true
    field.time :リリース日, required: true
    field.string :居住地, required: false
    field.string :年代, required: false
    field.string :性別, required: false
    field.string :属性, required: false
    field.string :備考, required: false
    field.string :補足, required: false
    field.string :退院, required: false

    def initialize(*)
      super
      self[:created] = リリース日 # cairo_subparts_message_base対策。ウーンこれはアホ！ｗ
    end

    def idname
      number.to_s
    end

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

    def cure?
      退院 == '〇'
    end

    def die?
      備考&.include?('死亡')
    end

    def cure_sign
      case
      when die?
        '【死亡】'
      when cure?
        '【退院済み】'
      end
    end

    def repliable?
      true
    end

    def has_receive_message?
      !receive_user_idnames.empty?
    end

    def replyto_source
      parents&.first
    end

    def replyto_source_d(_ = false)
      Delayer::Deferred.new(true).tap do |promise|
        promise.call(replyto_source)
      end
    end

    def around(_ = false)
      [self, *parents.map(&:ancestors)].flat_map(&:descendants)
    end

    def ancestors(_ = false)
      [self, *parents.map(&:ancestors)]
    end

    def descendants
      [self, *children.map(&:descendants)]
    end

    def parents
      @parents ||= Set.new
    end

    def children
      @children ||= Set.new
    end

    def add_parent(other)
      parents << other
      other.add_child(self)
    end

    def add_child(other)
      children << other
    end

    IDNAME_MATCHER = %r[(NO.|№)([０-９\d]+(?:、[０-９\d]+)*)]
    def receive_user_idnames
      (補足 || '').scan(IDNAME_MATCHER).flat_map do |matched|
        (matched[1] || '').split('、').map { |raw| raw.tr('0-9', '０-９').to_i }
      end
    end

    def path
      "/#{number}"
    end
  end
end
