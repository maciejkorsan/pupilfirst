require 'rails_helper'

describe Users::MailFirstPasswordTokenService do
  include RoutesResolvable

  let!(:school) { create :school, :current }
  let!(:user) { create :user }

  subject { described_class.new(school, user) }

  it 'regenerate password token' do
    expect(user).to receive(:regenerate_reset_password_token)

    subject.execute
  end

  it 'update when the reset password was sent' do
    expect do
      subject.execute
    end.to change { user.reset_password_sent_at.to_i / 100 }.to(Time.zone.now.to_i / 100)
  end

  it 'uses reset_password action on link' do
    regex = Regexp.new(url_helpers.reset_password_path)
    expect(UserSessionMailer).to receive(:set_first_password_token).with(user, school, regex).and_call_original

    subject.execute
  end

  it 'uses schools first primary domain on link' do
    domain = school.domains.where(primary: true).first

    regex = Regexp.new(domain.fqdn)
    expect(UserSessionMailer).to receive(:set_first_password_token).with(user, school, regex).and_call_original

    subject.execute
  end

  it 'link contains reset_password_token' do
    reset_password_token = 'test_reset_password_token'
    allow(user).to receive(:reset_password_token) { reset_password_token }
    uri_param = URI.encode_www_form(token: reset_password_token)

    regex = Regexp.new(uri_param)
    expect(UserSessionMailer).to receive(:set_first_password_token).with(user, school, regex).and_call_original

    subject.execute
  end

  it 'link contains referrer for school dashboard' do
    reset_password_token = 'test_reset_password_token'
    allow(user).to receive(:reset_password_token) { reset_password_token }

    domain = school.domains.where(primary: true).first

    url_options = {
      token: reset_password_token,
      host: domain.fqdn,
      protocol: 'https'
    }

    uri_param = URI.encode_www_form(referrer: url_helpers.school_url(school, **url_options))
    regex = Regexp.new(uri_param)
    expect(UserSessionMailer).to receive(:set_first_password_token).with(user, school, regex).and_call_original

    subject.execute
  end

  it 'trigger delivery of UserSessionMailer#set_first_password_token' do 
    mailer = double('UserSessionMailer')

    allow(UserSessionMailer).to receive(:set_first_password_token) { mailer }
    expect(mailer).to receive(:deliver_now)

    subject.execute
  end
end
