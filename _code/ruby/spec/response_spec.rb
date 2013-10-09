
#
# specifiying mycourt_client.rb
#
# Wed Oct  9 12:54:50 JST 2013
#

require 'spec_helper'


describe MyCourtClient::Response do

  describe '#link' do

    before :all do

      @response =
        MyCourtClient::Response.new(
          nil,
          FakeResponse.new(
            '_links' => {
              'https://mycourt.pro/rels#auth_confirmation' => {
                'href' => 'https://staging.mycourt.pro/api/auth/1180',
                'method' => 'POST'
              }
            }))
    end

    it 'returns the first matching link' do

      @response.link('#auth_confirmation').should ==
        { 'href' => 'https://staging.mycourt.pro/api/auth/1180',
          'method' => 'POST' }
    end
  end
end

