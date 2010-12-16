class HelpController < ApplicationController
  def index
  end
  
  def intro_mindmap
  end
  
  def intro_editor
    @pagetitle = "编辑器简介"
  end
  
  def intro_mapimport
    @pagetitle = "文件导入"
  end
  
  def mapdemo
    respond_to do |format|
      format.html { render :template => 'mindmaps/demo_v03' }
      format.xml { render :action => "mapdemo.rxml", :layout => false }
      format.js {}
    end
  end
  
end
