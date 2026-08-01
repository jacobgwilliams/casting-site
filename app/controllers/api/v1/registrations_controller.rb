module Api
  module V1
    class RegistrationsController < BaseController
      skip_before_action :require_authentication, only: %i[create]

      def create
        user = User.new(registration_params)

        if user.save
          create_requested_personas!(user)
          start_new_session_for(user)
          render json: { user: UserSerializer.new(user.reload).as_json }, status: :created
        else
          render_validation_errors(user)
        end
      end

      private

      def registration_params
        params.require(:user).permit(
          :email, :password, :password_confirmation, :first_name, :last_name, :phone_number
        )
      end

      def create_requested_personas!(user)
        personas = Array(params[:personas]).map(&:to_s)

        user.create_actor_profile! if personas.include?("actor")
        user.create_casting_professional_profile! if personas.include?("casting_professional")

        if personas.include?("agent")
          user.create_representative_profile!(representative_type: "agent")
        elsif personas.include?("manager")
          user.create_representative_profile!(representative_type: "manager")
        end
      end
    end
  end
end
