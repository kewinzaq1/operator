module Humans
  # Terac REST API v2 — verified human labor.
  # Base: https://terac.com/api/external/v2
  # Auth: Authorization: Bearer <api key>
  #
  # Maps to the current MCP tool catalog:
  #   terac_request_feasibility     -> POST /quotes
  #   terac_get_feasibility_request -> GET  /quotes/:id
  #   terac_create_opportunity      -> POST /opportunities
  #   terac_launch_draft_opportunity-> POST /opportunities/:id/launch
  #   terac_get_opportunity         -> GET  /opportunities/:id
  #   terac_get_submissions         -> GET  /opportunities/:id/submissions
  #   terac_get_submission          -> GET  /submissions/:id
  #   terac_approve_submission      -> POST /submissions/:id/approve
  #
  # Pricing is not autonomous: request feasibility, then poll until status is
  # RESPONDED/PRICED and costPerParticipant (or cost_per_participant_cents) is set.
  class TeracClient
    BASE = "https://terac.com/api/external/v2"

    def initialize(api_key: ENV["TERAC_API_KEY"], http: nil)
      @http = http || HttpJson.new(base_url: BASE, headers: { "Authorization" => "Bearer #{api_key}" })
    end

    def request_feasibility(task:, expertise:, context: nil)
      @http.post("quotes", {
        description: task,
        audience: expertise,
        context: context,
        num_participants: 1
      })
    end

    def get_feasibility_request(id)
      @http.get("quotes/#{id}")
    end

    def create_opportunity(attrs)
      @http.post("opportunities", attrs)
    end

    def launch_opportunity(id)
      @http.post("opportunities/#{id}/launch")
    end

    def get_opportunity(id)
      @http.get("opportunities/#{id}")
    end

    def get_submissions(opportunity_id)
      @http.get("opportunities/#{opportunity_id}/submissions")
    end

    def get_submission(id)
      @http.get("submissions/#{id}")
    end

    def approve_submission(id)
      @http.post("submissions/#{id}/approve")
    end

    def quoted_cost(payload)
      return payload["costPerParticipant"] if payload["costPerParticipant"]
      return payload["cpi_usd"] if payload["cpi_usd"]
      cents = payload.dig("pricing", "cost_per_participant_cents") || payload["cost_per_participant_cents"]
      cents.to_f / 100.0 if cents
    end

    def priced?(payload)
      status = payload["status"].to_s.upcase
      %w[RESPONDED PRICED].include?(status) && quoted_cost(payload).present?
    end
  end
end
