module Agents
  # Triggers a Render Workflow task. POST https://api.render.com/v1/task-runs
  class RenderWorkflow
    def self.enabled?
      ENV["RENDER_API_KEY"].present? && ENV["RENDER_TASK_SLUG"].present? && !Rails.env.test?
    end

    def initialize(api_key: ENV["RENDER_API_KEY"], http: nil)
      @http = http || HttpJson.new(
        base_url: "https://api.render.com/v1",
        headers: { "Authorization" => "Bearer #{api_key}" }
      )
    end

    def start!(app_url:, token:)
      @http.post("task-runs", {
        task: ENV.fetch("RENDER_TASK_SLUG"),
        input: [ app_url, token ]
      })
    end
  end
end
