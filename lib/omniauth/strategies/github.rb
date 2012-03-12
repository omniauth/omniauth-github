require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class GitHub < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => 'https://api.github.com',
        :authorize_url => 'https://github.com/login/oauth/authorize',
        :token_url => 'https://github.com/login/oauth/access_token'
      }

      def request_phase
        super
      end

      # Split the user's full name into first and last
      if raw_info['name'] =~ /[a-zA-Z]+\s[a-zA-Z]+/
        (first_name, last_name) = raw_info['name'].split(' ')
      end
      
      uid { raw_info['id'] }

      info do
        {
          'nickname' => raw_info['login'],
          'email' => raw_info['email'],
          'name' => raw_info['name'],
          'first_name' => first_name ||= '',
          'last_name' => last_name ||= '',
          'location' => raw_info['location'],
          'description' => raw_info['bio'],
          'image' => raw_info['avatar_url'],
          'urls' => {
            'GitHub' => "https://github.com/#{raw_info['login']}",
            'Blog' => raw_info['blog'],
          },
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        access_token.options[:mode] = :query
        @raw_info ||= access_token.get('/user').parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'github', 'GitHub'
