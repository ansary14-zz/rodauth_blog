class RodauthMain < Rodauth::Rails::Auth
  configure do
    # List of authentication features that are loaded.
    enable :create_account, :verify_account, :verify_account_grace_period,
      :login, :logout, :remember,
      :reset_password, :change_password, :change_password_notify,
      :change_login, :verify_login_change, :close_account,
      :otp, :recovery_codes,
      :oauth, :oidc

    # See the Rodauth documentation for the list of available config options:
    # http://rodauth.jeremyevans.net/documentation.html

    # ==> General
    # The secret key used for hashing public-facing tokens for various features.
    # Defaults to Rails `secret_key_base`, but you can use your own secret key.
    # hmac_secret "04de0364cd1b4c3dfce5a2a70d738a26d667912887e4f6fce0d588f575ae4b0744945ad492b889c16369faabb260723fa9f15dc811e09fbc570116a4f1b4823a"

    #validate that name filled in and create the associated profile record after the account is created
    before_create_account do
      # Validate presence of the name field
      throw_error_status(422, "name", "must be present") unless param_or_nil("name")
    end
    after_create_account do
      # Create the associated profile record with name
      Profile.create!(account_id: account_id, name: param("name"))
    end
    after_close_account do
      # Delete the associated profile record
      Profile.find_by!(account_id: account_id).destroy
    end

    # auto generate recovery codes after TOTP setup
    auto_add_recovery_codes? true
    # display recovery codes after TOTP setup
    after_otp_setup do
      set_notice_now_flash "#{otp_setup_notice_flash}, please make note of your recovery codes"
      response.write add_recovery_codes_view
      request.halt # don't process the request any further
    end

    # Specify the controller used for view rendering and CSRF verification.
    rails_controller { RodauthController }

    # Store account status in a text column.
    account_status_column :status
    account_unverified_status_value "unverified"
    account_open_status_value "verified"
    account_closed_status_value "closed"

    # Make sure you hash the refresh tokens in the DB.
    oauth_tokens_refresh_token_hash_column :refresh_token_hash

    # list of OIDC and OAuth scopes you handle
    oauth_application_scopes %w[openid email profile posts.read]

    # default scopes to give to new applications, application-management specific
    oauth_application_default_scope %w[openid email profile posts.read]

    # by default you're only allowed to use https redirect URIs. But we're developing,
    # so it's fine.
    if Rails.env.development?
      oauth_valid_uri_schemes %w[http https]
    end

    # multiple times.
    get_oidc_param do |account, param|
      @profile ||= Profile.find_by(account_id: account[:id])
      case param
      when :email
        account[:email]
      when :email_verified
        account[:status] == "verified"
      when :name
        @profile.name
      end
    end

    # Store password hash in a column instead of a separate table.
    # account_password_hash_column :password_digest

    # Set password when creating account instead of when verifying.
    verify_account_set_password? false

    # Redirect back to originally requested location after authentication.
    # login_return_to_requested_location? true
    # two_factor_auth_return_to_requested_location? true # if using MFA

    # Autologin the user after they have reset their password.
    # reset_password_autologin? true

    # Delete the account record when the user has closed their account.
    # delete_account_on_close? true

    # Redirect to the app from login and registration pages if already logged in.
    # already_logged_in { redirect login_redirect }

    # ==> Emails
    # Use a custom mailer for delivering authentication emails.
    create_reset_password_email do
      RodauthMailer.reset_password(account_id, reset_password_key_value)
    end
    create_verify_account_email do
      RodauthMailer.verify_account(account_id, verify_account_key_value)
    end
    create_verify_login_change_email do |_login|
      RodauthMailer.verify_login_change(account_id, verify_login_change_old_login, verify_login_change_new_login, verify_login_change_key_value)
    end
    create_password_changed_email do
      RodauthMailer.password_changed(account_id)
    end
    # create_email_auth_email do
    #   RodauthMailer.email_auth(account_id, email_auth_key_value)
    # end
    # create_unlock_account_email do
    #   RodauthMailer.unlock_account(account_id, unlock_account_key_value)
    # end
    send_email do |email|
      # queue email delivery on the mailer after the transaction commits
      db.after_commit { email.deliver_later }
    end

    # ==> Flash
    # Match flash keys with ones already used in the Rails app.
    # flash_notice_key :success # default is :notice
    # flash_error_key :error # default is :alert

    # Override default flash messages.
    # create_account_notice_flash "Your account has been created. Please verify your account by visiting the confirmation link sent to your email address."
    # require_login_error_flash "Login is required for accessing this page"
    # login_notice_flash nil

    # ==> Validation
    # Override default validation error messages.
    # no_matching_login_message "user with this email address doesn't exist"
    # already_an_account_with_this_login_message "user with this email address already exists"
    # password_too_short_message { "needs to have at least #{password_minimum_length} characters" }
    # login_does_not_meet_requirements_message { "invalid email#{", #{login_requirement_message}" if login_requirement_message}" }

    # Change minimum number of password characters required when creating an account.
    # password_minimum_length 8

    # ==> Remember Feature
    # Remember all logged in users.
    after_login { remember_login }

    # Or only remember users that have ticked a "Remember Me" checkbox on login.
    # after_login { remember_login if param_or_nil("remember") }

    # Extend user's remember period when remembered via a cookie
    extend_remember_deadline? true

    # ==> Hooks
    # Validate custom fields in the create account form.
    # before_create_account do
    #   throw_error_status(422, "name", "must be present") if param("name").empty?
    # end

    # Perform additional actions after the account is created.
    # after_create_account do
    #   Profile.create!(account_id: account_id, name: param("name"))
    # end

    # Do additional cleanup after the account is closed.
    # after_close_account do
    #   Profile.find_by!(account_id: account_id).destroy
    # end

    # ==> Redirects
    # Redirect to home page after logout.
    logout_redirect "/"

    # Redirect to wherever login redirects to after account verification.
    verify_account_redirect { login_redirect }

    # Redirect to login page after password reset.
    reset_password_redirect { login_path }

    # redirect the user to the MFA page if they have MFA setup
    login_redirect do
      if uses_two_factor_authentication?
        two_factor_auth_required_redirect
      else
        "/"
      end
    end

    # ==> Deadlines
    # Change default deadlines for some actions.
    # verify_account_grace_period 3.days
    # reset_password_deadline_interval Hash[hours: 6]
    # verify_login_change_deadline_interval Hash[days: 2]
    # remember_deadline_interval Hash[days: 30]
  end
end
