class SessionsController < ApplicationController
  include SessionsHelper
  protect_from_forgery

  # GET /signin
  def new
    @title = "Sign in"
  end

  # POST /sessions
  def create
    email = params[:session][:email]
    pw = params[:session][:password]

    user = User.authenticate(email, pw)

    if user.nil?
      flash.now[:error] = "Invalid email/password combination"
      @title = "Sign in"

      render(:new)
    else
      sign_in(user)

      redirect_back_or(user)
    end
  end

  # DELETE /signout
  def destroy
    sign_out

    redirect_to(root_path)
  end
end
