require 'digest'

module Mailchimp
  class << self
    def contact_id(email)
      Digest::MD5.hexdigest(email)
    end

    def contact(email)
      req = Faraday.new(api_server + "/lists/#{audience}/members/")
      req.basic_auth('key', api_key)
      res = req.get(contact_id(email))
      if res.status == 200
        MultiJson.load(res.body)
      else
        raise 'Failed to fetch contact_status'
      end
    end

    def add_contact(email, name)
      names = name.split(' ')
      first_name = names.pop
      last_name = names.join(' ') || ""

      req = Faraday.new(api_server + "/lists/#{audience}/")
      req.headers['Content-Type'] = 'application/json'
      req.basic_auth('key', api_key)
      params = {
        email_address: email,
        status: 'subscribed',
        merge_fields: {
          'FNAME' => first_name,
          'LNAME' => last_name
        }
      }
      res = req.post('members/', params.to_json)
      if res.status == 200
        MultiJson.load(res.body)
      else
        raise 'Failed to fetch contact_status'
      end
    end

    def audience
      ENV['MAILCHIMP_AUDIENCE_ID']
    end

    def api_server
      ENV['MAILCHIMP_API_SERVER']
    end

    def api_key
      ENV['MAILCHIMP_API_KEY']
    end
  end
end
