require "test_helper"

class Api::V1::PersonasTest < ApiTestCase
  test "casting user session exposes casting persona only" do
    user = create_casting_user[:user]
    sign_in_as user

    get "/api/v1/session", as: :json

    assert_response :success
    personas = json_response.dig("user", "personas")
    assert personas["casting_professional"]
    refute personas["actor"]
    refute personas["representative"]
  end

  test "actor user session exposes actor persona only" do
    sign_in_as create_actor_user

    get "/api/v1/session", as: :json

    assert_response :success
    personas = json_response.dig("user", "personas")
    assert personas["actor"]
    refute personas["casting_professional"]
    refute personas["representative"]
  end

  test "agent user session exposes representative persona only" do
    sign_in_as create_agent_user

    get "/api/v1/session", as: :json

    assert_response :success
    personas = json_response.dig("user", "personas")
    assert personas["representative"]
    assert_equal "agent", personas["representative_type"]
    refute personas["actor"]
    refute personas["casting_professional"]
  end
end
