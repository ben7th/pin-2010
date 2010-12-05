class StarsController < ApplicationController

  before_filter :per_load
  def per_load
    @note = Note.find(params[:note_id]) if params[:note_id]
  end

  def create
    current_user.star_note(@note)
    redirect_to show_note_path(@note)
  end

  def destroy
    current_user.unstar_note(@note)
    redirect_to show_note_path(@note)
  end

end