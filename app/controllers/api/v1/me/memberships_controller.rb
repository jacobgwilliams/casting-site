module Api
  module V1
    module Me
      class MembershipsController < BaseController
        def index
          memberships = current_user.organization_memberships
            .includes(:organization)
            .where.not(status: "removed")
            .order(created_at: :desc)

          render json: {
            memberships: memberships.map { |membership|
              OrganizationMembershipSerializer.new(membership, include_organization: true).as_json
            }
          }
        end
      end
    end
  end
end
