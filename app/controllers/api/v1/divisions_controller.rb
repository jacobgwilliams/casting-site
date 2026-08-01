module Api
  module V1
    class DivisionsController < BaseController
      before_action :set_organization
      before_action :ensure_divisions_supported!
      before_action :set_division, only: %i[update destroy]

      def index
        division = @organization.divisions.new
        authorize division, :index?

        divisions = @organization.divisions.order(:name)
        render json: { divisions: divisions.map { |record| DivisionSerializer.new(record).as_json } }
      end

      def create
        division = @organization.divisions.new(division_params)
        authorize division

        if division.save
          render json: { division: DivisionSerializer.new(division).as_json }, status: :created
        else
          render_validation_errors(division)
        end
      end

      def update
        authorize @division

        if @division.update(division_params)
          render json: { division: DivisionSerializer.new(@division).as_json }
        else
          render_validation_errors(@division)
        end
      end

      def destroy
        authorize @division

        @division.destroy!
        head :no_content
      end

      private

      def set_organization
        @organization = Organization.find(params[:organization_id])
      end

      def set_division
        @division = @organization.divisions.find(params[:id])
      end

      def ensure_divisions_supported!
        return if @organization.agency? || @organization.management_company?

        render json: { error: "Divisions are only available for agencies and management companies" },
          status: :unprocessable_entity
      end

      def division_params
        params.require(:division).permit(:name, :slug, :description, :active)
      end
    end
  end
end
