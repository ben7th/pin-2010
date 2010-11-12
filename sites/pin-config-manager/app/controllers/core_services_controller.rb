class CoreServicesController < ApplicationController
  
  def reset_config
    settings = params['project']['settings']
    database = params['project']['database']
    name = settings['name']
    url = settings['url']
    
    project_config = ProjectConfig.find_by_name(name)
    
    if project_config.blank?
      ProjectConfig.create(:name=>name,:url=>url,:database=>database,:settings=>settings)
    else
      project_config.update_attributes(:url=>url,:database=>database,:settings=>settings)
    end

    return render :status=>200,:text=>"ok"
  end

  def show
    project_config = ProjectConfig.find_by_name(params[:id])
    render :status=>200,:xml=>project_config.to_xml
  end
    
end