# frozen_string_literal: true

module Plugin::Covid19
  class User < Diva::Model
    include Diva::Model::UserMixin

    field.string :name

    #model_field

    def icon
      Skin[:covid19]
    end
  end
end
