class ApprovalsController < ApplicationController
  before_action :require_business

  def update
    approval = current_business.approval_requests.find(params[:id])
    if params[:decision] == "approve"
      approval.approve!
    else
      approval.reject!
    end
    redirect_to dashboard_path
  end
end
