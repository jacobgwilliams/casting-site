module Api
  module V1
    class SkillsController < BaseController
      skip_before_action :require_authentication, only: %i[index]

      def index
        skills = Skill.order(:name)
        render json: {
          skills: skills.map { |s|
            { id: s.id, name: s.name, category: s.category, slug: s.slug }
          }
        }
      end
    end
  end
end
