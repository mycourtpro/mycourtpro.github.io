#--
# Copyright (c) 2013-2013, burningbox.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++

require 'time'
require 'base64'
require 'bcrypt'
require 'rufus-json/automatic'
require 'net/http/persistent'


class MyCourtClient

  ENDPOINT = 'https://staging.mycourt.pro/api'

  attr_reader :user_email
  attr_reader :device_name
  attr_reader :key_id

  def initialize(user_email, device_name, opts={})

    @endpoint = opts[:endpoint] || ENDPOINT
    @user_email = user_email
    @device_name = device_name
    @key_id = opts[:key_id] || 0
    @secret = opts[:secret]

    @salt = nil
    @confirmation_link = nil

    @http = Net::HTTP::Persistent.new('MyCourt')
  end

  def authenticate

    @salt = BCrypt::Engine.generate_salt(14)

    body = {}
    body['userEmail'] = @user_email
    body['deviceName'] = @device_name
    body['salt'] = @salt

    r = request(:post, root.href('#auth'), body)

    @key_id = r['keyId']
    @confirmation_link = r.href('#auth_confirmation')
  end

  def confirm_authentication(code)

    @secret = BCrypt::Engine.hash_secret(code.gsub(/ /, ''), @salt)

    request(:post, @confirmation_link, {})
  end

  protected

  def request(meth, uri, body)

    #puts [ meth, uri ].join(' ')

    kla = Net::HTTP.const_get(meth.to_s.capitalize)

    uri = URI.parse(uri) unless uri.is_a?(URI)
    path = [ uri.path, uri.query ].compact.join('?')

    req = kla.new(path)

    req.body = body.is_a?(String) ? body : Rufus::Json.encode(body) if body

    sign(uri, req)

    Response.new(self, @http.request(uri, req))
  end

  def root

    request(:get, @endpoint, nil)
  end

  def sign(uri, request)

    return unless @secret

    request['x-mycourt-date'] = Time.now.utc.httpdate

    headers = []
    tosign = []

    tosign << request.class.name.split('::').last.upcase
    tosign << uri.to_s.match(/(\/api.*)$/)[1]

    request.each_header do |h|
      headers << h
      tosign << "#{h}:#{request[h]}"
    end

    tosign << "\n"
    tosign << request.body || ''

    headers = headers.join(";")
    tosign = tosign.join("\n")

    sig =
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest.new('SHA256'),
          @secret,
          OpenSSL::Digest::SHA256.digest(tosign))).strip

    request['x-mycourt-authorization'] =
      "MyCourt " +
      "KeyId=#{@key_id}," +
      "Algorithm=HMACSHA256," +
      "SignedHeaders=#{headers}," +
      "Signature=#{sig}"
  end

  class Response

    def initialize(client, res)

      @client = client
      @res = res
      @data = Rufus::Json.decode(@res.body)
    end

    def [](key)

      @data[key]
    end

    def link(rel)

      @data['_links'].each { |k, v| return v if k[-rel.length..-1] == rel }

      nil
    end

    def href(rel)

      (link(rel) || {})['href']
    end

    def get(rel, params=nil)

      uri = compute_uri(link(rel), params)

      @client.send(:request, :get, uri, nil)
    end

    def post(rel, params, data=nil)

      if data == nil
        data = params
        params = nil
      end

      l = link(rel)

      uri = compute_uri(l, params)

      (l['fields'] || []).each do |f|

        name = f['name']

        if f['required'] == true
          raise ArgumentError.new(
            "required field '#{name}' is missing"
          ) unless data.has_key?(name)
        elsif f.has_key?('default')
          data[name] = f['default'] unless data.has_key?(name)
        elsif f.has_key?('value')
          data[name] = f['value']
        end
      end

      @client.send(:request, :post, uri, data)
    end

    #def delete(rel, params=nil)
    #end

    protected

    def compute_uri(link, params)

      uri = link['href']

      return uri unless link['templated'] == true

      params.each { |k, v| uri.gsub!(/\{#{k}\}/, URI.encode(v.to_s)) }

      i = uri.index('{?')

      return uri unless i

      items = uri[i + 2..-2].split(',')
      uri = uri[0..i - 1]

      items =
        items.collect { |it|
          it = it.to_sym
          params.has_key?(it) ? "#{it}=#{URI.encode(params[it].to_s)}" : nil
        }.compact

      uri = uri + '?' + items.join('&') if items.length > 0

      uri
    end
  end
end

