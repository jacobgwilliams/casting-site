class ProjectCastingTeamMember < ApplicationRecord
  ROLES = %w[owner casting_director casting_associate casting_assistant viewer].freeze

  belongs_to :project
  belongs_to :organization_membership

  validates :project_role, inclusion: { in: ROLES }
  validates :organization_membership_id, uniqueness: { scope: :project_id }
end
