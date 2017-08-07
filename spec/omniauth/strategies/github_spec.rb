require 'spec_helper'

RSpec.describe OmniAuth::Strategies::GitHub do
  let(:access_token)    { instance_double('AccessToken', :options => {}) }
  let(:parsed_response) { instance_double('ParsedResponse') }
  let(:response)        { instance_double('Response', :parsed => parsed_response) }

  let(:enterprise_site)          { 'https://some.other.site.com/api/v3' }
  let(:enterprise_authorize_url) { 'https://some.other.site.com/login/oauth/authorize' }
  let(:enterprise_token_url)     { 'https://some.other.site.com/login/oauth/access_token' }
  let(:enterprise_client_options) do
    {
      :site          => enterprise_site,
      :authorize_url => enterprise_authorize_url,
      :token_url     => enterprise_token_url
    }
  end
  let(:enterprise) do
    described_class.new('KEY', 'SECRET', :client_options => enterprise_client_options)
  end

  subject { described_class.new({}) }

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  describe '#authorize_params' do
    before do
      allow_super_class = allow_any_instance_of(described_class.superclass)
      allow_super_class.to receive(:session).and_return({})
      allow_super_class.to receive(:authorize_params).and_return('foo' => 'bar')
    end

    it 'should symbolize the hash keys' do
      expect(described_class.new({}).authorize_params).to eq(:foo => 'bar')
    end
  end

  describe '#extra' do
    let(:user)            { double(:user) }
    let(:emails)          { double(:emails) }
    let(:user_response)   { double(:user_response,   :parsed => user) }
    let(:emails_response) { double(:emails_response, :parsed => emails) }

    before do
      allow(access_token).to receive(:get)
      allow(access_token).to receive(:get).with('user/emails', any_args) { emails_response }
      allow(access_token).to receive(:get).with(/^user$/) { user_response }
      allow(subject).to receive(:options).and_return('scope' => 'user')
    end

    it 'should contain raw_info and all_emails' do
      expect(subject.extra).to eq(:raw_info => user, :all_emails => emails)
    end
  end

  context 'client options' do
    let(:client_options) { subject.options.client_options }

    it 'should have correct site' do
      expect(client_options.site).to eq('https://api.github.com')
    end

    it 'should have correct authorize url' do
      expect(client_options.authorize_url).to eq('https://github.com/login/oauth/authorize')
    end

    it 'should have correct token url' do
      expect(client_options.token_url).to eq('https://github.com/login/oauth/access_token')
    end

    describe 'should be overrideable' do
      let(:overridden_options) { enterprise.options.client_options }

      it 'for site' do
        expect(overridden_options.site).to eq(enterprise_site)
      end

      it 'for authorize url' do
        expect(overridden_options.authorize_url).to eq(enterprise_authorize_url)
      end

      it 'for token url' do
        expect(overridden_options.token_url).to eq(enterprise_token_url)
      end
    end
  end

  context '#email_access_allowed?' do
    it 'should not allow email if scope is nil' do
      subject.options['scope'] = nil
      expect(subject).not_to be_email_access_allowed
    end

    it 'should allow email if scope is user' do
      subject.options['scope'] = 'user'
      expect(subject).to be_email_access_allowed
    end

    it 'should allow email if scope is a bunch of stuff including user' do
      subject.options['scope'] = 'public_repo,user,repo,delete_repo,gist'
      expect(subject).to be_email_access_allowed
    end

    it 'should not allow email if scope does not grant email access' do
      subject.options['scope'] = 'repo,user:follow'
      expect(subject).not_to be_email_access_allowed
    end

    it 'should assume email access not allowed if scope is something currently not documented' do
      subject.options['scope'] = 'currently_not_documented'
      expect(subject).not_to be_email_access_allowed
    end
  end

  context '#email' do
    it 'should return email from raw_info if available' do
      allow(subject).to receive(:raw_info).and_return({ 'email' => 'you@example.com' })
      expect(subject.email).to eq('you@example.com')
    end

    it 'should return nil if there is no raw_info and email access is not allowed' do
      allow(subject).to receive(:raw_info).and_return({})
      expect(subject.email).to be_nil
    end

    it 'should not return the primary email if there is no raw_info and email access is allowed' do
      emails = [
        { 'email' => 'secondary@example.com', 'primary' => false },
        { 'email' => 'primary@example.com',   'primary' => true }
      ]
      allow(subject).to receive(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      allow(subject).to receive(:emails).and_return(emails)
      expect(subject.email).to be_nil
    end

    it 'should not return the first email if there is no raw_info and email access is allowed' do
      emails = [
        { 'email' => 'first@example.com',   'primary' => false },
        { 'email' => 'second@example.com',  'primary' => false }
      ]
      allow(subject).to receive(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      allow(subject).to receive(:emails).and_return(emails)
      expect(subject.email).to be_nil
    end
  end

  context '#raw_info' do
    it 'should use relative paths' do
      expect(access_token).to receive(:get).with('user').and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end
  end

  context '#emails' do
    it 'should use relative paths' do
      expect(access_token).to receive(:get).with('user/emails', :headers => {
        'Accept' => 'application/vnd.github.v3'
      }).and_return(response)

      subject.options['scope'] = 'user'
      expect(subject.emails).to eq(parsed_response)
    end
  end

  context '#info.email' do
    it 'should use any available email' do
      allow(subject).to receive(:raw_info).and_return({})
      allow(subject).to receive(:email).and_return('you@example.com')
      expect(subject.info['email']).to eq('you@example.com')
    end
  end

  context '#info.urls' do
    it 'should use html_url from raw_info' do
      allow(subject).to receive(:raw_info).and_return({ 'login' => 'me', 'html_url' => 'http://enterprise/me' })
      expect(subject.info['urls']['GitHub']).to eq('http://enterprise/me')
    end
  end

  describe '#callback_url' do
    it 'is a combination of host, script name, and callback path' do
      allow(subject).to receive(:full_host).and_return('https://example.com')
      allow(subject).to receive(:script_name).and_return('/sub_uri')

      expect(subject.callback_url).to eq('https://example.com/sub_uri/auth/github/callback')
    end
  end
end
