class RodauthController < ApplicationController
  # used by Rodauth for rendering views, CSRF protection, and running any
  # registered action callbacks and rescue_from handlers

  def download_recovery_codes
    rodauth.require_authentication

    send_data rodauth.recovery_codes.join("\n"),
      filename: "myapp-recovery-codes.txt",
      type: "text/plain"
  end
end
