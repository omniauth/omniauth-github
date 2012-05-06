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
end
