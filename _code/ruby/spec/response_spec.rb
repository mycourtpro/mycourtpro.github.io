
#
# specifiying mycourt_client.rb
#
# Wed Oct  9 12:54:50 JST 2013
#

require 'spec_helper'


class FakeHttpResponse

  attr_reader :body

  def initialize(body)

    @body =
      body.is_a?(String) ? body : Rufus::Json.encode(body)
  end
end

class FakeMyCourtClient

  attr_reader :last_request

  def request(method, uri, body)

    @last_request = { :method => method, :uri => uri, :body => body }

    nil
  end
end


describe MyCourtClient::Response do

  describe '#link' do

    before :all do

      @response =
        MyCourtClient::Response.new(
          nil,
          FakeHttpResponse.new(
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

  context 'http methods' do

    before :each do

      @client = FakeMyCourtClient.new

      @response =
        MyCourtClient::Response.new(
          @client,
          FakeHttpResponse.new(
            {
              '_links' => {
                'self' => {
                  'href' => 'https://staging.mycourt.pro/api'
                },
                'https://mycourt.pro/rels#my-clubs' => {
                  'href' => 'https://staging.mycourt.pro/api/clubs'
                },
                'https://mycourt.pro/rels#reservations' => {
                  'href' =>
                    'https://staging.mycourt.pro/api/reservations/{clubId}/{day}',
                  'templated' => true
                },
                'https://mycourt.pro/rels#members' => {
                  'href' =>
                    'https://staging.mycourt.pro/api/members/{clubId}{?query,count}',
                  'templated' => true
                },
                'https://mycourt.pro/rels#reserve' => {
                  'href' => 'https://staging.mycourt.pro/api/reservation',
                  'method' => 'POST',
                  'fields' => [
                    { 'name' => 'clubId', 'required' => true },
                    { 'name' => 'courtId', 'required' => true },
                    { 'name' => 'day', 'required' => true },
                    { 'name' => 'start', 'required' => true },
                    { 'name' => 'end', 'required' => true },
                    { 'name' => 'player1Id' },
                    { 'name' => 'player2Id' },
                    { 'name' => '_aft', 'value' => 'e7C2vM3...' }
                  ]
                },
                'https://mycourt.pro/rels#bookmark-add' => {
                  'href' => 'https://staging.mycourt.pro/api/bookmark/{clubId}',
                  'method' => 'POST'
                },
                'https://mycourt.pro/rels#bookmark-remove' => {
                  'href' =>
                    'https://staging.mycourt.pro/api/bookmark/{clubId}',
                  'method' => 'DELETE',
                  'templated' => true
                }
              },
              'version' => '1.0'
            }
          ))
    end

    describe '#get' do

      it 'gets self' do

        @response.get('self')

        @client.last_request[:method].should == :get
        @client.last_request[:uri].should == 'https://staging.mycourt.pro/api'
        @client.last_request[:body].should == nil
      end

      it 'gets #my-clubs' do

        @response.get('#my-clubs')

        @client.last_request[:uri].should ==
          'https://staging.mycourt.pro/api/clubs'
      end

      it 'gets https://mycourt.pro/rels#my-clubs' do

        @response.get('https://mycourt.pro/rels#my-clubs')

        @client.last_request[:uri].should ==
          'https://staging.mycourt.pro/api/clubs'
      end

      context '"templated": true' do

        it 'completes the path' do

          @response.get(
            'https://mycourt.pro/rels#reservations',
            :clubId => 19, :day => 20131019)

          @client.last_request[:uri].should ==
            'https://staging.mycourt.pro/api/reservations/19/20131019'
        end

        it 'completes the query string (1)' do

          @response.get(
            'https://mycourt.pro/rels#members',
            :clubId => 19)

          @client.last_request[:uri].should ==
            'https://staging.mycourt.pro/api/members/19'
        end

        it 'completes the query string (2)' do

          @response.get(
            'https://mycourt.pro/rels#members',
            :clubId => 19, :count => 21)

          @client.last_request[:uri].should ==
            'https://staging.mycourt.pro/api/members/19?count=21'
        end

        it 'completes the query string (3)' do

          @response.get(
            'https://mycourt.pro/rels#members',
            :clubId => 19, :query => 'toto', :count => 21)

          @client.last_request[:uri].should ==
            'https://staging.mycourt.pro/api/members/19?query=toto&count=21'
        end

        it 'escapes the query string values' do

          @response.get(
            'https://mycourt.pro/rels#members',
            :clubId => 7, :query => 'to to')

          @client.last_request[:uri].should ==
            'https://staging.mycourt.pro/api/members/7?query=to%20to'
        end
      end
    end

    describe '#post' do

      it 'posts reservations' do

        data = {}
        data['clubId'] = 19
        data['courtId'] = 7
        data['day'] = 20131212
        data['start'] = 1200
        data['end'] = 1300
        data['player1Id'] = 49
        data['player2Id'] = 50

        @response.post('#reserve', data)

        @client.last_request[:method].should ==
          :post
        @client.last_request[:uri].should ==
          'https://staging.mycourt.pro/api/reservation'
        @client.last_request[:body].should ==
          data
      end

      it 'accepts links without forms'
      it 'raises on missing "required": true fields'
      it 'completes fields with "value"'
    end

    describe '#delete' do

      it 'works'
    end
  end
end

