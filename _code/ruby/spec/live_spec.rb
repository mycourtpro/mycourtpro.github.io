
#
# specifiying mycourt_client.rb
#
# Thu Oct 10 09:59:02 JST 2013
#

require 'spec_helper'


describe MyCourtClient do

  context 'live' do

    before :each do

      @client = MyCourtClient.new(
        credentials[:user_email], credentials[:device_name],
        :key_id => credentials[:key_id], :secret => credentials[:secret])
    end

    describe MyCourtClient::Response do

      before :each do

        @root = @client.root
      end

      describe '#my_clubs' do

        it 'lists my clubs' do

          r = @root.my_clubs

          r.class.should == MyCourtClient::Response
          r.data.keys.sort.should == %w[ _embedded _links version ]
          r.data['_embedded'].should have_key('clubs')
          r.embedded.should have_key('clubs')
          r.embedded['clubs'].first.should have_key('currency')
        end
      end
    end
  end
end

