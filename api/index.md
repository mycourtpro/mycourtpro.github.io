---
layout: api
title: API
---

# MyCourt API

The MyCourt API lets you interact with MyCourt over HTTPS.

It's meant for mobile clients and other devices.

It builds on HTTP(s), JSON. There is this H in HTTP, it stands for Hypermedia and we've been trying to put it into use.

Interacting with MyCourt is mostly done by GETting JSON documents and POSTing JSON documents.

Each HTTP request to MyCourt must be signed, thanks to a secret key shared between you and MyCourt.

*Nota Bene*: you need a MyCourt account in order to use the MyCourt API. It's in our plans to provide signup via the API but it's not yet implemented.


<h2 id="signing">Sign requests?</h2>

The signature process is very similar to the one used by Amazon. You and MyCourt share a secret key and you use it to sign _every request_ you make to MyCourt. Unsigned requests or requests with an invalid signature will be rejected.

MyCourt expects you to add two headers to your HTTP requests: "x-mycourt-date" and "x-mycourt-authorization"

The "x-mycourt-date" is simply the current date in the RFC1123 format, "Mon, 05 Aug 2013 08:49:35 GMT", for example. In Ruby, for example, you'd do ```Time.now.httpdate```.

The "x-mycourt-authorization" is computed by a simple function that combines the request details and the secret key you share with the MyCourt system.

For more details about request signing, read [authentication](auth.html).


<h2 id="hypermedia">Hypermedia</h2>

The usual API lists HTTP endpoints and templates for each action. When those endpoints change, you have to change the client.

MyCourt API reserves the right to change those endpoints and although you'll use them, you're expected to find them via links and their "rel" labels.

Likewise, when browsing MyCourt, you click the "my reservations" button to list your reservations, you don't type: "https://mycourt.pro/users/123/reservations" in the address bar.

For more details about this, read [flow](flow.html).

