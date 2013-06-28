class ScratchpadRepositoriesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource :scratchpad_repository


  # -------------------------------------------------------------
  def update
    respond_to do |format|
      if @scratchpad_repository.update_attributes(params[:scratchpad_repository])
        format.html { redirect_to @scratchpad_repository, notice: 'Scratchpad repository was successfully updated.' }
        format.json { render json: @scratchpad_repository.as_json(include: [:environment]) }
      else
        format.html { render action: 'edit' }
        format.json { render json: @scratchpad_repository.errors, status: :unprocessable_entity }
      end
    end
  end

end
