class ActorRepresentationContactPolicy < ApplicationPolicy
  def create?
    division_policy.update?
  end

  def destroy?
    division_policy.update?
  end

  private

  def division_policy
    @division_policy ||= ActorRepresentationDivisionPolicy.new(user, record.actor_representation_division)
  end
end
