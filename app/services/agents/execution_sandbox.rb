module Agents
  class ExecutionSandbox
    Info = Struct.new(:id, :status, :environment, :task, keyword_init: true)

    def start!(task:)
      raise NotImplementedError
    end

    def finish!
      raise NotImplementedError
    end

    def environment_name
      raise NotImplementedError
    end
  end
end
