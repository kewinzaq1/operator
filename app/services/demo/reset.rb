module Demo
  class Reset
    def self.call
      AgentAction.delete_all
      Message.delete_all
      HumanEscalation.delete_all
      ApprovalRequest.delete_all
      BusinessMetric.delete_all
      AgentRun.delete_all
      Payment.delete_all
      Appointment.delete_all
      Conversation.delete_all
      Lead.delete_all
      DigitalProduct.delete_all
      Service.delete_all
      Customer.delete_all
      BusinessPolicy.delete_all
      Business.delete_all
      Seed.call
    end
  end
end
