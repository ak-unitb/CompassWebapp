class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    logger.debug( "locale: ".concat(I18n.locale.to_s) )
  end

  def not_found
    logger.debug( "In method ApplicationController::not_found" )
    raise ActionController::RoutingError.new('Not Found')
  end




  private

    def record_not_found
      #render plain: "404 Not Found", status: 404
      respond_to do |format|
        #format.html { render plain: "404 Not Found", status: 404 }
        format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
        format.json { render json: { :errors => { :error => "404 Not Found" } }, status: 404 }
        format.xml { render xml: { :error => "404 Not Found" }.to_xml( root: "errors" ), status: 404 }
      end
    end

end
