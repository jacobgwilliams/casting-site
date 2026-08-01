module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :require_authentication, only: %i[create]

      def show
        render json: { user: UserSerializer.new(current_user).as_json }
      end

      def create
        user = User.find_by(email: params.require(:email))

        if user&.authenticate(params.require(:password))
          start_new_session_for(user)
          user.update!(last_signed_in_at: Time.current)
          render json: { user: UserSerializer.new(user).as_json }, status: :created
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      def destroy
        terminate_session
        head :no_content
      end
    end
  end
end
