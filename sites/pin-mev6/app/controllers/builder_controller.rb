class BuilderController < ApplicationController
  before_filter :login_required, :only=>[:create, :import]
  
  def create
    mindmap = Mindmap.new_by_params(current_user, params[:mindmap])
    if mindmap.save
      render :partial=>'mindmaps/parts/grids', :locals=>{:mindmaps=>[mindmap]}
      return
    end
    render :status=>400, :text=>mindmap.errors.to_json
  end
  
  def import
    mindmap = Mindmap.new_by_import(current_user, params[:file])
    if mindmap.save
      render :partial=>'mindmaps/parts/grids', :locals=>{:mindmaps=>[mindmap]}
      return
    end
    render :status=>400, :text=>mindmap.errors.to_json
  end
  
end
