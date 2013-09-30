---
layout: api
title: API
---

# MyCourt API

The MyCourt API lets you interact with MyCourt over HTTPS.

It's meant for mobile clients and other devices.

It builds on HTTP(s), JSON. There is this H in HTTP, it stands for Hypermedia and we've been trying to put it into use.

Interacting with MyCourt is mostly done by GETting JSON documents and POSTing JSON documents.

Each HTTP request is signed. The signature process is very similar to the one used by Amazon. You and MyCourt share a secret key and you use it to sign every request you make to MyCourt. Unsigned requests or requests with an invalid signature will be rejected.

Learn more about the [API and authorization](authorization.html).


## JSON over HTTP

The easiest way to think about the MyCourt API is as a "website for computers" or a "website not meant for humans".

When you look at the MyCourt website (and you're logged in):

<img class="screenshot" src="/images/mycourt_home.png" />

You see information and links.

The equivalent for a computer browsing the MyCourt API is:

{% highlight javascript linenos %}
{
  "_links": {
    "self": {
      "href": "http://localhost:60364/api"
    },
    "https://mycourt.pro/rels#my-clubs": {
      "href": "http://localhost:60364/api/clubs"
    },
    "https://mycourt.pro/rels#my-reservations": {
      "href": "http://localhost:60364/api/reservations"
    },
    "https://mycourt.pro/rels#reserve": {
      "href": "http://localhost:60364/api/reservation",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true },
        { "name": "courtId", "required": true },
        { "name": "day", "required": true },
        { "name": "start", "required": true },
        { "name": "end", "required": true },
        { "name": "player1Id" },
        { "name": "player2Id" },
        { "name": "_aft", "value": "1BSBnmw2f1Bpt4tAW86TZmoU9Gv6XyF0" }
      ]
    }
  },
  "version": "1.0"
}
{% endhighlight %}


## HALf

The MyCourt API builds on [HALf](https://github.com/jmettraux/half) which is an extension to [HAL](http://stateless.co/hal_specification.html).



