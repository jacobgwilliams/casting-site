module Api
  module V1
    class ActorRepresentationsController < BaseController
      def index
        representations = scoped_representations.includes(
          :organization,
          actor_profile: :user,
          actor_representation_divisions: [
            :division,
            { actor_representation_contacts: { representative_profile: :user } }
          ]
        ).order(created_at: :desc)

        render json: {
          actor_representations: representations.map { |record|
            ActorRepresentationSerializer.new(record).as_json
          }
        }
      end

      def show
        representation = find_representation
        authorize representation
        render json: { actor_representation: ActorRepresentationSerializer.new(representation).as_json }
      end

      def create
        representation = build_representation
        authorize representation

        if representation.save
          render json: { actor_representation: ActorRepresentationSerializer.new(representation).as_json },
            status: :created
        else
          render_validation_errors(representation)
        end
      end

      def update
        representation = find_representation
        authorize representation

        attrs = representation_update_params
        apply_status_side_effects!(representation, attrs)

        if representation.update(attrs)
          render json: { actor_representation: ActorRepresentationSerializer.new(representation.reload).as_json }
        else
          render_validation_errors(representation)
        end
      end

      private

      def scoped_representations
        scope = policy_scope(ActorRepresentation)
        return scope.none unless ActorRepresentationPolicy.new(current_user, ActorRepresentation.new).index?

        if params[:organization_id].present?
          scope = scope.where(organization_id: params[:organization_id])
        end
        scope
      end

      def find_representation
        scoped_representations.find(params[:id])
      end

      def build_representation
        if representation_params[:actor_profile_id].present?
          actor_profile = ActorProfile.find(representation_params[:actor_profile_id])
        elsif representation_params[:actor_email].present?
          actor_profile = User.find_by!(email: representation_params[:actor_email].strip.downcase).actor_profile
          raise ActiveRecord::RecordNotFound, "Actor profile not found" if actor_profile.nil?
        else
          raise ActiveRecord::RecordNotFound, "Actor profile not found" unless current_user.actor_profile

          actor_profile = current_user.actor_profile
        end

        ActorRepresentation.new(
          representation_assignable_params.merge(
            actor_profile: actor_profile,
            invited_by_user: current_user,
            status: representation_params[:status].presence || default_create_status(actor_profile),
            started_on: representation_params[:started_on].presence || Date.current
          )
        )
      end

      def default_create_status(actor_profile)
        if actor_profile.user_id == current_user.id
          "pending"
        else
          "pending"
        end
      end

      def apply_status_side_effects!(representation, attrs)
        new_status = attrs[:status]
        return if new_status.blank?

        if new_status == "active" && representation.status != "active"
          attrs[:confirmed_at] = Time.current
        end

        if new_status.in?(%w[terminated inactive]) && attrs[:ended_on].blank?
          attrs[:ended_on] = Date.current
        end
      end

      def representation_assignable_params
        representation_params.except(:actor_profile_id, :actor_email)
      end

      def representation_params
        params.require(:actor_representation).permit(
          :organization_id, :actor_profile_id, :actor_email, :status, :exclusive,
          :started_on, :ended_on, :notes
        )
      end

      def representation_update_params
        params.require(:actor_representation).permit(
          :status, :exclusive, :started_on, :ended_on, :notes, :confirmed_at
        ).to_h.symbolize_keys
      end
    end
  end
end
