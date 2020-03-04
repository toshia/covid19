# frozen_string_literal: true

module Plugin::Covid19
  class User < Diva::Model
    include Diva::Model::UserMixin

    field.string :name

    #model_field

    def icon
      Enumerator.new{|y|
        Plugin.filtering(:photo_filter, 'https://1.bp.blogspot.com/-q0vC8T9XRSg/XiOwuwtXJLI/AAAAAAABXHk/clxgC9d2E8YrWluWTw0NFYP832mEMdN-ACNcBGAsYHQ/s400/virus_corona.png', y)
      }.lazy.map{|photo|
        Plugin.filtering(:miracle_icon_filter, photo)[0]
      }.first
    end
  end
end
