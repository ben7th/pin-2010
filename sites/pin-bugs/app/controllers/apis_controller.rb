class ApisController < ApplicationController

  before_filter :per_load
  def per_load
    @api_help = ApiHelp.find(params[:id]) if params[:id]
  end

  def index
    @api_helps = ApiHelp.all
  end

  def show
    @api_help = ApiHelp.find(params[:id])
  end

  def new
    @api_help = ApiHelp.new
  end

  def create
    @api_help = ApiHelp.create(params[:api_help])
    redirect_to '/apis'
  end

  def edit
  end

  def update
    if @api_help.update_attributes(params[:api_help])
      return redirect_to :action=>"show"
    end
    return redirect_to :action=>"edit"
  end

end
