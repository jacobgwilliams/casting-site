class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(*)
    {
      id: @user.id,
      email: @user.email,
      first_name: @user.first_name,
      last_name: @user.last_name,
      full_name: @user.full_name,
      phone_number: @user.phone_number,
      status: @user.status,
      personas: {
        actor: @user.actor?,
        casting_professional: @user.casting_professional?,
        representative: @user.representative?,
        representative_type: @user.representative_profile&.representative_type
      },
      actor_profile_id: @user.actor_profile&.id,
      casting_professional_profile_id: @user.casting_professional_profile&.id,
      representative_profile_id: @user.representative_profile&.id
    }
  end
end
