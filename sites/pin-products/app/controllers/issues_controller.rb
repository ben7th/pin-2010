class IssuesController < ApplicationController
  before_filter :per_load
  def per_load
    @product = Product.find(params[:product_id]) if params[:product_id]
    @issue = Issue.find(params[:id]) if params[:id]
  end
  
  def new
  end
  
  def create
    issue = @product.issues.new(:content=>params[:content])
    if issue.save
      return redirect_to "/issues/#{issue.id}"
    end
    flash[:error] = get_flash_error(issue)
    render :action=>:new
  end
  
  def show
  end
  
  def done
    @issue.done
    redirect_to "/products/#{@issue.product_id}"
  end
  
end
