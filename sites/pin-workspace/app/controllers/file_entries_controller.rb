class FileEntriesController < ApplicationController

  before_filter :per_load
  before_filter :login_required


  def per_load
    @workspace = Workspace.find(params[:workspace_id]) if params[:workspace_id]
    @file_entry = FileEntry.find(params[:id]) if params[:id]
  end

  def index
    @file_entries = @workspace.file_entries
  end

  def new
    
  end

  def create
    file_entry = @workspace.file_entries.new(params[:file_entry])
    file_entry.user = current_user
    if file_entry.save
      redirect_to :action=>'index'
    end
  end

  def destroy
    if @file_entry.destroy
      redirect_to :action=>'index'
    end
  end

  def upload
    send_file @file_entry.content.path,:filename=>@file_entry.title
  end
  
end