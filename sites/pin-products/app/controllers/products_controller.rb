class ProductsController < ApplicationController
  before_filter :per_load
  def per_load
    @product = Product.find(params[:id]) if params[:id]
  end
  
  def index
    @products = Product.order("id asc")
  end
  
  def new
  end
  
  def create
    product = Product.new(:name=>params[:name],:code=>params[:code],:description=>params[:description])
    if product.save
      return redirect_to "/products/#{product.id}"
    end
    flash[:error] = get_flash_error(product)
    render :action=>:new
  end
  
  def edit
  end
  
  def update
    if @product.update_attributes(params[:product])
      return redirect_to "/products/#{@product.id}"
    end
    flash[:error] = get_flash_error(@product)
    render :action=>:edit
  end
  
  def show
  end
  
  def edit_server_develop_description
  end
  
  def update_server_develop_description
    update_description(:server_develop_description)
  end
  
  def edit_web_ui_develop_description
  end
  
  def update_web_ui_develop_description
    update_description(:web_ui_develop_description)
  end
  
  def edit_mobile_client_develop_description
  end
  
  def update_mobile_client_develop_description
    update_description(:mobile_client_develop_description)
  end
  
  def edit_deploy_description
  end
  
  def update_deploy_description
    update_description(:deploy_description)
  end
  
  def edit_difficulty
  end
  
  def update_difficulty
    update_description(:difficulty)
  end
  
  def update_description(attr)
    action = "edit_#{attr.to_s}".to_sym
    if @product.update_attribute(attr,params[attr])
      return redirect_to "/products/#{@product.id}"
    end
    flash[:error] = get_flash_error(@product)
    render :action=>action
  end
end
