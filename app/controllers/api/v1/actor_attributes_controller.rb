module Api
  module V1
    class ActorAttributesController < BaseController
      before_action :set_actor_profile
      before_action :set_actor_attribute, only: %i[update destroy]

      def index
        authorize ActorAttribute
        attributes = policy_scope(ActorAttribute).includes(:profile_attribute).joins(:profile_attribute)
          .order("profile_attributes.name")

        render json: {
          actor_attributes: attributes.map { |record| ActorAttributeSerializer.new(record).as_json }
        }
      end

      def create
        attribute = @actor_profile.actor_attributes.new(actor_attribute_params)
        authorize attribute

        if attribute.save
          render json: {
            actor_attribute: ActorAttributeSerializer.new(attribute.reload).as_json
          }, status: :created
        else
          render_validation_errors(attribute)
        end
      end

      def update
        authorize @actor_attribute

        if @actor_attribute.update(actor_attribute_params)
          render json: {
            actor_attribute: ActorAttributeSerializer.new(@actor_attribute.reload).as_json
          }
        else
          render_validation_errors(@actor_attribute)
        end
      end

      def destroy
        authorize @actor_attribute
        @actor_attribute.destroy!
        head :no_content
      end

      private

      def set_actor_profile
        @actor_profile = current_user.actor_profile
        raise ActiveRecord::RecordNotFound if @actor_profile.nil?
      end

      def set_actor_attribute
        @actor_attribute = policy_scope(ActorAttribute).find(params[:id])
      end

      def actor_attribute_params
        params.require(:actor_attribute).permit(:profile_attribute_id, :visibility)
      end
    end
  end
end
