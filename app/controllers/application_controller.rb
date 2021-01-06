class ApplicationController < ActionController::Base
  include SessionsHelper
  
  private
  
    #Confirms a logged in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please lg in."
        redirect_to login_url
      end
    end
end
