# OmniAuth GitHub

This is the official OmniAuth strategy for authenticating to GitHub. To
use it, you'll need to sign up for an OAuth2 Application ID and Secret
on the [GitHub Applications Page](https://github.com/settings/applications).

## Basic Usage

Add to your `Gemfile`:
```
gem 'omniauth-github'
```

Then `bundle install`

Create an initializer `config/initializers/omniauth.rb`:
```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end
```
## Github Callback

When a user on your site visits `/auth/github` and will be redirected to Github and asked to verify permissions. When they accept, they will be sent back to your site based on the callback setting for the application you setup. [https://developer.github.com/v3/oauth/](Read Github OAuth documentation)

When the user is redirected back to your site, the callback URL will have the following variables available:
The response to Rails in `env.omniauth`:

`env.omniauth # => [:uid, :provider, info: :name, credentials: :token]`

## Example

Setup your Rails app and signup for a OAuth Application as described above.

### 1. Generate a new controller:

```
rails g controller Sessions
```

### 2. Generate a user model:

```
rails g model user provider uid name oauth_token oauth_expires_at:datetime
rake db:migrate
```

### 3. Add to your `Gemfile`:

```
gem 'omniauth-github'
```

Then `bundle install`

### 4. Create an initializer `config/initializers/omniauth.rb`:

```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end
```

### 5. Add these routes to `config/routes.rb`:

```
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
```

### 6. Add create and destroy actions to SessionsController:

```
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
```

### 7. Add a class method to User:

```
class User < ActiveRecord::Base

  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid: auth[:uid]).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.try(:expires_at)
      user.save!
    end
  end
end
```

### 8. Add a `current_user` method to ApplicationController:

```
class ApplicationController < ActionController::Base

  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
```

### 9. Add link to signin in application layout:

```
  <div>
    <% if current_user %>
      Signed in as <strong><%= current_user.name %></strong>!
      <%= link_to "Sign out", signout_path, id: "sign_out" %>
    <% else %>
      <%= link_to "Sign in with Github", "/auth/github", id: "sign_in" %>
    <% end %>
  </div>
```

This example based on the article by RichOnRails, [Google authentication in Ruby on Rails](http://richonrails.com/articles/google-authentication-in-ruby-on-rails)

## Github Enterprise Usage
```
provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
{
  :client_options => {
    :site => 'https://github.YOURDOMAIN.com/api/v3',
    :site => 'https://github.YOURDOMAIN.com/',
    :authorize_url => 'https://github.YOURDOMAIN.com/login/oauth/authorize',
    :token_url => 'https://github.YOURDOMAIN.com/login/oauth/access_token',
  }
}
```

## Scopes

GitHub API v3 lets you set scopes to provide granular access to different types of data: 

  	use OmniAuth::Builder do
      provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo,gist"
    end

More info on [Scopes](http://developer.github.com/v3/oauth/#scopes).

## License

Copyright (c) 2011 Michael Bleigh and Intridea, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
