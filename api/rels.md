---
layout: api
title: API rels
---

# rels

Rule: noun is a GET request, verb is a POST, PUT or DELETE request.

URLs do not matter and they might change.


<h2 id="my-clubs">GET #my-clubs</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#my-clubs": {
  "href": "https://staging.mycourt.pro/api/clubs"
}
{% endhighlight %}

Lists the clubs the user owns, is member of or has bookmarked.

See also [#bookmark-add](#bookmark-add) and [#bookmark-remove](#bookmark-remove).


<h2 id="my-reservations">GET #my-reservations</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#my-reservations": {
  "href": "https://staging.mycourt.pro/api/reservations"
}
{% endhighlight %}

Lists all the upcoming reservations for the user.

See also [#reservations](#reservations) and [#reserve](#reserve).


<h2 id="reservations">GET #reservations</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#reservations": {
  "href": "https://staging.mycourt.pro/api/reservations/{clubId}/{day}",
  "templated": true
}
{% endhighlight %}

Lists all the reservations for a given club on a given day.

See also [#my-reservations](#my-reservations) and [#reserve](#reserve).


<h2 id="members">GET #members</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#members": {
  "href": "https://staging.mycourt.pro/api/members/{clubId}{?query,count}",
  "templated": true
}
{% endhighlight %}

Lists the members of a club. Takes optional ```query``` and ```count```.

Count limits the number of users in the answer.

Query is used to narrow to users whose names (first or last) start with the given query. Mostly used for typeahead input.

See also [#clubs](#clubs) and [#reserve](#reserve).


<h2 id="reserve">POST #reserve</h2>

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

Posts a reservation.

See also [#reservations](#reservations) and [#my-reservations](#my-reservations).


<h2 id="subscribe">POST #subscribe</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#subscribe": {
  "href": "https://staging.mycourt.pro/api/subscription",
  "method": "POST",
  "fields": [
    { "name": "clubId", "required": true },
    { "name": "subscriptionId", "required": true },
    { "name": "userId" }
  ]
}
{% endhighlight %}

Purchases a subscription.

The ```userId``` defaults to the current user's id.

The owner of a club may use this method (thanks to ```userId```) to attribute a subscription to a user.

See also [#clubs](#clubs).


<h2 id="bookmark-add">POST #bookmark-add</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#bookmark-add": {
  "href": "https://staging.mycourt.pro/api/bookmark",
  "method": "POST",
  "fields": [
    { "name": "clubId", "required": true }
  ]
}
{% endhighlight %}

Bookmarks a club.

See also [#clubs](#clubs) and [#bookmark-remove](#bookmark-remove).


<h2 id="bookmark-remove">DELETE #bookmark-remove</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#bookmark-remove": {
  "href": "https://staging.mycourt.pro/api/bookmark/{clubId}",
  "method": "DELETE",
  "templated": true
}
{% endhighlight %}

Removes a club bookmark.

See also [#clubs](#clubs) and [#bookmark-add](#bookmark-add).


<h2 id="slot-prices">GET #slot-prices</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#slot-prices": {
  "href": "https://staging.mycourt.pro/api/clubs/{clubId}/prices/{day}",
  "templated": true
}
{% endhighlight %}

Lists all the slot prices for a club on a given day (court group by court group).

See also [#clubs](#clubs) and [#reservations](#reservations).


<h2 id="payment-add">POST #payment-add</h2>

{% highlight javascript %}
"https://mycourt.pro/rels#payment-add": {
  "href": "https://staging.mycourt.pro/api/payment",
  "method": "POST",
  "fields": [
    { "name": "clubId", "required": true },
    { "name": "token", "required": true },
    { "name": "nick", "required": true }
  ]
}
{% endhighlight %}

Adds a payment token for the current user in the given club. ```nick``` is a string like "my visa card" or "amex gold spare".

The ```token``` is a [Paymill](http://paymill.com) token (obtained via the Paymill bridge).

See also [#clubs](#clubs) and [#subscribe](#subscribe).
