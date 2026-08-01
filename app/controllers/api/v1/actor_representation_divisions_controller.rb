module Api
  module V1
    class ActorRepresentationDivisionsController < BaseController
      before_action :set_representation
      before_action :set_representation_division, only: %i[update destroy]

      def create
        division = @representation.actor_representation_divisions.new(division_params)
        division.started_on ||= Date.current
        authorize division

        if division.save
          render json: {
            representation_division: ActorRepresentationDivisionSerializer.new(division).as_json
          }, status: :created
        else
          render_validation_errors(division)
        end
      end

      def update
        authorize @representation_division

        if @representation_division.update(division_params)
          render json: {
            representation_division: ActorRepresentationDivisionSerializer.new(@representation_division).as_json
          }
        else
          render_validation_errors(@representation_division)
        end
      end

      def destroy
        authorize @representation_division

        @representation_division.update!(status: "ended", ended_on: Date.current)
        head :no_content
      end

      private

      def set_representation
        @representation = policy_scope(ActorRepresentation).find(params[:actor_representation_id])
      end

      def set_representation_division
        @representation_division = @representation.actor_representation_divisions.find(params[:id])
      end

      def division_params
        params.require(:representation_division).permit(:division_id, :status, :started_on, :ended_on)
      end
    end
  end
end
