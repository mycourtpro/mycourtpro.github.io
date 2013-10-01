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
      "href": "https://staging.mycourt.pro:60364/api/auth",
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

TODO...


<h2 id="signing">Request signing</h2>

I call thy name in madness with storm clouds
Tremulouser than condemned in the void
Swifter than damned in the void
I make haunted servitude to thee

(lore ipsum thanks to [https://gist.github.com/jart/3432955](https://gist.github.com/jart/3432955))

