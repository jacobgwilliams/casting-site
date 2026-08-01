module Api
  module V1
    class SessionsController < BaseController
      skip_before_action :require_authentication, only: %i[create]

      def show
        render json: { user: UserSerializer.new(current_user).as_json }
      end

      def update
        authorize current_user

        if update_current_user
          render json: { user: UserSerializer.new(current_user.reload).as_json }
        else
          render_validation_errors(current_user)
        end
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

      private

      def update_current_user
        attrs = session_update_params
        password = attrs.delete(:password)
        password_confirmation = attrs.delete(:password_confirmation)
        current_password = attrs.delete(:current_password)

        if password.present?
          unless current_user.authenticate(current_password.to_s)
            current_user.errors.add(:current_password, "is incorrect")
            return false
          end

          current_user.password = password
          current_user.password_confirmation = password_confirmation
        end

        current_user.assign_attributes(attrs)
        current_user.save
      end

      def session_update_params
        params.require(:user).permit(
          :first_name, :last_name, :phone_number,
          :password, :password_confirmation, :current_password
        )
      end
    end
  end
end
