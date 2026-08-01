require "test_helper"

class Api::V1::SessionsTest < ApiTestCase
  test "login succeeds with valid credentials" do
    user = create_actor_user

    post "/api/v1/session", params: { email: user.email, password: TestData::PASSWORD }, as: :json

    assert_response :created
    assert_equal user.email, json_response.dig("user", "email")
  end

  test "login fails with invalid password" do
    user = create_actor_user

    post "/api/v1/session", params: { email: user.email, password: "wrong-password" }, as: :json

    assert_response :unauthorized
    assert_equal "Invalid email or password", json_response["error"]
  end

  test "show returns current user when authenticated" do
    user = create_actor_user
    sign_in_as user

    get "/api/v1/session", as: :json

    assert_response :success
    assert_equal user.id, json_response.dig("user", "id")
  end

  test "show requires authentication" do
    get "/api/v1/session", as: :json

    assert_response :unauthorized
  end

  test "update changes account fields" do
    user = create_actor_user
    sign_in_as user

    patch "/api/v1/session",
      params: {
        user: {
          first_name: "Alexandra",
          last_name: "Actor",
          phone_number: "555-0100"
        }
      },
      as: :json

    assert_response :success
    assert_equal "Alexandra", json_response.dig("user", "first_name")
    assert_equal "555-0100", json_response.dig("user", "phone_number")
  end

  test "update password requires current password" do
    user = create_actor_user
    sign_in_as user

    patch "/api/v1/session",
      params: {
        user: {
          current_password: "wrong-password",
          password: "new-password-123",
          password_confirmation: "new-password-123"
        }
      },
      as: :json

    assert_response :unprocessable_entity
    assert_includes json_response["errors"], "Current password is incorrect"
  end

  test "update password succeeds with current password" do
    user = create_actor_user
    sign_in_as user

    patch "/api/v1/session",
      params: {
        user: {
          current_password: TestData::PASSWORD,
          password: "new-password-123",
          password_confirmation: "new-password-123"
        }
      },
      as: :json

    assert_response :success

    delete "/api/v1/session", as: :json
    post "/api/v1/session", params: { email: user.email, password: "new-password-123" }, as: :json

    assert_response :created
  end
end
