---
layout: api
title: API authentication
---

# MyCourt API auth

Each request to the MyCourt API must be signed.

The signature is the result of a function that takes as input the request itself (method, target, headers and body) and the secret key.

The secret key is shared between the client application that uses the API and the MyCourt system.

The first step is to [obtain a secret key](#secret). Once this is done, keep that secret secret and [sign each request](#signing) with it.


<h2 id="secret">Obtaining a secret key</h2>

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
    "https://mycourt.pro/rels#auth": {
      "href": "https://staging.mycourt.pro/api/auth",
      "method": "POST",
      "fields": [
        { "name": "userEmail", "required": true },
        { "name": "deviceName", "required": true },
        { "name": "salt", "required": true },
        { "name": "_aft", "value":"5bZvx..." }
      ]
    }
  }
}
{% endhighlight %}

This isn't a [200](flow.html#code200), but a 401 "unauthorized". MyCourt will point you at where to get authenticated.

As explained in [flow](flow.html), you're supposed to follow the ```#auth``` link. Here it's easy, it's the only link the MyCourt API communicated to you.

<h3 id="announce">Announce yourself</h3>

The auth link looks like:

{% highlight javascript %}
  "https://mycourt.pro/rels#auth": {
    "href": "https://staging.mycourt.pro/api/auth",
    "method": "POST",
    "fields": [
      { "name": "userEmail", "required": true },
      { "name": "deviceName", "required": true },
      { "name": "salt", "required": true },
      { "name": "_aft", "value":"5bZvx..." } ] }
{% endhighlight %}

You're expected to post a JSON document with 4 fields, "userEmail", "deviceName", "salt" and "_aft".

* userEmail: this is the email you use to identify yourseful on the MyCourt website
* deviceName: the name of this device, a short string like "iPhone" or "WinPhone8" is best
* salt: a [bcrypt](http://en.wikipedia.org/wiki/Bcrypt) generated salt, it's a String of the form "$2a$14$olE7PUzfsq.iSd.5qNLlDu"
* aft: this is an antiforgery token, you're simply expected to pass it back with your request

So, to announce yourself, you have to post to ```https://staging.mycourt.pro/api/auth``` a JSON document that looks like:

{% highlight javascript %}
{
  "userEmail": "toto@example.com",
  "deviceName": "winPhone8",
  "salt": "$2a$14$olE7PUzfsq.iSd.5qNLlDu"
  "_aft": "5bZvx..."
}
{% endhighlight %}

This will prompt the MyCourt system to send you, via email, a code.

The answer to the post will be something like:

{% highlight javascript %}
{
  "keyId": 1180,
  "_links": {
    "https://mycourt.pro/rels#auth_confirmation": {
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

<h3 id="confirm">Confirm the key</h3>

As just said, once you have requested a secret key over HTTPS and receveid by email, you have to confirm it via the ```#auth_confirmation``` link.

This confirmation is only a matter of sending an empty JSON document (yes, ```{}``` is sufficient) via a POST to the ```#auth_confirmation``` link. But, this request has to be signed (with the secret key).

Keep that secret key safely in your device/client. The platform you're developing for probably has a way to store such credentials in a secure way.


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

