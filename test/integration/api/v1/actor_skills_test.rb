require "test_helper"

class Api::V1::ActorSkillsTest < ApiTestCase
  setup do
    @actor = create_actor_user
    @skill = Skill.create!(name: "Juggling", slug: "juggling", category: "performance")
  end

  test "actor lists own skills" do
    @actor.actor_profile.actor_skills.create!(skill: @skill, proficiency: "advanced")
    sign_in_as @actor

    get "/api/v1/actor_skills", as: :json

    assert_response :success
    assert_equal 1, json_response.fetch("actor_skills").size
    assert_equal "Juggling", json_response.dig("actor_skills", 0, "skill_name")
  end

  test "actor creates skill with proficiency" do
    sign_in_as @actor

    assert_difference "ActorSkill.count", 1 do
      post "/api/v1/actor_skills",
        params: {
          actor_skill: {
            skill_id: @skill.id,
            proficiency: "intermediate",
            years_experience: 3
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "intermediate", json_response.dig("actor_skill", "proficiency")
    assert_equal 3, json_response.dig("actor_skill", "years_experience")
  end

  test "actor updates skill" do
    actor_skill = @actor.actor_profile.actor_skills.create!(skill: @skill, proficiency: "beginner")
    sign_in_as @actor

    patch "/api/v1/actor_skills/#{actor_skill.id}",
      params: { actor_skill: { proficiency: "expert" } },
      as: :json

    assert_response :success
    assert_equal "expert", json_response.dig("actor_skill", "proficiency")
  end

  test "actor deletes skill" do
    actor_skill = @actor.actor_profile.actor_skills.create!(skill: @skill)
    sign_in_as @actor

    assert_difference "ActorSkill.count", -1 do
      delete "/api/v1/actor_skills/#{actor_skill.id}", as: :json
    end

    assert_response :no_content
  end

  test "agent cannot manage actor skills" do
    actor_skill = @actor.actor_profile.actor_skills.create!(skill: @skill)
    sign_in_as create_agent_user

    get "/api/v1/actor_skills", as: :json

    assert_response :not_found
  end
end
