class PagesController < ApplicationController
  def home
    redirect_to dashboard_path if params[:go] == "dashboard" && current_business
  end
end
