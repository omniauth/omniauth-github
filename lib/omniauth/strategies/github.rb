require 'omniauth-oauth2'

class OmniAuth::Strategies::GitHub < OmniAuth::Strategies::OAuth2
  option :client_options, {
    :site          => 'https://api.github.com',
    :authorize_url => 'https://github.com/login/oauth/authorize',
    :token_url     => 'https://github.com/login/oauth/access_token'
  }

  def authorize_params
    key_value_pairs = super.map { |(k,v)| [k.to_sym, v] }
    Hash[key_value_pairs]
  end

  uid { "#{raw_info['id']}" }

  info do
    {
      'nickname' => raw_info['login'],
      'email'    => email,
      'name'     => raw_info['name'],
      'image'    => raw_info['avatar_url'],
      'urls'     => {
        'GitHub' => raw_info['html_url'],
        'Blog'   => raw_info['blog'],
      }
    }
  end

  extra { { :raw_info => raw_info, :all_emails => emails } }

  def email
    email_access_allowed? ? primary_email : raw_info['email']
  end

  def raw_info
    @raw_info ||= get_github_user_info
  end

  def primary_email
    primary = emails.find { |i| i['primary'] && i['verified'] }
    primary && primary['email'] || nil
  end

  # The new /user/emails API - http://developer.github.com/v3/users/emails/#future-response
  def emails
    @emails ||= email_access_allowed? ? get_github_user_emails : []
  end

  def email_access_allowed?
    return false unless options['scope']
    email_scopes = ['user', 'user:email']
    scopes = options['scope'].split(',')
    (scopes & email_scopes).any?
  end

  def callback_url
    "#{full_host}#{script_name}#{callback_path}"
  end

  private

  def get_github_user_info
    get_github_info('user')
  end

  def get_github_user_emails
    get_github_info('user/emails', 'Accept' => 'application/vnd.github.v3')
  end

  def get_github_info(path, headers = {})
    access_token.options[:mode] = :query
    args = headers.empty? ? [path] : [path, :headers => headers]
    access_token.get(*args).parsed
  end
end

OmniAuth.config.add_camelization 'github', 'GitHub'
