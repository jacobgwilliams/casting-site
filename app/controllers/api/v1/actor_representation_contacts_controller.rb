module Api
  module V1
    class ActorRepresentationContactsController < BaseController
      before_action :set_representation
      before_action :set_representation_division
      before_action :set_contact, only: %i[destroy]

      def create
        contact = @representation_division.actor_representation_contacts.new(contact_params)
        contact.started_on ||= Date.current
        authorize contact

        if contact.save
          render json: { contact: ActorRepresentationContactSerializer.new(contact).as_json }, status: :created
        else
          render_validation_errors(contact)
        end
      end

      def destroy
        authorize @contact

        @contact.update!(ended_on: Date.current)
        head :no_content
      end

      private

      def set_representation
        @representation = policy_scope(ActorRepresentation).find(params[:actor_representation_id])
      end

      def set_representation_division
        @representation_division = @representation.actor_representation_divisions.find(params[:division_id])
      end

      def set_contact
        @contact = @representation_division.actor_representation_contacts.find(params[:id])
      end

      def contact_params
        params.require(:contact).permit(:representative_profile_id, :is_primary, :started_on, :ended_on)
      end
    end
  end
end
