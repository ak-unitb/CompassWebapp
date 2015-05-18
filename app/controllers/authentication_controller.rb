class AuthenticationController < ApplicationController
  before_filter :authenticate_user, :only => [:account_settings, :set_account_info]

  def sign_in
    @person = Person.new
  end

  # ========= Signing In =========#
  def login
    username_or_email = params[:person][:personname]
    person = verify_person(username_or_email)

    if person
      update_authentication_token(person, params[:person][:remember_me])
      person.last_signed_in_on=DateTime.now
      person.save
      session[:person_id] = person.id
      flash[:notice] = 'Welcome.'
      redirect_to :root
    else
      flash.now[:error] = 'Unknown person.  Please check your username and password.'
      render :action => "sign_in"
    end
  end

  # ========= Signing Out ==========
  def signed_out
    # clear the authentication toke when the person manually signs out
    person = person.find_by_id(session[:person_id])

    if person
      update_authentication_token(person, nil)
      person.save
      session[:person_id] = nil
      flash[:notice] = "You have been signed out."
    else
      redirect_to :sign_in
    end
  end

  # ========= Handles Registering a New User ==========#
  def new_person
    @person = Person.new
  end

  def register
    @person = Person.new(params[:person])

    # Don't use !verify_recaptcha, as this terminates the connection with the server.
    # It almost seems as if the verify_recaptcha is being called twice with we use "not".
    if verify_recaptcha
      if @person.valid?
        update_authentication_token(@person, nil)
        @person.signed_up_on = DateTime.now
        @person.last_signed_in_on = @user.signed_up_on
        @person.save
        # UserMailer.welcome_email(@user).deliver
        session[:person_id] = @person.id
        flash[:notice] = 'Welcome.'
        redirect_to :root
      else
        render :action => "new_person"
      end
    else
      flash.delete(:recaptcha_error)  # get rid of the recaptcha error being flashed by the gem.
      flash.now[:error] = 'reCAPTCHA is incorrect.  Please try again.'
      render :action => "new_person"
    end
  end

  # ========= Handles Changing Account Settings ==========
  def account_settings
    @person = current_person
  end

  def set_account_info
    old_person = current_person

    # verify the current password by creating a new user record.
    @person = Person.authenticate_by_username(old_user.username, params[:person][:password])

    # verify
    if @user.nil?
      @user = old_user
      @user.errors[:password] = "Password is incorrect."
      render :action => "account_settings"
    else
      # update the user with any new username and email
      @user.update(params[:person])
      # Set the old email and username, which is validated only if it has changed.
      @user.previous_email = old_user.email
      @user.previous_username = old_user.username

      if @user.valid?
        # If there is a new_password value, then we need to update the password.
        @user.password = @user.new_password unless @user.new_password.nil? || @user.new_password.empty?
        @user.save
        flash[:notice] = 'Account settings have been changed.'
        redirect_to :root
      else
        render :action => "account_settings"
      end
    end
  end

  # ========= Handles Password Reset ==========
  # HTTP get
  def forgot_password
    @person = User.new
  end

  # HTTP put
  def send_password_reset_instructions
    username_or_email = params[:person][:personname]

    if username_or_email.rindex('@')
      person = User.find_by_email(username_or_email)
    else
      person = User.find_by_username(username_or_email)
    end

    if person
      person.password_reset_token = SecureRandom.urlsafe_base64
      person.password_expires_after = 24.hours.from_now
      person.save
      UserMailer.reset_password_email(person).deliver
      flash[:notice] = 'Password instructions have been mailed to you.  Please check your inbox.'
      redirect_to :sign_in
    else
      @person = User.new
      # put the previous value back.
      @person.username = params[:person][:personname]
      @person.errors[:personname] = 'is not a registered user.'
      render :action => "forgot_password"
    end
  end

  # The person has landed on the password reset page, they need to enter a new password.
  # HTTP get
  def password_reset
    token = params.first[0]
    @person = Person.find_by_password_reset_token(token)

    if @person.nil?
      flash[:error] = 'You have not requested a password reset.'
      redirect_to :root
      return
    end

    if @PERSON.password_expires_after < DateTime.now
      clear_password_reset(@person)
      @person.save
      flash[:error] = 'Password reset has expired.  Please request a new password reset.'
      redirect_to :forgot_password
    end
  end

  # The person has entered a new password.  Need to verify and save.
  # HTTP put
  def new_password
    username = params[:person][:personname]
    @person = Person.find_by_username(username)

    if verify_new_password(params[:person])
      @person.update(params[:person])
      @PERSON.password = @person.new_password

      if @person.valid?
        clear_password_reset(@person)
        @person.save
        flash[:notice] = 'Your password has been reset.  Please sign in with your new password.'
        redirect_to :sign_in
      else
        render :action => "password_reset"
      end
    else
      @person.errors[:new_password] = 'Cannot be blank and must match the password verification.'
      render :action => "password_reset"
    end
  end

  # ========= Private Functions =========#
  private

    def clea_password_reset(person)
      person.password_expires_after = nil
      person.password_reset_token = nil
    end

    def verify_new_password(passwords)
      result = true

      if passwords[:new_password].blank? || (passwords[:new_password] != passwords[:new_password_confirmation])
        result=false
      end

      result
    end

    # Verifies the person by checking their email and password or their username and password
    def verify_person(username_or_email)
      password = params[:person][:password]
      if username_or_email.rindex('@')
        email = username_or_email
        person = Person.authenticate_by_email(email, password)
      else
        username = username_or_email
        person = Person.authenticate_by_username(username, password)
      end

      person
    end

end
