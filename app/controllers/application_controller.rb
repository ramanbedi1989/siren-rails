class ApplicationController < ActionController::API
  include Authenticable
  before_filter :authenticate_with_token!
end
