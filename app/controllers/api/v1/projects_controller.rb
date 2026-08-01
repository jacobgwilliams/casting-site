module Api
  module V1
    class ProjectsController < BaseController
      def index
        projects = policy_scope(Project).includes(:casting_office, :breakdowns).order(created_at: :desc)
        render json: {
          projects: projects.map { |p| ProjectSerializer.new(p).as_json }
        }
      end

      def show
        project = Project.includes(breakdowns: [ :breakdown_criterion, { breakdown_skill_requirements: :skill } ])
          .find(params[:id])
        authorize project
        render json: { project: ProjectSerializer.new(project, include_breakdowns: true).as_json }
      end

      def create
        project = Project.new(project_params)
        project.created_by_user = current_user
        authorize project

        if project.save
          attach_creator_to_team!(project)
          render json: { project: ProjectSerializer.new(project).as_json }, status: :created
        else
          render_validation_errors(project)
        end
      end

      def update
        project = Project.find(params[:id])
        authorize project

        if project.update(project_params)
          render json: { project: ProjectSerializer.new(project).as_json }
        else
          render_validation_errors(project)
        end
      end

      private

      def project_params
        params.require(:project).permit(
          :name, :project_type, :description, :status, :casting_office_id,
          :production_company_name, :union_status, :shoot_start_date, :shoot_end_date,
          :location_summary, :confidential, :published_at
        )
      end

      def attach_creator_to_team!(project)
        return if project.casting_office_id.blank?

        membership = current_user.organization_memberships.active.find_by(
          organization_id: project.casting_office_id
        )
        return unless membership

        project.project_casting_team_members.find_or_create_by!(organization_membership: membership) do |member|
          member.project_role = "owner"
          member.permissions = {
            can_edit_project: true,
            can_manage_breakdowns: true,
            can_review_submissions: true,
            can_invite_team_members: true
          }
        end
      end
    end
  end
end
