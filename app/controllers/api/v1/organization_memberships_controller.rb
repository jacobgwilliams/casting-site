module Api
  module V1
    class OrganizationMembershipsController < BaseController
      before_action :set_organization
      before_action :set_membership, only: %i[update destroy]

      def index
        membership = @organization.organization_memberships.new(user: current_user)
        authorize membership, :index?

        memberships = @organization.organization_memberships.includes(:user).order(created_at: :desc)
        render json: {
          memberships: memberships.map { |record| OrganizationMembershipSerializer.new(record).as_json }
        }
      end

      def create
        membership = @organization.organization_memberships.new(membership_assignable_params)
        membership.user = resolve_user
        membership.status = membership_params[:status].presence || "invited"
        membership.started_on ||= Date.current
        apply_invite_timestamps!(membership)
        authorize membership

        if membership.save
          render json: { membership: OrganizationMembershipSerializer.new(membership).as_json }, status: :created
        else
          render_validation_errors(membership)
        end
      end

      def update
        authorize @membership

        attrs = membership_update_params
        restrict_non_admin_update!(attrs)

        if attrs[:status] == "active" && @membership.invited?
          attrs[:accepted_at] = Time.current
        end

        if @membership.update(attrs)
          render json: { membership: OrganizationMembershipSerializer.new(@membership).as_json }
        else
          render_validation_errors(@membership)
        end
      end

      def destroy
        authorize @membership

        @membership.update!(status: "removed", ended_on: Date.current)
        head :no_content
      end

      private

      def set_organization
        @organization = Organization.find(params[:organization_id])
      end

      def set_membership
        @membership = @organization.organization_memberships.find(params[:id])
      end

      def resolve_user
        if membership_params[:user_id].present?
          User.find(membership_params[:user_id])
        elsif membership_params[:email].present?
          User.find_by!(email: membership_params[:email].strip.downcase)
        else
          current_user
        end
      end

      def apply_invite_timestamps!(membership)
        if membership.status == "invited"
          membership.invited_at = Time.current
        elsif membership.status == "active"
          membership.accepted_at = Time.current
        end
      end

      def restrict_non_admin_update!(attrs)
        admin = @organization.organization_memberships.active.exists?(
          user_id: current_user.id,
          membership_role: %w[owner administrator]
        )
        return if admin

        attrs.slice!(:status)
        raise Pundit::NotAuthorizedError unless attrs[:status] == "active" && @membership.invited?
      end

      def membership_assignable_params
        membership_params.except(:user_id, :email)
      end

      def membership_params
        params.require(:membership).permit(
          :user_id, :email, :membership_role, :job_title, :status, :started_on, :ended_on
        )
      end

      def membership_update_params
        params.require(:membership).permit(
          :membership_role, :job_title, :status, :started_on, :ended_on
        ).to_h.symbolize_keys
      end
    end
  end
end
