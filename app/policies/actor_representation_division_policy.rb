class ActorRepresentationDivisionPolicy < ApplicationPolicy
  def create?
    representation_policy.update?
  end

  def update?
    representation_policy.update?
  end

  def destroy?
    representation_policy.update?
  end

  private

  def representation_policy
    @representation_policy ||= ActorRepresentationPolicy.new(user, record.actor_representation)
  end
end
