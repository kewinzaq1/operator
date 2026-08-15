module Agents
  class LocalSandbox < ExecutionSandbox
    def start!(task:)
      Info.new(id: "local-#{Process.pid}", status: "RUNNING", environment: environment_name, task: task)
    end

    def finish!
      Info.new(id: "local-#{Process.pid}", status: "COMPLETED", environment: environment_name, task: nil)
    end

    def environment_name
      "local rails job"
    end
  end
end
