module Api
  module V1
    class OrganizationsController < BaseController
      def index
        organizations = policy_scope(Organization).order(:name)
        render json: { organizations: organizations.map { |o| OrganizationSerializer.new(o).as_json } }
      end

      def show
        organization = Organization.find(params[:id])
        authorize organization
        render json: { organization: OrganizationSerializer.new(organization).as_json }
      end

      def create
        organization = Organization.new(organization_params)
        authorize organization

        Organization.transaction do
          organization.save!
          organization.organization_memberships.create!(
            user: current_user,
            membership_role: "owner",
            status: "active",
            started_on: Date.current,
            accepted_at: Time.current
          )
        end

        render json: { organization: OrganizationSerializer.new(organization).as_json }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      def update
        organization = Organization.find(params[:id])
        authorize organization

        if organization.update(organization_params)
          render json: { organization: OrganizationSerializer.new(organization).as_json }
        else
          render_validation_errors(organization)
        end
      end

      private

      def organization_params
        params.require(:organization).permit(
          :name, :organization_type, :status, :website_url, :phone_number, :email,
          :address_line_1, :address_line_2, :city, :state_region, :postal_code, :country_code
        )
      end
    end
  end
end
