class ApplicationController < ActionController::Base
  def hello
    render html: "Tom says hello, world!"
  end
end
