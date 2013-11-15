---
layout: api
title: API rels
---

# rels

Rule: noun is a GET request, verb is a POST, PUT or DELETE request.

URLs do not matter and they might change.

Here is a list of the rels supported by the MyCourt API. Click to jump to details.

* [#my-clubs](#my-clubs)
* [#clubs](#clubs)
* [#my-reservations](#my-reservations)
* [#members](#members)
* [#reserve](#reserve) (POST)
* [#subscribe](#subscribe) (POST)
* [#bookmark-add](#bookmark-add) (POST)
* [#bookmark-remove](#bookmark-remove) (DELETE)
* [#slots](#slots)
* [#payment-add](#payment-add) (POST)
* [#membership-request](#membership-request) (POST)
* [#translations](#translations)

<!---
* [#auth](#auth)
* [#auth_confirmation](#auth_confirmation)
-->

---

<h2 id="my-clubs">GET #my-clubs</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#my-clubs": {
  "href": "https://staging.mycourt.pro/api/clubs"
}
{% endhighlight %}

Lists the clubs the user owns, is member of or has bookmarked.

See also [#bookmark-add](#bookmark-add) and [#bookmark-remove](#bookmark-remove).

---

<h2 id="clubs">GET #clubs</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#clubs": {
  "href": "https://staging.mycourt.pro/api/clubs{?query,country,count}",
  "templated": true
}
{% endhighlight %}

Lists clubs registered in MyCourt. Next step would be to bookmark it or to request its membership.

The ```query``` is a string. Clubs whose information (name, street, city, ...) begins with that string (case ignored) are returned.

The ```country``` query parameter expects a two-char country code like "de", "ch" or "us". It limits the query to the given country.

See also [#my-clubs](#my-clubs) and [#bookmark-add](#bookmark-add).

---

<h2 id="my-reservations">GET #my-reservations</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#my-reservations": {
  "href": "https://staging.mycourt.pro/api/reservations"
}
{% endhighlight %}

Lists all the upcoming reservations for the user.

See also [#reservations](#reservations) and [#reserve](#reserve).

---

<h2 id="members">GET #members</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#members": {
  "href": "https://staging.mycourt.pro/api/members/{clubId}{?query,count}",
  "templated": true
}
{% endhighlight %}

Lists the members of a club. Takes optional ```query``` and ```count```.

Count limits the number of users in the answer.

Query is used to narrow to users whose names (first or last) start with the given query. Mostly used for typeahead input.

See also [#clubs](#clubs) and [#reserve](#reserve).

---

<h2 id="reserve">POST #reserve</h2>

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

Posts a reservation.

Returns ```402 Payment Required``` if the slot requested is subject to a tariff and the user has not yet specified a credit card for this this (see [#payment-add](#payment-add)).

See also [#reservations](#reservations) and [#my-reservations](#my-reservations).

---

<h2 id="subscribe">POST #subscribe</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#subscribe": {
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

Returns ```402 Payment Required``` if the user is not an owner of the club and has not yet indicated which credit card to use (see [#payment-add](#payment-add)).

See also [#clubs](#clubs).

---

<h2 id="bookmark-add">POST #bookmark-add</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#bookmark-add": {
  "href": "https://staging.mycourt.pro/api/bookmark",
  "method": "POST",
  "fields": [
    { "name": "clubId", "required": true }
  ]
}
{% endhighlight %}

Bookmarks a club.

See also [#clubs](#clubs) and [#bookmark-remove](#bookmark-remove).

---

<h2 id="bookmark-remove">DELETE #bookmark-remove</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#bookmark-remove": {
  "href": "https://staging.mycourt.pro/api/bookmark/{clubId}",
  "method": "DELETE",
  "templated": true
}
{% endhighlight %}

Removes a club bookmark.

See also [#clubs](#clubs) and [#bookmark-add](#bookmark-add).

---

<h2 id="slots">GET #slots</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#slots": {
  "href": "https://staging.mycourt.pro/api/clubs/{clubId}/slots/{day}",
  "templated": true
}
{% endhighlight %}

A combination of [#reservations](#reservations) and [#slot-prices](#slot-prices) (will deprecate those two).

Returns in one stroke each court slots with prices and reservations.

Here is a sample response (only one court though):

{% highlight javascript %}
{
  "version": "1.0",
  "_embedded": {
    "slots": [
      {
        "courtId": 69484,
        "courtName": "old dirty court",
        "courtGroupId": 62799,
        "courtGroupName": "Group1",
        "slots": [
          {
            "reservations": [],
            "slot": "0700",
            "price": 0.0,
            "start": 700,
            "end": 800,
            "associationId": 161670,
            "associationName": "subscription",
            "associationKind": "subscription",
            "associationSubKind": "subscription",
            "associations": []
          },
          {
            "reservations": [],
            "slot": "0800",
            "price": 0.0,
            "start": 800,
            "end": 900,
            "associationId": 161670,
            "associationName": "subscription",
            "associationKind": "subscription",
            "associationSubKind": "subscription",
            "associations": []
          },
          {
            "reservations": [
              {
                "id": 16991,
                "courtId": 69484,
                "courtName": "old dirty court",
                "clubId": 55035,
                "clubName": "Club des Modzons",
                "clubLongName": "Club des Modzons - Malibu",
                "day": 20131111,
                "start": 900,
                "end": 1000,
                "hour": "0900",
                "slot": "20131111-900",
                "slotStart": "09:00",
                "slotEnd": "10:00",
                "slotDay": "11.11.2013",
                "player1Id": 79936,
                "player1Name": "Alfred Muster",
                "player1DetailedName": "Alfred Muster ( 1800)",
                "player2Id": 79937,
                "player2Name": "Bob Scampioni",
                "player2DetailedName": "Bob Scampioni ( 1800)",
                "modifierId": 79937,
                "modifier": "Bob Scampioni",
                "updatedAt": "11/7/2013 9:47:19 AM",
                "associationId": 161670,
                "price": "0EUR"
              },
              {
                "id": 16992,
                "courtId": 69484,
                "courtName": "old dirty court",
                "clubId": 55035,
                "clubName": "Club des Modzons",
                "clubLongName": "Club des Modzons - Malibu",
                "day": 20131111,
                "start": 900,
                "end": 1000,
                "hour": "0900",
                "slot": "20131111-900",
                "slotStart": "09:00",
                "slotEnd": "10:00",
                "slotDay": "11.11.2013",
                "modifierId": 79937,
                "modifier": "Bob Scampioni",
                "updatedAt": "11/7/2013 9:47:19 AM",
                "associationId": 161670,
                "price": "0EUR"
              }
            ],
            "slot": "0900",
            "price": 0.0,
            "start": 900,
            "end": 1000,
            "associationId": 161670,
            "associationName": "subscription",
            "associationKind": "subscription",
            "associationSubKind": "subscription",
            "associations": []
          },
          {
            "reservations": [],
            "slot": "1000",
            "price": 0.0,
            "start": 1000,
            "end": 1100,
            "associationId": 161670,
            "associationName": "subscription",
            "associationKind": "subscription",
            "associationSubKind": "subscription",
            "associations": []
          }
        ]
      }
    ]
  }
}
{% endhighlight %}

See also [#clubs](#clubs).

---

<h2 id="payment-add">POST #payment-add</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#payment-add": {
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

---

<h2 id="membership-request">POST #membership-request</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#membership-request": {
  "href": "https://staging.mycourt.pro/api/membership",
  "method": "POST",
  "fields": [
    { "name": "clubId", "required": true },
    { "name": "userId" }
  ]
}
{% endhighlight %}

Request membership to a given club.

Returns 409 Conflict if there is already an existing membership (active, requested or any other state) for this club (and the current user).

Specifying ```clubId``` and ```userId``` lets the owner of a club accept a membership request via the MyCourt API. (Not yet implemented).

See also [#clubs](#clubs) and [#subscribe](#subscribe).

---

<h2 id="translations">GET #translations</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#translations": {
  "href": "https://staging.mycourt.pro/api/translations"
}
{% endhighlight %}

Currently only used to pass translated sport names.

This is what the typical answer (minus links) looks like:

{% highlight javascript %}
{
  "version": "1.0",
  "_embedded": {
    "sports": [
      {
        "id": 1, "name": "Tennis", "key": "tennis",
        "de": ".sports.tennis", "en": "tennis", "fr": "tennis"
      },
      {
        "id": 2, "name": "Squash", "key": "squash",
        "de": ".sports.squash", "en": "squash", "fr": "squash"
      },
      {
        "id": 3, "name": "Badminton", "key": "badminton",
        "de": ".sports.badminton", "en": "badminton", "fr": "badminton"
      },
      {
        "id": 4, "name": "Table tennis", "key": "table_tennis",
        "de": ".sports.table_tennis", "en": "table tennis", "fr": "tennis de table"
      },
      {
        "id": 5, "name": "Basque pelota", "key": "basque_pelota",
        "de": ".sports.basque_pelota", "en": "basque pelota", "fr": "pelote basque"
      }
    ]
  }
}
{% endhighlight %}

