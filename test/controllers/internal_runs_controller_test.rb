require "test_helper"

class InternalRunsControllerTest < ActionDispatch::IntegrationTest
  setup { seed_demo! }

  test "rejects missing token" do
    ENV.delete("OPERATOR_JOB_TOKEN")
    post "/internal/runs", params: { trigger: "render_workflow" }, as: :json
    assert_response :unauthorized
  end

  test "starts an operator run when the shared token matches" do
    ENV["OPERATOR_JOB_TOKEN"] = "hackathon-token"
    assert_difference -> { AgentRun.count }, 1 do
      post "/internal/runs",
        params: { trigger: "render_workflow" },
        headers: { "X-Operator-Token" => "hackathon-token" },
        as: :json
    end
    assert_response :success
    assert JSON.parse(response.body)["run_id"].present?
  ensure
    ENV.delete("OPERATOR_JOB_TOKEN")
  end
end
