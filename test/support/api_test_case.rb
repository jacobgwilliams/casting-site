class ApiTestCase < ActionDispatch::IntegrationTest
  include TestData

  private

  def sign_in_as(user)
    post "/api/v1/session", params: { email: user.email, password: TestData::PASSWORD }, as: :json
    assert_response :created
  end

  def json_response
    JSON.parse(response.body)
  end
end
