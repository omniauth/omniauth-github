require 'spec_helper'

describe OmniAuth::Strategies::GitHub do
  subject do
    OmniAuth::Strategies::GitHub.new({})
  end

  context "client options" do
    it 'should have correct site' do
      subject.options.client_options.site.should eq("https://api.github.com")
    end

    it 'should have correct authorize url' do
      subject.options.client_options.authorize_url.should eq('https://github.com/login/oauth/authorize')
    end

    it 'should have correct token url' do
      subject.options.client_options.token_url.should eq('https://github.com/login/oauth/access_token')
    end
  end

  context "#email_access_allowed?" do
    it "should not allow email if scope is nil" do
      subject.options['scope'].should be_nil
      subject.should_not be_email_access_allowed
    end

    it "should not allow email if scope is 'public'" do
      subject.options['scope'] = 'public'
      subject.should_not be_email_access_allowed
    end

    it "should allow email if scope is user" do
      subject.options['scope'] = 'user'
      subject.should be_email_access_allowed
    end

    it "should allow email if scope is scope is a bunch of stuff" do
      subject.options['scope'] = 'user,public_repo,repo,delete_repo,gist'
      subject.should be_email_access_allowed
    end

    it "should assume email access allowed if scope is scope is something currently not documented " do
      subject.options['scope'] = 'currently_not_documented'
      subject.should be_email_access_allowed
    end
  end

  context "#email" do
    it "should return email from raw_info if available" do
      subject.stub!(:raw_info).and_return({'email' => 'you@example.com'})
      subject.email.should eq('you@example.com')
    end

    it "should return nil if there is no raw_info and email access is not allowed" do
      subject.stub!(:raw_info).and_return({})
      subject.email.should be_nil
    end

    it "should return the first email if there is no raw_info and email access is allowed" do
      subject.stub!(:raw_info).and_return({})
      subject.options['scope'] = 'user'
      subject.stub!(:emails).and_return([ 'you@example.com' ])
      subject.email.should eq('you@example.com')
    end
  end

end
