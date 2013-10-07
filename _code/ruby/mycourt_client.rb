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
require 'bcrypt'
require 'rufus-json/automatic'
require 'net/http/persistent'


class MyCourtClient

  ENDPOINT = 'https://staging.mycourt.pro/api'

  attr_reader :user_email
  attr_reader :device_name

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

    h = {}
    h['userEmail'] = @user_email
    h['deviceName'] = @device_name
    h['salt'] = @salt

    r = post(root.link('#auth'), h, '')

    @key_id = r['keyId']
    @confirmation_link = r.link('#auth_confirmation')
  end

  protected

  def request(meth, uri, headers, body)

    p uri

    uri = URI.parse(uri) unless uri.is_a?(URI)
    path = [ uri.path, uri.query ].compact.join('?')

    req = meth.new(path, headers)
    req.body = body if body

    Response.new(@http.request(uri, req))
  end

  def get(uri, headers={})

    request(Net::HTTP::Get, uri, headers, nil)
  end

  def post(uri, headers, body)

    request(Net::HTTP::Post, uri, headers, body)
  end

  def root

    get(@endpoint)
  end

  class Response

    def initialize(res)

      @res = res
      @data = Rufus::Json.decode(@res.body)
      pp @data
    end

    def [](key)

      @data[key]
    end

    def link(fragment)

      k, v = @data['_links'].find { |k, v|
        k[-fragment.length..-1] == fragment
      }

      k ? v['href'] : nil
    end
  end
end

