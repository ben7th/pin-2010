class ApiParamsController < ApplicationController

  before_filter :per_load
  def per_load
    @api_help = ApiHelp.find(params[:api_id]) if params[:api_id]
    @api_param = ApiParam.find(params[:id]) if params[:id]
  end

  def new
    @api_param = ApiParam.new
  end

  def create
    if @api_param = @api_help.api_params.create(params[:api_param])
      return redirect_to "/apis/#{@api_help.id}"
    end
    redirect_to '/apis'
  end

end
