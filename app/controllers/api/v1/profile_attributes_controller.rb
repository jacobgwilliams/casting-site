module Api
  module V1
    class ProfileAttributesController < BaseController
      skip_before_action :require_authentication, only: %i[index]

      def index
        attributes = ProfileAttribute.order(:name)

        render json: {
          profile_attributes: attributes.map { |record| ProfileAttributeSerializer.new(record).as_json }
        }
      end
    end
  end
end
