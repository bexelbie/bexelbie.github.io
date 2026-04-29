---
title:      "The new Coinbase Card"
date:       2019-04-12 15:30:00 +0100
excerpt: "The interesting part isn't the BTC, it's this arbitrage"
categories:
  - Ramblings
tags:
  - Finance
header:
  overlay_color: "#333"
---

Note: This is not becoming a Finance Blog, I promise.  I just happened upon two interesting finance topics in a row.

Coinbase recently [announced](https://www.coinbase.com/card) a new debit card that uses BitCoin (BTC) as the base currency.  The [card FAQ](https://support.coinbase.com/customer/portal/articles/2969910-coinbase-card-faq) is lighter on details than I'd like and right now the full text of the card holder agreement isn't online.  I presume it is available through the app, which I have not installed.  Lots of people have opinions about the card, but they tend to be focusing on the fees, which seem reasonable in the banking market, but way too high for fintech savvy customers.  Compare them to Revolut, for example.

People are also [focusing](https://mashable.com/article/coinbase-visa-debit-card-uk-europe.amp/?europe=true) on the "Crypto Liquidation Fee" of 2.49% which is being interpreted as the equivalent of a "foreign currency conversion fee."  The official FAQ doesn't spell this out, so it may be something else being poorly explained, or this may be the UK language used for these kinds of fees.  At 2.49% it is on the very high side of foreign conversion fees, but it is also, in and of itself, not terribly interesting.

Most of the press seems to be [focused](https://www.techspot.com/news/79615-spending-cryptocurrency-easier-than-ever-coinbase-card.html) on how this is making cryptocurrencies easier to spend.  They're right.  This is also horribly uninteresting as this is not much of a new idea.  The same logic could be applied to my CZK currency debit card being enabled in making "CZK easier to spend" because they'll do on the fly conversion from other currencies (at an equally bad 2-3% fee).

I think the interesting thing the card raises is about how people interact with currencies.  I posit that most users of this card will wind up in this pattern:

1. Earn money in some fiat currency
2. Convert that fiat current into a cryptocurrency at some fee
3. Spend the cryptocurrency to buy goods priced in the original fiat currency at some fee

Once you have a robust market, the fees in '2' and '3' will begin to approach zero.  (Don't believe me - again, look at Revolut, Transferwise, and their ilk.)  This is interesting, because when this happens you are speculating, [as has been pointed out](https://www.newsbtc.com/2019/04/11/coinbases-crypto-debit-card-is-more-expensive-than-bank-cards/), but with a smoother market it becomes more predictable.  Therefore, we are theoretically getting a class of people who are doing micro-arbitrage.  This is interesting and part of a real-world problem I played with for a bit in February.

There is little that I have found written about real-time daily-spending level FOREX.  As ComputerWorld pointed out, [this may be really interesting for those who live in volatile currencies](https://www.computerworld.com/article/3388066/visa-and-coinbase-team-up-on-crypto-backed-debit-card.html) that experience runaway inflation.  But, once you eliminate this "edge-case" group you wind up with people like me and these card holders.  I am paid in Czech Crowns (CZK) but have access to a cash-back[^0] credit card denominated in US Dollars (USD).  I figured out that the fees looked like this, **assuming a fixed exchange rate**:

* Fee1: CZK to USD conversion at the time of transaction (0% markup on the visa interchange rate which is generally on target with the spot rate)
* Fee2: CZK to USD conversion at the time of bill payment (typically 0% markup on the spot rate via Revolut and others)
* Fee3: USD Cash back on the transaction amount (1.5% or more credit, an inverse fee, if you will)

The sum of these represented about a -.6% rate.  In other words, I made money on my spending.  Woo!

**Except** I am subject to currency exchange risk at a very small level.  If the CZK:USD rate changes by very little, I can easily be losing money on this transaction.

If you're still with me, you're probably wondering if this is ever worth the effort for a less than 1% payback.  On one hand, it isn't if it takes too much time.  On the other hand, it is part of a strategy of micro-optimization that is much like choosing the index fund with the 0.15% fee instead of the one with the 0.5% fee.  At some point, this is one of the few optimizations you have left to make[^1].

Therefore, we need to develop some guiding principles for how these kinds of optimizations should be done.  This is similar to the FIRE community's approach to suggesting index fund strategies to fund a long retirement.  We need a set of rules and principles for making decisions about when to move to alternative base currencies and when not too.

I suspect it is initially going to viewed as, "If your base currency has problems, convert, otherwise, hodl[^2]."  However, I suspect that there is a more rich set of rules and principles available.  Frankly, if cryptocurrency is ever going to begin being used on a mass scale[^3], we have to have them.  I am not sure this is a good thing or a bad thing, but as an expat, more exploration into cross-currency planning is very important to me.

To start this, I did some simplistic back-testing of a rule that said this:

1. Convert CZK to USD on the 1st of the month to cover expected spending
2. Spend in USD, my alternative currency base, until the exchange rate had risen by .6%
3. Finish the month spending in the real base currency, CZK for me.

This rule resulted in an average spend of about half the month in each currency.  The standard deviation was wide though, so some months had almost no USD spend and others were almost completely in USD.  Clearly this is too simplistic.  For one thing, anything that doesn't cost money should be considered success.  Therefore, theoretically, the .6% gain on each transaction could be used to fund losses on other transactions, to a net of zero.  That is sounding like a like of work without a dedicated app.  It is also a very point in time focused strategy.  Is there a long-view option?

[^0]: No one gets rich on cash back -- we aren't talking about this today!
[^1]: I am also a huge spreadsheet and optimization nerd, so roll with it.
[^2]: You knew an article that mentioned BTC would slip this in ...
[^3]: I don't care, but contributors are motivated by their own desires, not mine.
