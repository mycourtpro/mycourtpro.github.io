---
layout: api
title: API
---

# MyCourt API flow

lore ipsum

blah blah blah.

It builds on HTTP(s), JSON. There is this H in HTTP, it stands for Hypermedia and we've been trying to put it into use.

Interacting with MyCourt is mostly done by GETting JSON documents and POSTing JSON documents.

Each HTTP request to MyCourt must be signed, thanks to a secret key shared between you and MyCourt.


<h2 id="rels">rels (link labels)</h2>

blah blah blah.

The signature process is very similar to the one used by Amazon. You and MyCourt share a secret key and you use it to sign every request you make to MyCourt. Unsigned requests or requests with an invalid signature will be rejected.

MyCourt expects you to add two headers to your HTTP requests: "x-mycourt-date" and "x-mycourt-authorization"

The "x-mycourt-date" is simply the current date in the RFC1123 format, "Mon, 05 Aug 2013 08:49:35 GMT", for example. In Ruby, for example, you'd do ```Time.now.httpdate```.

The "x-mycourt-authorization" is computed by a simple function that combines the request details and the secret key you share with the MyCourt system.

