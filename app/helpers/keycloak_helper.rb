module KeycloakHelper
  def self.openid_config
    res = Faraday.get "#{site}/auth/realms/#{realm}/.well-known/openid-configuration"
    if (res.status == 200)
      MultiJson.load(res.body)
    else
      raise 'failed to fetch config'
    end
  end

  def self.end_session_endpoint
    openid_config['end_session_endpoint']
  end

  def self.sign_out(refresh_token)
    params = {
      'client_id' => client_id,
      'client_secret' => client_secret,
      'refresh_token' => refresh_token
    }
    res = Faraday.post(end_session_endpoint, params, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    if (res.status == 204)
      nil
    else
      raise 'failed to sign_out'
    end
  end

  def self.token_endpoint
    openid_config['token_endpoint']
  end

  # To manage and view users on Keycloak, the service_account must have 'manage users'
  # and 'view users' client roles, from client realm-management.
  def self.service_account
    params = {
      'client_id' => client_id,
      'client_secret' => client_secret,
      'grant_type' => 'client_credentials',
    }
    headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
    res = Faraday.post(token_endpoint, params, headers) 
    if (res.status == 200)
      MultiJson.load(res.body)
    else
      raise 'failed to fetch keycloak service account'
    end
  end

  def self.users_uri
    uri = URI(site)
    uri.path = "/auth/admin/realms/#{realm}/users"
    uri
  end

  def self.users_search(email)
    uri = users_uri
    uri.query = "search=#{email}"
    token = service_account['access_token']
    res = Faraday.get(uri.to_s, nil, { 'Authorization' => "Bearer #{token}" })
    if (res.status == 200)
      MultiJson.load(res.body)
    else
      raise 'failed to search for users'
    end
  end

  def self.create_user(email, password, first_name, last_name)
    user_rep = {
      username: email,
      email: email,
      firstName: first_name,
      lastName: last_name,
      enabled: true,
      credentials: [{
        type: "password",
        temporary: false,
        value: password
      }]
    }
    token = service_account['access_token']
    headers = {
      'Authorization' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
    res = Faraday.post(users_uri.to_s, user_rep.to_json, headers)
    if (res.status == 201)
      MultiJson.load(res.body)
    else
      raise 'failed to create_user'
    end
  end

  def self.keycloak_oauth_config
    Devise.omniauth_configs[:keycloak_openid].strategy
  end

  def self.client_id
    keycloak_oauth_config['client_id']
  end

  def self.client_secret
    keycloak_oauth_config['client_secret']
  end

  def self.site
    keycloak_oauth_config['client_options']['site']
  end

  def self.realm
    keycloak_oauth_config['client_options']['realm']
  end
end
