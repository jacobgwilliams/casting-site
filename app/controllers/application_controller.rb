class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  before_action :require_authentication

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    Current.session&.user
  end

  def require_authentication
    resume_session || render_unauthorized
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = {
        value: session.id,
        httponly: true,
        same_site: :lax,
        secure: Rails.env.production?
      }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end

  def render_not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
