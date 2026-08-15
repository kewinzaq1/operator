module Qa
  # Replay QA integration boundary.
  # When REPLAY_QA_API_KEY is set, creates an exploration project against the live app.
  # Otherwise the Rails system test in test/system/operator_run_test.rb is the smoke flow.
  class ReplayClient
    BASE = "https://loop-qa.replay.io/api/v1"

    def initialize(api_key: ENV["REPLAY_QA_API_KEY"], http: nil)
      @api_key = api_key
      @http = http || HttpJson.new(base_url: BASE, headers: { "Authorization" => "Bearer #{api_key}" })
    end

    def available?
      @api_key.present?
    end

    def start_smoke(target_url:)
      return { "status" => "skipped", "reason" => "no Replay credentials; use system tests" } unless available?

      @http.post("projects", {
        target_url: target_url,
        name: "Operator smoke",
        prompt: "Open dashboard → Run my business → cancellation detected → replacement contacted → booking created → payment created → activity log updated"
      })
    end
  end
end
