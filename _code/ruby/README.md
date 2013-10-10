
# MyCourt sample Ruby client

blah blah blah.

Based on [half.rb](https://github.com/jmettraux/half.rb)


## obtaining an API key

```ruby
require 'mycourt_client'

c = MyCourtClient.new('toto@example.com', 'smahon')
c.authenticate

# the code comes via email, let's feed it to our client and confirm
#
print 'please enter the authentication code: '
code = gets.strip

c.confirm_authentication(code)
```

## regular operation

blah blah blah.


## license

MIT

