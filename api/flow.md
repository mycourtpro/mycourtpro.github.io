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
    "http://mycourtpro.github.io/api/rels.html#my-clubs": {
      "href": "https://mycourt.com/api/clubs"
    },
    "http://mycourtpro.github.io/api/rels.html#my-reservations": {
      "href": "https://mycourt.com/api/reservations"
    },
    "http://mycourtpro.github.io/api/rels.html#reservations": {
      "href": "http://localhost:60364/api/reservations/{clubId}/{day}",
      "templated": true
    },
    "http://mycourtpro.github.io/api/rels.html#reserve": {
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
    "http://mycourtpro.github.io/api/rels.html#my-clubs": {
      "href": "https://mycourt.com/api/clubs"
    }
{% endhighlight %}

A straightforward link that translates as ```GET https://mycourt.com/api/clubs```

* templated GET

{% highlight javascript %}
    "http://mycourtpro.github.io/api/rels.html#reservations": {
      "href": "http://localhost:60364/api/reservations/{clubId}/{day}",
      "templated": true
    }
{% endhighlight %}

Another GET link but this time the "href" is templated (hence ```"templated": true```).

* POST with form

{% highlight javascript %}
    "http://mycourtpro.github.io/api/rels.html#reserve": {
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

The MyCourt API, being based on HTTP, relies on clients understanding [HTTP status codes](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html).

Here is a refresher on the codes the MyCourt API may return:

* [200 OK](#200-ok)
* [204 No Content](#204-no-content)
* [304 Not Modified](#304-not-modified)
* [400 Bad Request](#400-bad-request)
* [401 Unauthorized](#401-unauthorized)
* [402 Payment Required](#402-payment-required)
* [403 Forbidden](#403-forbidden)
* [404 Not Found](#404-not-found)
* [500 Internal Server Error](#500-internal-server-error)


<h3 id="200-ok">200 OK</h3>

"The request has succeeded."

The information/response is the JSON object in the payload.

<h3 id="204-no-content">204 No Content</h3>

"The server has fulfilled the request but does not need to return an entity-body"

A simple "OK", no further answer / payload required.

<h3 id="304-not-modified">304 Not Modified</h3>

"If the client has performed a conditional GET request and access is allowed, but the document has not been modified, the server SHOULD respond with this status code. The 304 response MUST NOT contain a message-body, and thus is always terminated by the first empty line after the header fields."

<h3 id="400-bad-request">400 Bad Request</h3>

"The request could not be understood by the server due to malformed syntax. The client SHOULD NOT repeat the request without modifications."

Missing form fields and/or query string parameters. Carefully look at how the request is built and what the server expects.

<h3 id="401-unauthorized">401 Unauthorized</h3>

"The request requires user authentication."

The MyCourt API returns 401 when the user is not authenticated. A link to the authentication endpoint is included in the JSON payload.

<h3 id="402-payment-required">402 Payment Required</h3>

"This code is reserved for future use."

This is what the MyCourt API answers when the user attempts to reserve a paying slot or buy a club subscription but his credit card information is missing or invalid.

<h3 id="403 Forbidden">403 Forbidden</h3>

"The server understood the request, but is refusing to fulfill it. Authorization will not help and the request SHOULD NOT be repeated."

The user hasn't enough rights for his request to be completed.

<h3 id="404-not-found">404 Not Found</h3>

"The server has not found anything matching the Request-URI. No indication is given of whether the condition is temporary or permanent."

Shouldn't happen often as the user (agent) mostly follows links, unless the link is "templated" and the query string parameters are wrong (unknown clubId, etc).

<h3 id="500-internal-server-error">500 Internal Server Error</h3>

"The server encountered an unexpected condition which prevented it from fulfilling the request."

This response indicates an issue on the MyCourt server side. The admins are notified and hopefully the issue is resolved sooner or later.

Don't hesitate to contact us via the [developer issue tracker](https://github.com/mycourtpro/mycourtpro.github.io/issues) if such an issue is a blocker for you (especially when developing a client application).

