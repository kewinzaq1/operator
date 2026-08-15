module Agents
  # Superserve isolated Firecracker sandbox for long-running operator jobs.
  # Control plane: SUPERSERVE_BASE_URL (default https://api.superserve.ai)
  # Auth: SUPERSERVE_API_KEY
  class SuperserveSandbox < ExecutionSandbox
    def initialize(api_key: ENV["SUPERSERVE_API_KEY"], base_url: ENV.fetch("SUPERSERVE_BASE_URL", "https://api.superserve.ai"))
      @api_key = api_key
      @http = HttpJson.new(base_url: base_url, headers: { "Authorization" => "Bearer #{api_key}" })
    end

    def start!(task:)
      payload = @http.post("sandboxes", {
        name: "operator-#{Time.current.to_i}",
        timeoutSeconds: 900,
        metadata: { task: task, app: "operator" }
      })
      @id = payload["id"]
      Info.new(id: @id, status: payload["status"] || "RUNNING", environment: environment_name, task: task)
    rescue HttpJson::Error => e
      Rails.logger.warn("[Superserve] falling back to local: #{e.message}")
      LocalSandbox.new.start!(task: task)
    end

    def finish!
      @http.post("sandboxes/#{@id}/pause") if @id
      Info.new(id: @id, status: "COMPLETED", environment: environment_name, task: nil)
    rescue HttpJson::Error
      Info.new(id: @id, status: "COMPLETED", environment: environment_name, task: nil)
    end

    def environment_name
      "isolated sandbox"
    end
  end
end
