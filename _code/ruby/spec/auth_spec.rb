
#
# specifiying mycourt_client.rb
#
# Wed Oct  9 12:54:50 JST 2013
#

require 'spec_helper'


describe MyCourtClient do

  context 'auth' do

    describe '#authenticate' do

      it 'requests a new key' do

        client = MyCourtClient.new(
          credentials[:user_email], credentials[:device_name])

        client.authenticate

        client.key_id.should_not ==
          nil
        client.instance_variable_get(:@confirmation_link).should ==
          "https://staging.mycourt.pro/api/auth/#{client.key_id}"
      end

      it 'fucks up' do

        client = MyCourtClient.new(nil, nil)

        client.authenticate

        true.should == false

        # returns a 400, right, but includes links as if the client
        # were authenticated...
        #
        # TODO: fix that
      end
    end

    describe '#confirm_authentication' do

      it 'works'
    end
  end
end

