class TypeaheadsController < ApplicationController

  # -------------------------------------------------------------
  def user
    @search = params[:search]
    @users = User.search(@search)

    respond_to do |format|
      format.json { render json: @users.as_json(only: [:full_name, :email, :id]) }
    end
  end

end
