module Api
  module V1
    class ActorProfilesController < BaseController
      before_action :set_actor_profile

      def show
        authorize @actor_profile
        render json: { actor_profile: ActorProfileSerializer.new(@actor_profile).as_json }
      end

      def update
        authorize @actor_profile

        if @actor_profile.update(actor_profile_params)
          render json: { actor_profile: ActorProfileSerializer.new(@actor_profile).as_json }
        else
          render_validation_errors(@actor_profile)
        end
      end

      private

      def set_actor_profile
        @actor_profile = current_user.actor_profile
        raise ActiveRecord::RecordNotFound if @actor_profile.nil?
      end

      def actor_profile_params
        params.require(:actor_profile).permit(
          :professional_name, :union_status, :primary_location, :timezone, :profile_status
        )
      end
    end
  end
end
