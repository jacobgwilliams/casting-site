module Api
  module V1
    class RepresentativeProfilesController < BaseController
      before_action :set_representative_profile

      def show
        authorize @representative_profile
        render json: {
          representative_profile: RepresentativeProfileSerializer.new(@representative_profile).as_json
        }
      end

      def update
        authorize @representative_profile

        if @representative_profile.update(representative_profile_params)
          render json: {
            representative_profile: RepresentativeProfileSerializer.new(@representative_profile).as_json
          }
        else
          render_validation_errors(@representative_profile)
        end
      end

      private

      def set_representative_profile
        @representative_profile = current_user.representative_profile
        raise ActiveRecord::RecordNotFound if @representative_profile.nil?
      end

      def representative_profile_params
        params.require(:representative_profile).permit
      end
    end
  end
end
