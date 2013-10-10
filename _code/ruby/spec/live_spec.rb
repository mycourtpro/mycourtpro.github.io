
#
# specifiying mycourt_client.rb
#
# Thu Oct 10 09:59:02 JST 2013
#

require 'spec_helper'


describe MyCourtClient do

  before :each do

    @client = MyCourtClient.new(
      credentials[:user_email], credentials[:device_name],
      :key_id => credentials[:key_id], :secret => credentials[:secret])
  end

  context 'live' do

    describe '#xxx' do

      it 'works'
    end
  end
end

