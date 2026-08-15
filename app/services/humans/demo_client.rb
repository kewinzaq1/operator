module Humans
  class DemoClient
    EXPERT_RESULT = <<~TEXT.squish
      Verified sports physiotherapist in Warsaw. Keep the next 7 days to
      mobility and isometric work only — no loaded squats or running. Resume
      progressive loading after pain-free daily walking. Share this with the
      client and offer a lighter session this week.
    TEXT

    def request_feasibility(task:, expertise:, context: nil)
      {
        "id" => "fr_demo_#{SecureRandom.hex(3)}",
        "status" => "SUBMITTED",
        "task" => task,
        "audience" => expertise,
        "context" => context
      }
    end

    def get_feasibility_request(id)
      {
        "id" => id,
        "status" => "RESPONDED",
        "costPerParticipant" => 18.0,
        "cpi_usd" => 18.0,
        "pricing" => { "cost_per_participant_cents" => 1800, "currency" => "usd" }
      }
    end

    def create_opportunity(attrs)
      {
        "id" => "opp_demo_#{SecureRandom.hex(3)}",
        "status" => "draft",
        "title" => attrs[:title] || attrs["title"],
        "num_participants" => 1,
        "links" => { "launch" => "/opportunities/demo/launch", "submissions" => "/opportunities/demo/submissions" }
      }
    end

    def launch_opportunity(id)
      { "id" => id, "status" => "live", "launched_at" => Time.current.iso8601 }
    end

    def get_opportunity(id)
      {
        "id" => id,
        "status" => "completed",
        "submission_stats" => { "total" => 1, "approved" => 1, "awaiting_review" => 0 }
      }
    end

    def get_submissions(_opportunity_id)
      { "data" => [ { "id" => "sub_demo_pt", "status" => "approved", "result" => EXPERT_RESULT } ] }
    end

    def get_submission(id)
      { "id" => id, "status" => "approved", "result" => EXPERT_RESULT }
    end

    def approve_submission(id)
      { "id" => id, "status" => "approved" }
    end

    def quoted_cost(payload)
      payload["costPerParticipant"] || payload["cpi_usd"] || 18.0
    end

    def priced?(payload)
      %w[RESPONDED PRICED].include?(payload["status"].to_s.upcase)
    end
  end
end
