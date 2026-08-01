module Api
  module V1
    class ActorSkillsController < BaseController
      before_action :set_actor_profile
      before_action :set_actor_skill, only: %i[update destroy]

      def index
        authorize ActorSkill
        skills = policy_scope(ActorSkill).includes(:skill).joins(:skill).order("skills.name")

        render json: {
          actor_skills: skills.map { |record| ActorSkillSerializer.new(record).as_json }
        }
      end

      def create
        skill = @actor_profile.actor_skills.new(actor_skill_params)
        authorize skill

        if skill.save
          render json: { actor_skill: ActorSkillSerializer.new(skill.reload).as_json }, status: :created
        else
          render_validation_errors(skill)
        end
      end

      def update
        authorize @actor_skill

        if @actor_skill.update(actor_skill_params)
          render json: { actor_skill: ActorSkillSerializer.new(@actor_skill.reload).as_json }
        else
          render_validation_errors(@actor_skill)
        end
      end

      def destroy
        authorize @actor_skill
        @actor_skill.destroy!
        head :no_content
      end

      private

      def set_actor_profile
        @actor_profile = current_user.actor_profile
        raise ActiveRecord::RecordNotFound if @actor_profile.nil?
      end

      def set_actor_skill
        @actor_skill = policy_scope(ActorSkill).find(params[:id])
      end

      def actor_skill_params
        params.require(:actor_skill).permit(:skill_id, :proficiency, :years_experience, :notes)
      end
    end
  end
end
