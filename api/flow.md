---
layout: api
title: API flow
---

<h1 id="flow">MyCourt API flow</h1>

The MyCourt API is based on HTTP(s) and JSON. It replies to HTTP requests with JSON documents. When POSTing and PUTting to it, the expected payload is JSON.

The H in HTTP stands for "Hypermedia". The MyCourt API attempts to make good use of this and thus follows the patterns that made the "web" ubiquitous.

When looking at a web page from a "human" point of view, hypermedia emerges as "links":

<img class="shadowed" src="/images/mycourt_home.png" style="width: 100%" />

For the MyCourt API, the links are grouped under a "_links" key in the JSON document handed back:

{% highlight javascript %}
{
  "_links": {
    "https://mycourt.pro/rels#my-clubs": {
      "href": "https://mycourt.com/api/clubs"
    },
    "https://mycourt.pro/rels#my-reservations": {
      "href": "https://mycourt.com/api/reservations"
    },
    "https://mycourt.pro/rels#reservations": {
      "href": "http://localhost:60364/api/reservations/{clubId}/{day}",
      "templated": true
    },
    "https://mycourt.pro/rels#reserve": {
      "href": "https://mycourt.com/api/reservation",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true },
        { "name": "courtId", "required": true },
        { "name": "day", "required": true },
        { "name": "start", "required": true },
        { "name": "end", "required": true },
        { "name": "player1Id" },
        { "name": "player2Id" }
      ]
    }
  },
  "version": "1.0"
}
{% endhighlight %}

A client to the MyCourt API is expected to follow the links as it deems appropriate.

Such a client is not expected to "infer" URIs from an endpoint. It does a GET request on a single endpoint and the answer contains links to appropriate action/resources.


<h2 id="half">HALf</h2>

The MyCourt API is based on [HALf](https://github.com/jmettraux/half), which is itself based on [HAL](http://stateless.co/hal_specification.html).

The JSON documents returned by the MyCourt API sport a "_links" section detailing all the available links, from GETs to POSTs.


<h2 id="follow">follow</h2>

Let's take a closer look at the some of the links shown above:

* straight GET

{% highlight javascript %}
    "https://staging.mycourt.pro/rels#my-clubs": {
      "href": "https://mycourt.com/api/clubs"
    }
{% endhighlight %}

A straightforward link that translates as ```GET https://mycourt.com/api/clubs```

* templated GET

{% highlight javascript %}
    "https://staging.mycourt.pro/rels#reservations": {
      "href": "http://localhost:60364/api/reservations/{clubId}/{day}",
      "templated": true
    }
{% endhighlight %}

Another GET link but this time the "href" is templated (hence ```"templated": true```).

* POST with form

{% highlight javascript %}
    "https://mycourt.pro/rels#reserve": {
      "href": "https://staging.mycourt.pro/api/reservation",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true },
        { "name": "courtId", "required": true },
        { "name": "day", "required": true },
        { "name": "start", "required": true },
        { "name": "end", "required": true },
        { "name": "player1Id" },
        { "name": "player2Id" }
      ]
    }
{% endhighlight %}

When the "method" is not specified it defaults to "GET", as seen above. Here "POST" is set. There is also a list of "fields". Those fields are optional unless "required".

Here's what could get POSTed to the MyCourt API:
{% highlight javascript %}
// POST to https://staging.mycourt.pro/api/reservation
{
  "clubId": 1934,
  "courtId": 3003,
  "day": 20131212,
  "start": 1200,
  "end": 1300,
  "player1Id": 1245,
  "player2Id": 1247
}
{% endhighlight %}

For a description of all the links see [link rels](rels.html).


<h2 id="status">status codes</h2>

blah blah blah.

