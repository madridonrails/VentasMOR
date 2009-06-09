ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.smtp_settings   = Config.smtp_settings

#require "tlsmail"
#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)