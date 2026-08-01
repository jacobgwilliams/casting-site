module Api
  module V1
    class BreakdownsController < BaseController
      def index
        breakdowns = Breakdown.includes(:project, :breakdown_criterion, breakdown_skill_requirements: :skill)
          .order(created_at: :desc)

        visible = breakdowns.select { |breakdown| policy(breakdown).show? }
        render json: { breakdowns: visible.map { |b| BreakdownSerializer.new(b).as_json } }
      end

      def show
        breakdown = Breakdown.includes(:project, :breakdown_criterion, breakdown_skill_requirements: :skill)
          .find(params[:id])
        authorize breakdown
        render json: { breakdown: BreakdownSerializer.new(breakdown).as_json }
      end

      def create
        project = Project.find(params[:project_id])
        breakdown = project.breakdowns.new(breakdown_params)
        breakdown.created_by_user = current_user
        authorize breakdown

        Breakdown.transaction do
          breakdown.save!
          create_criteria!(breakdown)
          create_skill_requirements!(breakdown)
        end

        breakdown.reload
        render json: { breakdown: BreakdownSerializer.new(breakdown).as_json }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      def update
        breakdown = Breakdown.find(params[:id])
        authorize breakdown

        Breakdown.transaction do
          breakdown.update!(breakdown_params)
          update_criteria!(breakdown)
          replace_skill_requirements!(breakdown) if params[:skill_requirements]
        end

        breakdown.reload
        render json: { breakdown: BreakdownSerializer.new(breakdown).as_json }
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      private

      def breakdown_params
        params.require(:breakdown).permit(
          :character_name, :description, :role_type, :billing, :status, :visibility,
          :number_of_roles, :audition_required, :submission_deadline, :work_start_date,
          :work_end_date, :compensation_details, :location_details, :published_at, :closed_at
        )
      end

      def criteria_params
        params.fetch(:criteria, {}).permit(
          :portrayal_age_min, :portrayal_age_max, :gender_presentation, :union_requirement,
          :local_hire_required, :required_location, :travel_provided, :work_authorization
        )
      end

      def create_criteria!(breakdown)
        return if criteria_params.blank?

        breakdown.create_breakdown_criterion!(criteria_params)
      end

      def update_criteria!(breakdown)
        return if params[:criteria].nil?

        if breakdown.breakdown_criterion
          breakdown.breakdown_criterion.update!(criteria_params)
        else
          create_criteria!(breakdown)
        end
      end

      def create_skill_requirements!(breakdown)
        Array(params[:skill_requirements]).each do |req|
          breakdown.breakdown_skill_requirements.create!(
            skill_id: req[:skill_id] || req["skill_id"],
            requirement_level: req[:requirement_level] || req["requirement_level"] || "required",
            minimum_proficiency: req[:minimum_proficiency] || req["minimum_proficiency"],
            notes: req[:notes] || req["notes"]
          )
        end
      end

      def replace_skill_requirements!(breakdown)
        breakdown.breakdown_skill_requirements.destroy_all
        create_skill_requirements!(breakdown)
      end
    end
  end
end
