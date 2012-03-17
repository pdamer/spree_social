UserSessionsController.class_eval do

  ssl_required :merge

  def merge
    # now sign in from the login form
    authenticate_user!
    unless user_signed_in?
      @user = User.find params[:user][:id]
      @user.email = params[:user][:email]
      
      flash[:error] = I18n.t("devise.failure.invalid")
      render(:template => 'users/merge')
      return
    end

    # prep for all the shifting and do it
    user = User.find(current_user.id)
    user.user_authentications << UserAuthentication.find(params[:user_authentication])
    user.save!

    if current_order
      current_order.associate_user!(user)
      session[:guest_token] = nil
    end
    # trash the old anonymous that was created
    User.destroy(params[:user][:id])

    # tell the truth now
    flash[:alert] = "Succesfully linked your accounts"
    sign_in(user, :event => :authentication)
    redirect_back_or_default(root_path)
  end

end
