module Api
  module V1
    class CastingProfessionalProfilesController < BaseController
      before_action :set_casting_professional_profile

      def show
        authorize @casting_professional_profile
        render json: {
          casting_professional_profile: CastingProfessionalProfileSerializer.new(@casting_professional_profile).as_json
        }
      end

      def update
        authorize @casting_professional_profile

        if @casting_professional_profile.update(casting_professional_profile_params)
          render json: {
            casting_professional_profile: CastingProfessionalProfileSerializer.new(@casting_professional_profile).as_json
          }
        else
          render_validation_errors(@casting_professional_profile)
        end
      end

      private

      def set_casting_professional_profile
        @casting_professional_profile = current_user.casting_professional_profile
        raise ActiveRecord::RecordNotFound if @casting_professional_profile.nil?
      end

      def casting_professional_profile_params
        params.require(:casting_professional_profile).permit(:professional_title)
      end
    end
  end
end
