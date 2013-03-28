class SessionsController < ApplicationController
  def create
    @user = User.init_for_oauth(params[:provider].intern, auth_hash)
    session[:picture] = auth_hash.info.image

    if @user.save
      sign_in @user
      redirect_to signed_in_path
    else
      redirect_to root_path
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
