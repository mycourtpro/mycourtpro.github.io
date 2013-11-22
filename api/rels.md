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
* [#associations](#associations)
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

Returns in one stroke each court slots with prices and reservations.

The answer is structured in an object with two entries: "slots" and "associations". The slots lists all the slots for the day for the club, with prices and reservations. Prices and reservations may refer to associations. They only do it via the associationId. The "associations" part of the answer is an object that can be used to look up the association details.

The associations are included in the answer because calling [#associations](#associations) will only return "active" associations. In the case of a "prepaid" subscription, it might become "consumed" and not by returned by #association, but the "associations" part of the #slots answer will contain it.

Here is a sample response (only one court though, and links edited out for brevity):

{% highlight javascript %}
{
  "version": "1.0",
  "userId": 84546,
  "slots": [
    {
      "courtId": 74285,
      "courtName": "court1",
      "courtGroupId": 66662,
      "courtGroupName": "group1",
      "slots": [
        {
          "reservations": [],
          "slot": "0700",
          "price": -1,
          "start": 700,
          "end": 800,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "0800",
          "price": -1,
          "start": 800,
          "end": 900,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "0900",
          "price": -1,
          "start": 900,
          "end": 1000,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1000",
          "price": 6.0,
          "start": 1000,
          "end": 1100,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1100",
          "price": 6.0,
          "start": 1100,
          "end": 1200,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1200",
          "price": 7.5,
          "start": 1200,
          "end": 1300,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1300",
          "price": -1,
          "start": 1300,
          "end": 1400,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1400",
          "price": -1,
          "start": 1400,
          "end": 1500,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1500",
          "price": -1,
          "start": 1500,
          "end": 1600,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1600",
          "price": -1,
          "start": 1600,
          "end": 1700,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1700",
          "price": -1,
          "start": 1700,
          "end": 1800,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1800",
          "price": -1,
          "start": 1800,
          "end": 1900,
          "subscriptionTemplates": []
        }
      ]
    },
    {
      "courtId": 74286,
      "courtName": "court2",
      "courtGroupId": 66662,
      "courtGroupName": "group1",
      "slots": [
        {
          "reservations": [],
          "slot": "0700",
          "price": -1,
          "start": 700,
          "end": 800,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "0800",
          "price": -1,
          "start": 800,
          "end": 900,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "0900",
          "price": -1,
          "start": 900,
          "end": 1000,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1000",
          "price": 6.0,
          "start": 1000,
          "end": 1100,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1100",
          "price": 6.0,
          "start": 1100,
          "end": 1200,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1200",
          "price": 7.5,
          "start": 1200,
          "end": 1300,
          "associationId": 172717,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1300",
          "price": -1,
          "start": 1300,
          "end": 1400,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1400",
          "price": -1,
          "start": 1400,
          "end": 1500,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1500",
          "price": -1,
          "start": 1500,
          "end": 1600,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1600",
          "price": -1,
          "start": 1600,
          "end": 1700,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1700",
          "price": -1,
          "start": 1700,
          "end": 1800,
          "subscriptionTemplates": []
        },
        {
          "reservations": [],
          "slot": "1800",
          "price": -1,
          "start": 1800,
          "end": 1900,
          "subscriptionTemplates": []
        }
      ]
    }
  ],
  "associations": {
    "templates": [
      172717
    ],
    "172717": {
      "id": 172717,
      "userId": null,
      "clubId": 58247,
      "status": "active",
      "description": null,
      "kind": "tariff",
      "name": "tariff0",
      "rank": 0,
      "subKind": "tariff",
      "dataBag": {
        "schedule": "1d-7d10-12=6.0;1d-7d12-13=7.5",
        "nonMembers": true
      },
      "createdAt": "2013-11-22T04:47:26.617Z",
      "updatedAt": "2013-11-22T04:47:31.987Z",
      "price": null
    }
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

<h2 id="associations">GET #associations</h2>

{% highlight javascript %}
"http://mycourtpro.github.io/api/rels.html#associations": {
  "href": "https://staging.mycourt.pro/api/club/{clubId}/associations"
}
{% endhighlight %}

Returns a dictionary (JSON object) mapping association ids to association JSON representations.
There is a special entry (key is "templates") that lists those association ids that point to template association (the list of subscriptions the current user can acquire in this club).

Note that this call returns only associations that are "active". Whereas the [#slots](#slots) call returns all the active associations between a club and the user plus "consumed" associations referred to by the reservations in the slots.

Typical answer (minus links):

{% highlight javascript %}
{
  "version": "1.0",
  "userId": 82328,
  "associations": {
    "templates": [
      167423
    ],
    "167422": {
      "id": 167422,
      "userId": 82328,
      "clubId": 56685,
      "status": "active",
      "description": null,
      "kind": "membership",
      "name": "member",
      "rank": 0,
      "dataBag": {},
      "createdAt": "2013-11-17T01:16:28.07Z",
      "updatedAt": "2013-11-17T01:16:29.76Z"
    },
    "167423": {
      "id": 167423,
      "userId": null,
      "clubId": 56685,
      "status": "active",
      "description": null,
      "kind": "subscription",
      "name": "standard0",
      "rank": 0,
      "dataBag": {},
      "createdAt": "2013-11-17T01:16:28.077Z",
      "updatedAt": "2013-11-17T01:16:29.76Z"
    }
  }
}
{% endhighlight %}

See also [#slots](#slots).

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
  "userId": 82328,
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

