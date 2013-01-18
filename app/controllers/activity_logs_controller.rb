class ActivityLogsController < ApplicationController

  before_filter :authenticate_user!

  # -------------------------------------------------------------
  # GET /activity
  # GET /activity.json
  def index
    fetch_activity_logs

    respond_to do |format|
      format.html
      format.js
      format.json do
        query = params[:query]
        if query
          actions = ActivityLog.all_actions(query)
          render json: actions
        else
          render json: @activity_logs
        end
      end
    end
  end


  # -------------------------------------------------------------
  # POST /activity/filter
  def filter
    @last_email = params[:email]
    @last_action = params[:action_name]

    fetch_activity_logs

    respond_to do |format|
      format.js
    end
  end


  private

  # -------------------------------------------------------------
  def fetch_activity_logs
    criteria = {}
    criteria['users.email'] = @last_email unless @last_email.blank?
    criteria['action'] = @last_action unless @last_action.blank?

    @activity_logs = ActivityLog.joins(:user).where(criteria).
      page(params[:page])
  end

end
