
require 'pp'
require_relative 'mycourt_client'

#c = MyCourtClient.new('toto@example.com', 'smahon')
#c.authenticate
#
##puts c.key_id
#
#print 'please enter the authentication code: '
#code = gets.strip
#
#c.confirm_authentication(code)

eml, dev, kid, sec = File.read('.secret').split(' ').collect(&:strip)

c = MyCourtClient.new(eml, dev, :key_id => kid, :secret => sec)

c.send(:post, "https://staging.mycourt.pro/api/auth/" + kid, {}, {})

