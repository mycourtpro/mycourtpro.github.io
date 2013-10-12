---
layout: api
title: API rels
---

# rels

blah blah blah.

{% highlight javascript %}
{
  "_links": {
    "self": {
      "href": "https://staging.mycourt.pro/api"
    },
    "https://mycourt.pro/rels#my-clubs": {
      "href": "https://staging.mycourt.pro/api/clubs"
    },
    "https://mycourt.pro/rels#my-reservations": {
      "href": "https://staging.mycourt.pro/api/reservations"
    },
    "https://mycourt.pro/rels#reservations": {
      "href": "https://staging.mycourt.pro/api/reservations/{clubId}/{day}",
      "templated": true
    },
    "https://mycourt.pro/rels#members": {
      "href": "https://staging.mycourt.pro/api/members/{clubId}{?query,count}",
      "templated": true
    },
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
    },
    "https://mycourt.pro/rels#subscribe": {
      "href": "https://staging.mycourt.pro/api/subscription",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true },
        { "name": "subscriptionId", "required": true },
        { "name": "userId" }
      ]
    },
    "https://mycourt.pro/rels#bookmark-add": {
      "href": "https://staging.mycourt.pro/api/bookmark",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true }
      ]
    },
    "https://mycourt.pro/rels#bookmark-remove": {
      "href": "https://staging.mycourt.pro/api/bookmark/{clubId}",
      "method": "DELETE",
      "templated": true
    },
    "https://mycourt.pro/rels#slot-prices": {
      "href": "https://staging.mycourt.pro/api/clubs/{clubId}/prices/{day}",
      "templated": true
    },
    "https://mycourt.pro/rels#payment-add": {
      "href": "https://staging.mycourt.pro/api/payment",
      "method": "POST",
      "fields": [
        { "name": "clubId", "required": true },
        { "name": "token", "required": true },
        { "name": "nick", "required": true }
      ]
    }
  }
}
{% endhighlight %}

