require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"
  
  fixtures :accounts
  include ActionMailer::Quoting
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_send_welcome    
    @account = Account.find(:first)
    url_for_account = 'account link'    
    response = Mailer.deliver_welcome(@account, url_for_account)
    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal response, ActionMailer::Base.deliveries[0]
    assert_equal @account.email, response.to[0]
    assert_match %r{#{url_for_account}}, response.body
  end
  def test_send_accounts_reminder
    @account = Account.find(:first)    
    users = User.find_all_by_email(@account.email)
    unless users.empty?
      urls = users.map {|u| "http://#{u.account.short_name}.localhost.com"}
      response = Mailer.deliver_accounts_reminder(@account.email, urls)
      assert_equal 1, ActionMailer::Base.deliveries.length
      assert_equal response, ActionMailer::Base.deliveries[0]
      assert_equal @account.email, response.to[0]
      assert_match %r{#{urls.join("\n  ")}}, response.body
    end
  end  
    
  def test_send_devalert
    subject = 'example subject'
    body = 'example body'
    extra_to = 'example@example.com'
    response = Mailer.deliver_devalert(subject,body,extra_to)
    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal response, ActionMailer::Base.deliveries[0]
    assert_equal subject, response.subject
    assert_equal ALERT_EMAIL_DEV, response.header["from"].to_s
    assert_equal [CONTACT_EMAIL_ACCOUNTS, extra_to].compact.join(', '), response.to.compact.join(', ')
    assert_match %r{#{body}}, response.body
  end
  
  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end

