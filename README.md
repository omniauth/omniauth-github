![Ruby](https://github.com/omniauth/omniauth-github/workflows/Ruby/badge.svg?branch=master)

# OmniAuth GitHub

This is the official OmniAuth strategy for authenticating to GitHub. To
use it, you'll need to sign up for an OAuth2 Application ID and Secret
on the [GitHub Applications Page](https://github.com/settings/applications).

## Installation

```ruby
gem 'omniauth-github', github: 'omniauth/omniauth-github', branch: 'master'
```

## Basic Usage

```ruby
use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end
```


## Basic Usage Rails

In `config/initializers/github.rb`

```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  end
```


## Github Enterprise Usage

```ruby
provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'],
    {
      :client_options => {
        :site => 'https://github.YOURDOMAIN.com/api/v3',
        :authorize_url => 'https://github.YOURDOMAIN.com/login/oauth/authorize',
        :token_url => 'https://github.YOURDOMAIN.com/login/oauth/access_token',
      }
    }
```

## Scopes

GitHub API v3 lets you set scopes to provide granular access to different types of data: 

```ruby
use OmniAuth::Builder do
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET'], scope: "user,repo,gist"
end
```

More info on [Scopes](https://docs.github.com/en/developers/apps/scopes-for-oauth-apps).

## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:
```json
{
  "provider": "github",
  "uid": "50639655",
  "info": {
    "nickname": "nejdetkadir",
    "email": "nejdetkadir.550@gmail.com",
    "name": "Nejdet Kadir Bektaş",
    "image": "https://avatars.githubusercontent.com/u/50639655?v=4",
    "urls": {
      "GitHub": "https://github.com/nejdetkadir",
      "Blog": "www.nejdetkadirbektas.com"
    }
  },
  "credentials": {
    "token": "token",
    "expires": false
  },
  "extra": {
    "raw_info": {
      "login": "nejdetkadir",
      "id": 50639655,
      "node_id": "MDQ6VXNlcjUwNjM5NjU1",
      "avatar_url": "https://avatars.githubusercontent.com/u/50639655?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/nejdetkadir",
      "html_url": "https://github.com/nejdetkadir",
      "followers_url": "https://api.github.com/users/nejdetkadir/followers",
      "following_url": "https://api.github.com/users/nejdetkadir/following{/other_user}",
      "gists_url": "https://api.github.com/users/nejdetkadir/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/nejdetkadir/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/nejdetkadir/subscriptions",
      "organizations_url": "https://api.github.com/users/nejdetkadir/orgs",
      "repos_url": "https://api.github.com/users/nejdetkadir/repos",
      "events_url": "https://api.github.com/users/nejdetkadir/events{/privacy}",
      "received_events_url": "https://api.github.com/users/nejdetkadir/received_events",
      "type": "User",
      "site_admin": false,
      "name": "Nejdet Kadir Bektaş",
      "company": null,
      "blog": "www.nejdetkadirbektas.com",
      "location": "Samsun",
      "email": null,
      "hireable": null,
      "bio": "Ruby on Rails, Javascript, GNU/Linux",
      "twitter_username": null,
      "public_repos": 88,
      "public_gists": 0,
      "followers": 46,
      "following": 102,
      "created_at": "2019-05-14T20:29:52Z",
      "updated_at": "2021-04-21T02:37:32Z",
      "private_gists": 0,
      "total_private_repos": 18,
      "owned_private_repos": 18,
      "disk_usage": 207250,
      "collaborators": 3,
      "two_factor_authentication": true,
      "plan": {
        "name": "pro",
        "space": 976562499,
        "collaborators": 0,
        "private_repos": 9999
      }
    },
    "all_emails": [
      {
        "email": "nejdetkadir.550@gmail.com",
        "primary": true,
        "verified": true,
        "visibility": "private"
      }
    ],
    "scope": "public_repo,user"
  }
}
```

## Semver
This project adheres to Semantic Versioning 2.0.0. Any violations of this scheme are considered to be bugs. 
All changes will be tracked [here](https://github.com/omniauth/omniauth-github/releases).

## License

Copyright (c) 2011 Michael Bleigh and Intridea, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
