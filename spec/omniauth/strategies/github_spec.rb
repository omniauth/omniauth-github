require 'spec_helper'

describe OmniAuth::Strategies::GitHub do
  let(:access_token) { double('AccessToken', :options => {}) }
  let(:parsed_response) { double('ParsedResponse') }
  let(:response) { double('Response', :parsed => parsed_response) }

  let(:enterprise_site)          { 'https://some.other.site.com/api/v3' }
  let(:enterprise_authorize_url) { 'https://some.other.site.com/login/oauth/authorize' }
  let(:enterprise_token_url)     { 'https://some.other.site.com/login/oauth/access_token' }
  let(:enterprise) do
    OmniAuth::Strategies::GitHub.new('GITHUB_KEY', 'GITHUB_SECRET',
        {
            :client_options => {
                :site => enterprise_site,
                :authorize_url => enterprise_authorize_url,
                :token_url => enterprise_token_url
            }
        }
    )
  end

  subject do
    OmniAuth::Strategies::GitHub.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  context "client options" do
    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq("https://api.github.com")
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('https://github.com/login/oauth/authorize')
    end

    it 'should have correct token url' do
      expect(subject.options.client_options.token_url).to eq('https://github.com/login/oauth/access_token')
    end

    describe "should be overrideable" do
      it "for site" do
        expect(enterprise.options.client_options.site).to eq(enterprise_site)
      end

      it "for authorize url" do
        expect(enterprise.options.client_options.authorize_url).to eq(enterprise_authorize_url)
      end

      it "for token url" do
        expect(enterprise.options.client_options.token_url).to eq(enterprise_token_url)
      end
    end
  end

  context "#email_access_allowed?" do
    it "should not allow email if scope is nil" do
      expect(subject.options['scope']).to be_nil
      expect(subject).not_to be_email_access_allowed
    end

    it "should allow email if scope is user" do
      subject.options['scope'] = 'user'
      expect(subject).to be_email_access_allowed
    end

    it "should allow email if scope is a bunch of stuff including user" do
      subject.options['scope'] = 'public_repo,user,repo,delete_repo,gist'
      expect(subject).to be_email_access_allowed
    end

    it "should not allow email if scope is other than user" do
      subject.options['scope'] = 'repo'
      expect(subject).not_to be_email_access_allowed
    end

    it "should assume email access not allowed if scope is something currently not documented " do
      subject.options['scope'] = 'currently_not_documented'
      expect(subject).not_to be_email_access_allowed
    end
  end

  context "#email" do
    it "should return email from raw_info if available" do
      allow(subject).to receive(:raw_info).and_return({'email' => 'you@example.com'})
      expect(subject.email).to eq('you@example.com')
    end

    it "should return nil if there is no raw_info and email access is not allowed" do
      allow(subject).to receive(:raw_info).and_return({})
      expect(subject.email).to be_nil
    end

    it "should return the primary email if there is no raw_info and email access is allowed" do
      emails = [
        { 'email' => 'secondary@example.com', 'primary' => false },
        { 'email' => 'primary@example.com',   'primary' => true }
      ]
      allow(subject).to receive(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      allow(subject).to receive(:emails).and_return(emails)
      expect(subject.email).to eq('primary@example.com')
    end

    it "should return the first email if there is no raw_info and email access is allowed" do
      emails = [
        { 'email' => 'first@example.com',   'primary' => false },
        { 'email' => 'second@example.com',  'primary' => false }
      ]
      allow(subject).to receive(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      allow(subject).to receive(:emails).and_return(emails)
      expect(subject.email).to eq('first@example.com')
    end
  end

  context "#raw_info" do
    it "should use relative paths" do
      expect(access_token).to receive(:get).with('user').and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end
  end

  context "#emails" do
    it "should use relative paths" do
      expect(access_token).to receive(:get).with('user/emails', :headers=>{"Accept"=>"application/vnd.github.v3"}).and_return(response)
      subject.options['scope'] = 'user'
      expect(subject.emails).to eq(parsed_response)
    end
  end

end
