
#
# Specifying mycourt_client.rb
#
# Wed Oct  9 12:50:56 JST 2013
#

require_relative '../mycourt_client'


class FakeResponse

  attr_reader :body

  def initialize(body)

    @body =
      body.is_a?(String) ? body : Rufus::Json.encode(body)
  end
end

def credentials

  Rufus::Json.decode(File.read('.credentials'))
end

#RSpec.configure do |config|
#end

