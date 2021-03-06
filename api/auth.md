---
layout: api
title: API authentication
---

# MyCourt API auth

Each request to the MyCourt API must be signed.

The signature is the result of a function that takes as input the request itself (method, target, headers and body) and the secret key.

The secret key is shared between the client application that uses the API and the MyCourt system.

The first step is to obtain a secret key. Once this is done, keep that secret secret and [sign each request](#signing) with it.

A secret key is coupled to a MyCourt account, that means there are two cases: [the account already exists](#authenticate) or an account doesn't exist and has to be [created and registered](#register).

<h2 id="authenticate">existing MyCourt account</h2>

The customer already has a MyCourt account (else jump to [registering](#register)).

There are 4 steps to obtain a key. Those steps are a dialog between the client and the MyCourt system. Here is a graphical depiction:

<img class="shadowed" src="/images/auth_steps.png" />

Maybe, the fifth step would be "keep the key, and keep it secret".

<h3 id="knock">Knocking at the door</h3>

You want to get in? Knock at the door first. The unique API endpoint is ```https://staging.mycourt.pro/api```, so let's knock that door:

{% highlight javascript %}
curl https://staging.mycourt.pro/api
{% endhighlight %}

You'll get a JSON document looking like:

{% highlight javascript %}
{
  "code": 401,
  "message": "unauthorized",
  "_links": {
    "http://mycourtpro.github.io/api/rels.html#auth": {
      "href": "https://staging.mycourt.pro/api/auth",
      "method": "POST",
      "fields": [
        { "name": "userEmail", "required": true },
        { "name": "deviceName", "required": true },
        { "name": "salt", "required": true }
      ]
    },
    "http://mycourtpro.github.io/api/rels.html#register": {
      // ...
    }
  }
}
{% endhighlight %}

This isn't a [200](flow.html#code200), but a 401 "unauthorized". MyCourt will point you at where to get authenticated.

As explained in [flow](flow.html), you're supposed to follow the ```#auth``` link. Here it's easy, it's the only link the MyCourt API communicated to you.

(The ```#register``` link is for when the user doesn't have an account and one has [to be created](#register))

<h3 id="auth-announce">Announcing the user</h3>

The auth link looks like:

{% highlight javascript %}
  "http://mycourtpro.github.io/api/rels.html#auth": {
    "href": "https://staging.mycourt.pro/api/auth",
    "method": "POST",
    "fields": [
      { "name": "userEmail", "required": true },
      { "name": "deviceName", "required": true },
      { "name": "salt", "required": true } ] }
{% endhighlight %}

You're expected to post a JSON document with 3 fields, "userEmail", "deviceName" and "salt".

* userEmail: this is the email you use to identify yourseful on the MyCourt website
* deviceName: the name of this device, a short string like "iPhone" or "WinPhone8" is best
* salt: a [bcrypt](http://en.wikipedia.org/wiki/Bcrypt) generated salt, it's a String of the form "$2a$14$olE7PUzfsq.iSd.5qNLlDu"

So, to announce yourself, you have to post to ```https://staging.mycourt.pro/api/auth``` a JSON document that looks like:

{% highlight javascript %}
{
  "userEmail": "toto@example.com",
  "deviceName": "winPhone8",
  "salt": "$2a$14$olE7PUzfsq.iSd.5qNLlDu"
}
{% endhighlight %}

This will prompt the MyCourt system to send you, via email, a code.

The answer to the post will be something like:

{% highlight javascript %}
{
  "keyId": 1180,
  "_links": {
    "http://mycourtpro.github.io/api/rels.html#auth_confirmation": {
      "href": "https://staging.mycourt.pro/api/auth/1180",
      "method": "POST"
    }
  }
}
{% endhighlight %}

Prompting you to POST an empty JSON document to ```https://staging.mycourt.pro/api/auth/{keyId}``` as a confirmation.

The code received by email is a string like "AF4G RT23 7RS4 123Q". It's meant to be entered easily in a mobile device.

<h3 id="compute">Compute the key</h3>

The code received by email is used to compute the secret key that is shared between you (client/device) and the MyCourt system.

In Visual Basic, that would look like:

{% highlight vb.net %}
dim secret = Bcrypt.HashPassword(code.Replace(" ", ""), salt)
{% endhighlight %}

and in Ruby:
{% highlight ruby %}
secret = BCrypt::Engine.hash_secret(code.gsub(/ /, ''), salt)
{% endhighlight %}

<h3 id="confirm">Confirm the key</h3>

As just said, once you have requested a secret key over HTTPS and receveid by email, you have to confirm it via the ```#auth_confirmation``` link.

This confirmation is only a matter of sending an empty JSON document (yes, ```{}``` is sufficient) via a POST to the ```#auth_confirmation``` link. But, this request has to be signed (with the secret key).

Keep that secret key safely in your device/client. The platform you're developing for probably has a way to store such credentials in a secure way.


<h2 id="register">register new MyCourt account</h2>

(If the user already holds a MyCourt account, follow the instructions in [authenticating](#authenticate))

Like when [authenticating](#authenticate) an existing MyCourt account, there are 4 steps to obtain a key. Those are the same steps, except for the 2nd one (announcing). Instead of following the ```#auth``` link, the ```#register``` link has to be followed.

<img class="shadowed" src="/images/register_steps.png" />

<h3 id="register-announce">Announcing the new user</h3>

When "announcing" an already existing MyCourt account, the client only has to pass the "userEmail", "deviceName" and a computed "salt". When announcing a new MyCourt account, the client has to pass those three pieces of information plus some more, here is what the ```#register``` link looks like:

{% highlight javascript %}
  "http://mycourtpro.github.io/api/rels.html#register": {
    "href": "https://staging.mycourt.pro/api/register",
    "method": "POST",
    "fields": [

      { "name": "userEmail", "required": true },
      { "name": "deviceName", "required": true },
      { "name": "salt", "required": true },

      { "name": "firstName", "required": true },
      { "name": "lastName", "required": true },
      { "name": "birthDate", "required": true },
      { "name": "gender", "required": true },
      { "name": "dateFormat", "default": "dd.MM.yyyy" },
      { "name": "lang", "default": "en" },

      { "name": "password", "comment": "website password" }
    ]
  }
{% endhighlight %}

Post the requested information to ```#register```, the rest goes like when [the MyCourt account already exists](#authenticate).

Please note that the ```password``` field is optional. If it's not set, the new account will first need a password reset request in order to be used on the "traditional" MyCourt web application.


<h2 id="signing">Request signing</h2>

Once you have a secret key (and its keyId), you can start signing requests. In face, as just seen, you have to confirm your key by signing a very first request (to ```#auth_confirmation```).

A signed request is expected to sport two MyCourt specific headers: "x-mycourt-date" and "x-mycourt-signature".

**x-mycourt-date** is the current (client) date expressed in the RFC1123 format, "Mon, 05 Aug 2013 08:49:35 GMT", for example. In Ruby, for example, you'd do ```Time.now.httpdate```.

**x-mycourt-signature** is a string that looks like: "MyCourt KeyId=6012627,Algorithm=HMACSHA256,SignedHeaders=x-mycourt-date,Signature=ItkVqGfmD4R6Hyy1s+XfXugwSBArJx6O6wUSZz25jk9="

Request signing is simply about inserting those two headers. The first one, "x-mycourt-date" is easy, the second one requires more work.

<h3 id="what">What to sign</h3>

The signature is computed from a string composed of lines (separated by linefeeds (not carriage returns, not linefeeds + carriage returns).

The first line is the **method** (in uppercase) of the request, usually "GET" or "POST".

The second line is the **path** of the URI targetted, starting from the "/api" part included. The next lines are the included **headers** and their values, generally it's only "x-mycourt-date". The format is "{header}:{value}" (a colon as separator, no spaces around the colon).

Then a *blank line*.

Then the *body* of the request.

So something like:

{% highlight js %}
GET
/api/auth/1180
x-mycourt-date:Mon, 05 Aug 2013 08:49:35 GMT

{"hello":"world"}
{% endhighlight %}

Here is how the signing looks in Ruby:

{% highlight ruby %}
require 'base64'

# ...

  # Where request is of class Net::HTTP::{Get|Post|Put|Delete}
  #
  def sign(request)

    return unless @secret

    request['x-mycourt-date'] = Time.now.utc.httpdate

    headers = []
    tosign = []

    tosign << request.class.name.split('::').last.upcase
    tosign << request.path.to_s.match(/(\/api.*)$/)[1]

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
{% endhighlight %}

([complete Ruby example client source](https://github.com/mycourtpro/mycourtpro.github.io/tree/master/_code/ruby/mycourt_client.rb))

<h3 id="signing_sample">signing sample data</h3>

(can be used when unit testing your client signature mechanism)

GET sample signature:

{% highlight python %}
# data:
"""
GET
/api/clubs/106462/prices/20140815
x-mycourt-date:Tue, 12 Aug 2014 11:03:39 GMT
x-nada:just_for_showing_a_second_header


"""

# secret:
"""
$2a$14$th.AkDhi6OIRk1NBoiaQhuScgMvwehHsVVYb3pKy2B/PvaAFChYTO
"""

# signature:
"""
P2iTnabfMn3LLF74DAkqycFK4tgLSLiUbKneyJZZll4=
"""

# headers:
"""
x-mycourt-date: Tue, 12 Aug 2014 11:03:39 GMT
x-nada: just_for_showing_a_second_header
x-mycourt-authorization: MyCourt KeyId=9181,Algorithm=HMACSHA256,SignedHeaders=x-mycourt-date;x-nada,Signature=P2iTnabfMn3LLF74DAkqycFK4tgLSLiUbKneyJZZll4=
"""
{% endhighlight %}

POST sample signature:

{% highlight python %}
# data:
"""
POST
/api/bookmark
x-mycourt-date:Tue, 12 Aug 2014 13:28:49 GMT
x-nada:just_for_showing_a_second_header


{"clubId":106463}
"""

# secret:
"""
$2a$14$JD0LM2UxcwKP69IyqOJBq.aZrafUtDQoP5X81w5i9jiDRmMMHk/hm
"""

# signature:
"""
KKXZgCzBtxLpLgOIN4KEkN+W3bjWkfgxWz8PGqIsQRY=
"""

# headers:
"""
x-mycourt-date: Tue, 12 Aug 2014 13:28:49 GMT
x-nada: just_for_showing_a_second_header
x-mycourt-authorization: MyCourt KeyId=9182,Algorithm=HMACSHA256,SignedHeaders=x-mycourt-date;x-nada,Signature=KKXZgCzBtxLpLgOIN4KEkN+W3bjWkfgxWz8PGqIsQRY=
"""
{% endhighlight %}


<h2 id="conclusion">Conclusion</h2>

You've seen how to request a secret key and then how to use it to confirm it.

You have one day to confirm a key else it gets discard after one day (you can simply request a new one).

Now that you've signed successfully your confirmation, you can sign [all the requests you need](flow.html).

