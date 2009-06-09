class Mailer < ActionMailer::Base
  def welcome(account, url_for_account)
    set_common_ivars_from_template('welcome', binding)
    @recipients = account.email
  end

  def accounts_reminder(email, urls)
    set_common_ivars_from_template('accounts_reminder', binding)
    @recipients = email
  end

  def random_password(user, password)
    set_common_ivars_from_template('chpass_instructions', binding)
    @recipients = user.email
  end

  # Alerts to monitorize application health.
  def devalert(subject, body='', extra_to=[])
    recipients  = CONTACT_EMAIL_ACCOUNTS
    if RAILS_ENV == 'production'
      extra_to   = [extra_to] if extra_to.is_a?(String)
      recipients = [recipients].concat(extra_to).join(',')
    end
    @subject    = subject
    @body       = {:msg => body}
    @recipients = recipients
    @from       = ALERT_EMAIL_DEV
    @sent_on    = Time.now
    @headers    = {}
  end

  def set_common_ivars_from_template(mail_key, local_vars)
    config   = Config.send("#{mail_key}_mail")
    @from    = process(config['from'], local_vars)
    @subject = process(config['subject'], local_vars)
    @body    = {:msg => process(config['body'], local_vars)}
    @sent_on = Time.now
    @headers = {}
  end
  
  def process(template, local_vars)
    ERB.new(template).result(local_vars)
  end
end
