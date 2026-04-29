---
title:      "Avoiding Double Taxation with Tax Treaties"
excerpt:   "It's about way more than the FEIE"
date:       2017-01-09 08:00:00
categories:
  - Ramblings
tags:
  - Tax
header:
  overlay_image: "/img/2017/tax/header.png"
  og_image: "/img/2017/tax/header.png"
  teaser: "/img/2017/tax/header.png"
  caption: "Photo credit: author"
  overlay_filter: 0.5
comments:   true
redirect_from:
 - /ramblings/2017/01/09/international-taxes/
classes: none
toc: true
---

As an American living in Europe I have to deal with some international tax issues.  Lots and lots has been written about American taxation for non-resident Americans.  However, most of it is repetitive and simplistic.  I see almost no fully worked examples and nothing with what I consider even basic levels of "complexity." 

Most examples and conversations focus on one thing, the Foreign Earned Income Exclusion (FEIE) vs the Foreign Tax Credit (FTC) for Earned Income.  This has been written about by everyone.  Therefore, in my example, we are just going to use the FEIE and not explore this.  Maybe later, if there is interest, the example can be worked both ways.

I am not an Accountant, Enrolled Agent, CPA, Tax Attorney, or any other fancy tax person.  My thoughts below are my own and may not be accurate for your situation, lifestyle, taxes, or universe.  If you follow anything written on this page you are on your own.  That said, lets have some fun.

# Meet Bob

Bob is an American who has moved to Europe.  He has a job in a country with a tax treaty with the United States.  Bob's completely fictitious profile is below.  His profile has been set up to ensure that he will owe tax to the US after FEIE.

* Bob is single and has no children.
* Bob earned the equivalent of $50,000 USD working for a foreign employer.
* Bob has a bank account in the US that earned $100 in interest (reported on a 1099-INT).
* Bob has a bank account in his country of residence that earned the equivalent of $1000 in interest with $150 in tax withheld at source.
* Bob has a brokerage account in the US that resulted in the following:
  * $1,500 in Dividends of which $1,000 is Qualified Dividends.
  * $2,000 in Short Term Capital Gains.
  * $4,000 in Long Term Capital Gains for assets held for less than 3 years.
  * $10,000 in Long Term Capital Gains for assets held for at least 3 years.  The 3 year mark is irrelevant for US Tax purposes, but matters in Bob's country of residence.
  * All assets are non-real estate
* Bob has no other sources of income.
* Bob is covered by a Totalization Agreement so we will not be considering Social Security and Medicare Taxes.
* Bob moved from a state that does not try to keep him as a resident so there is no state tax consideration.
* Bob's resident country taxes residents on their worldwide income and Bob is a full-year tax resident.
* Bob rents and has no Schedule A qualified deductions other than foreign tax.
* Bob meets all qualifications required for the Foreign Earned Income Exclusion.
* Bob has completed his foreign tax return and without any treaty benefits, his numbers are:
  * Taxable Income: $57,600
  * Total Tax: $7,640 + $150 withheld on interest at source[^0]
  * Tax Percent: 13.26%, ignoring the $150 withheld on interest at source

# Baseline US Tax Return

As an American citizen, Bob is subject to tax on his worldwide income by the United States as though he were resident in the United States.  Let's start by building a basic 2016 tax return for him as though he had residency in the United States with this income profile.  We will begin by ignoring all foreign tax considerations.

[The tax return](/img/2017/tax/baseline.pdf)

Bob's baseline tax return is pretty basic.  His Adjusted Gross Income (AGI), as expected, is $68,600 and after taking the standard deduction ($6,300) and the personal exemption ($4,050) his taxable income is $58,250.  I've included the Schedule D tax worksheet so you can see where his tax of $8,840 comes from.  His qualified dividends and long term capital gains were taxed at a preferred rate so he paid less than the tax table value of $10,340.

This is not terribly interesting as far as taxes go, but it shows us where we are starting.  If there was no double-taxation prevention, Bob would pay over $16,000 in taxes.

# FEIE, a/k/a "Now you see it, now you don't"

[The tax return](/img/2017/tax/feie.pdf)

Let's apply just the Foreign Earned Income Exclusion (FEIE).  This will remove the earned income from the tax return.  If there is interest we can revisit this as a Foreign Tax Credit later.

After adding a 2555 to claim the FEIE and exclude the $50,000, we see Bob's AGI fall to $18,600 and his taxable income fall to $8,250.  His tax is now $562.  I've attached his Schedule D and FEIE worksheets so you can see how the calculation was done.  Again, his preferred tax treatment for qualified distributions and long term capital gains have helped him pay less tax.

If you haven't explored the FEIE before, it is mostly important that you notice that the exclusion results in the remaining taxable income being charged at the highest rates possible.  If you think about the graduated tax system used by the US, the excluded income fills the lower brackets and then the remaining income is layered on top.  In this case, Bob avoids the worst of it because his remaining taxable income is almost all taxed at preferred rates.

# Warning: Dragons Ahead

At this point we've reached the limit of the guidance and worked examples I've been able to find.  I suspect someone, somewhere has written about these ideas, but I haven't seen it.  I am going to work through the rest of this using my best understanding.  I am hoping that any errors I make will be pointed out by others so this can become a more useful reference.  So, warning, ahead be dragons.

# Definitively Foreign Source Unearned Income

Bob has one item of definitively foreign source unearned income, his foreign bank account interest.  He received $1000 in interest and had $150 in tax withheld at source.  I will explore why I think the US has to give the tax credit more in the next section.  For the purposes of this section, let's just accept that a credit will be given by the US for taxes paid to a foreign government.  We use form 1116 to claim the Foreign Tax Credit.  The form is required because the tax was not reported on a 1099.

Form 1116 is a multi-use form and covers a lot of different situations.  There are also many reasons why you may have to use more than one copy of this form in a single tax return.  Bob's foreign bank interest is Passive category income.

[The tax return](/img/2017/tax/ftc.pdf)

The only change on 1040 is the $41 foreign tax credit (see line 48).  Wait a minute, Bob paid $150 in foreign tax.  Why is his credit so low?  If you look at form 1116 and review line 3 (all parts), you'll see that the $1,000 in foreign bank interest is 14.6% of Bob's total income (line 3f).  Bob's standard deduction of $6,300 is removed from his gross income before the tax is calculated.  Therefore we have to allocate 14.6% of this deduction to Bob's foreign bank interest.  This reduces his tax credit eligible income to $908 (line 7).

On the second page of form 1116, line 19 calculates that the $908 is 7.38% of Bob's total pre-personal exemption (1040 line 41, 1116 line 18) income.  Therefore only 7.38% of Bob's tax is allocated this income.  Line 21 is the result of multiplying the $562 tax by 7.38%.  Therefore, his credit is limited to $41.

If you go forward a few pages in the return, you'll find the "Worksheet for Form 1116 - Foreign Tax Credit Carryover Worksheet for Passive Category Income."  This fancy-pants worksheet just shows that Bob has a $109 carryover tax credit for his unused foreign tax.  $109 is what is left after subtracting the $41 allowed credit from the total tax of $150 paid on the foreign source income.

I am not going to explore carryover and carryback foreign tax credits in detail.  However, the short version is that you can use the unused foreign tax credits in the previous year (carryback) or at anytime in the next 10 years (carryover).  Like everything, there are rules.

# Who gave the dragons reinforcements? a/k/a Dealing with Foreign Taxation of US Source Income

Those dragons I mentioned earlier are about to get a lot more worrisome.  At this point we need to start thinking about Tax Treaties, I think.  This is the place where nothing seems to have been definitively written.  Even IRS wasn't very helpful here[^1].  For the purposes of this exercise, we will assume that Bob lives in the [Czech Republic](https://www.irs.gov/businesses/international-businesses/czech-republic-tax-treaty-documents)[^2] which has a tax treaty with the United States.  The [tax treaty](https://www.irs.gov/pub/irs-trty/czech.pdf) and the [technical notes](https://www.irs.gov/pub/irs-trty/czechtech.pdf) are reasonable reads and mostly understandable.

Let's start by reviewing Bob's income:

* **Wages** - Bob's wages are earned in the Czech Republic and have been excluded using the FEIE
* **Foreign Bank Interest** - Bob's foreign bank interest and the tax directly withheld have been processed on form 1116
* **US Bank Interest** - Bob's US bank interest was taxed on his Czech tax return and has not had any credit treatment on his US tax return, yet.
* **US Dividends** - Bob's US dividends were taxed on his Czech tax return and has not had any credit treatment on his US tax return, yet.
* **US Capital Gains** - Bob's US capital gains were taxed on his Czech tax return and has not had any credit treatment on his US tax return, yet.

Let's explore these last three for treatment and then we will follow up with application.

## Interest

The tax treaty discusses interest in Article 11.  Paragraphs 1 and 5 seem to be the only ones relevant for Bob:

> 1. Interest arising in a Contracting State and beneficially owned by a resident of the other Contracting State shall be taxable only in that other State.
> 
> 5. Interest shall be deemed to arise in a Contracting State when the payer is a resident of that State. Where, however, the person paying the interest, whether he is a resident of a Contracting State or not, has in a Contracting State a permanent establishment or fixed base, and such interest is borne by such permanent establishment or fixed base, then such interest shall be deemed to arise in the State in which the permanent establishment or fixed base is situated.

This would seem to indicate that a resident of the Czech Republic having interest received from sources in the United States shall only be taxed on that interest in the Czech Republic.  Further that interest shall be considered to be Czech source income.

The technical notes seem to support this conclusion.

> Paragraph 1 grants to each Contracting State the exclusive right (subject to paragraphs 2 and 4) to tax interest beneficially owned by a resident of that Contracting State and arising in the other Contracting State.
> 
> Paragraph 5 provides a source rule for interest. Under this paragraph, interest is deemed to arise in a Contracting State when the payer is a resident of that State. Where, however, the payer (whether or not a resident of a Contracting State) has in a Contracting State a permanent establishment or fixed base, and such interest is borne by such permanent establishment or fixed base, then such interest shall be deemed to arise in the State in which the permanent establishment or fixed base is situated.

## Dividends

The tax treaty discusses dividends in Article 10.  Paragraphs 1 and 2 seem to be the only ones relevant for Bob:

> 1. Dividends paid by a company which is a resident of a Contracting State to a resident of the other Contracting State may be taxed in that other State.
> 
> 2. However, such dividends may also be taxed in the Contracting State of which the company paying the dividends is a resident, and according to the laws of that State, but if the beneficial owner of the dividends is a resident of the other Contracting State, the tax so charged shall not exceed: ... b) 15 percent of the gross amount of the dividends in all other cases.

Paragraph 1 seems to mean that US source dividends paid to a resident of the Czech Republic are able to be taxed by the Czech Republic.  This has happened.

Paragraph 2 limits the US to a 15 percent maximum tax rate.

Again, the technical notes seem to support these conclusions.

> This Article provides rules for the taxation of dividends and similar amounts paid by a company resident in one Contracting State to a resident of the other Contracting State. The article permits full residence State taxation of such dividends and limited source State taxation.  Article 10 also provides rules for the imposition of a tax on branch profits by the State of source.
> 
> Paragraph 1 preserves the residence State's general right to tax its residents on dividends paid by a company that is a resident of the other Contracting State. The same result is achieved by the "saving" clause of paragraph 3 of Article 1 (General Scope).
>
> Paragraph 2 grants the source State the right to tax dividends paid by a company that is a resident of that State to a resident of the other Contracting State. If the beneficial owner of the dividend is a company that owns at least 10 percent of the voting shares of the company paying the dividend, the tax that may be imposed by the source State is limited to 5 percent of the gross amount of the dividend. In all other cases, the source State tax is limited to 15 percent of the gross amount of the dividend. Indirect ownership of voting shares (e.g., through tiers of corporations) and direct or indirect ownership of nonvoting shares are not considered for purposes of determining eligibility for the 5 percent direct investment dividend rate.

The explanation for paragraph 1 mentions the "saving" clause.  We will explore that more in two sections.

## Capital Gains

The tax treaty discusses gains in Article 13.  Paragraph 6 seem to be the only one relevant for Bob as most of the section is taken up by the discussion of gains from real property.  Bob's stock is not real property in this situation.

> 6. Gains from the alienation of any property other than property referred to in paragraphs 1 through 5 shall be taxable only in the Contracting State of which the alienator is a resident.

This would seem to indicate that a resident of the Czech Republic having gains received from sources in the United States shall only be taxed on that interest in the Czech Republic.

Again, the technical notes seem to support this conclusion.

> This Article provides rules for source and residence State taxation of gains from the alienation of property.
> 
> Paragraph 6 grants to the residence State the exclusive right to tax gains from the alienation of property other than property referred to in paragraphs 1 through 5.

## The "Saving" Clause

Reading the above, you'd think Bob would be mostly on easy street.  His interest and gains aren't taxable by the United States and his dividends are taxable at a maximum rate of 15%.  Unfortunately for Bob he is about to meet the "saving" clause.  Article 1, paragraph 3 of the tax treaty says:

> 3. A Contracting State may tax its residents (as determined under Article 4 (Resident)) and its citizens, including former citizens, according to the laws of that State as if the Convention had not come into effect.

**Boom** The US has the right to tax Bob any way it wants to as Bob is a citizen.  This preserves the right of the US to tax it's citizens on worldwide income without regard to residency.

Unfortunately, again, the technical notes seem to support this conclusion.

> Paragraph 3 contains the traditional "saving" clause found in all U.S. treaties. Under this paragraph, each of the Contracting States may tax its own residents, citizens and former citizens, in accordance with its domestic law, notwithstanding any Convention provision to the contrary.  If, for example, a Czech resident performs independent personal services in the United States and the income from the services is not attributable to a fixed base in the United States, Article 14 (Independent Personal Services) would normally prevent the United States from taxing the income. If, however, the Czech resident is also a citizen of the United States, the "saving" clause permits the United States to include the remuneration in the worldwide income of the citizen and subject it to tax under normal Code rules (i.e., without regard to Code section 894(a)). Special foreign tax credit rules applicable to U.S. taxation of certain U.S. income of U.S. citizens resident in the Czech Republic are provided in paragraph 3 of Article 24 (Relief from Double Taxation).

## Relief from Double Taxation

This leads us to Article 24 of the treaty about double taxation.  The entire section is:

> 1. In accordance with the provisions and subject to the limitations of the law of the United States (as it may be amended from time to time without changing the general principle hereof), the United States shall allow to a resident or citizen of the United States as a credit against the United States tax on income the income tax paid to the Czech Republic by or on behalf of such resident or citizen.
>
> 2. In the Czech Republic, double taxation will be avoided in the following manner: The Czech Republic, when imposing taxes on its residents, may include in the tax base upon which such taxes are imposed the items of income which according to the provisions of this Convention may also be taxed in the United States, but shall allow as a deduction from the amount of tax computed on such a base an amount equal to the tax paid in the United States (other than solely on the basis of citizenship). Such deduction shall not, however, exceed that part of the Czech tax, as computed before the deduction is given, which is appropriate to the income which, in accordance with the provisions of this Convention, may be taxed in the United States (other than solely on the basis of citizenship).
>
> 3. In the case of an individual who is a citizen of the United States and a resident of the Czech Republic, income which may be taxed by the United States solely by reason of citizenship in accordance with paragraph 3 of Article 1 (General Scope) shall be deemed to arise in the Czech Republic to the extent necessary to avoid double taxation, provided that in no event will the tax paid to the United States be less than the tax that would be paid if the individual were not a citizen of the United States.

The technical notes for this article are:

> In this Article, each Contracting State undertakes to relieve double taxation by granting a foreign tax credit against its income tax for the income tax paid to the other country. Under paragraph 1, the credit granted by the United States is allowed in accordance with the provisions and subject to the limitations of U.S. law, as that law my be amended over time, so long as the general principle of this Article (the allowance of a credit) is retained. Thus, although the Convention provides for a foreign tax credit, the terms of the credit are determined by the provisions of the U.S. statutory credit, at the time the credit is given.
>
> The U.S. foreign tax credit is generally limited under the Code to the amount of U.S. tax due with respect to net foreign source income within the relevant foreign tax credit limitation category (see Code section 904(a)). Nothing in the Convention prevents the limitation of the U.S.  credit from being applied on a per-country or overall basis or some variation thereof. In general, where source rules are provided in the Convention for purposes of determining the taxing rights of the Contracting States, these are consistent with the Code source rules for foreign tax credit and other purposes. Where, however, there is an inconsistency between Convention and Code source rules, the Code source rules (e.g., Code section 904(g)) will be used to determine the limits for the allowance of a credit under the Convention. (Paragraph 3 of the Article provides an exception to this general rule with respect to certain U.S. source income of U.S. citizens resident in the Czech Republic.)
>
> Paragraph 2 provides that the Czech Republic may include in the income tax base of its residents items of income that, under the Convention, are also taxable by the United States. The Czech Republic will credit the U.S. tax paid on such income to the extent that such tax does not exceed the amount of Czech tax that is appropriate to the income.
>
> Paragraph 3 provides a special rule for the tax treatment of U.S. citizens resident in the Czech Republic. Under this paragraph, income that may be taxed by the United States solely by reason of citizenship in accordance with the "saving" clause of paragraph 3 of Article 1 (General Scope) shall be treated as having its source in the Czech Republic to the extent necessary to avoid double taxation. This provision overrides U.S. law source rules only in those cases where U.S. law would operate to deny a foreign tax credit for taxes imposed by the Czech Republic under the provisions of the Convention on U.S. citizens resident in the Czech Republic. In no case, however, is this provision to reduce the taxes paid to the United States below the amount that would be paid if the individual were not a citizen of the United States, i.e., the U.S. tax imposed on a nonresident, non-citizen with respect to income arising in the United States.
>
> As an example of the application of paragraph 3, consider a U.S. citizen resident in the Czech Republic who receives $200 of portfolio dividend income from United States sources and is subject to U.S. tax at 28 percent ($56) on that income. Under the provisions of Article 10 (Dividends), the United States tax on portfolio dividends paid to residents of the Czech Republic who are not U.S. citizens is limited to 15 percent ($30 in this case). Suppose the Czech Republic taxes that income of its resident at 40 percent, or $80, and grants, in accordance with the provisions of paragraph 2 of this Article, a credit for the $30 of U.S. tax imposed on the basis of source only. The net Czech tax will be $50 and the total tax $106. Thus, the total tax is higher than either of the two countries' taxes, indicating some double taxation. The United States agrees to resource enough of that dividend income to avoid double taxation, but in no case, to reduce the U.S. tax paid below the $30 it is entitled to tax at source. In this example, the U.S. will resource enough of the dividend to permit a credit of $26, thus reducing its net tax from $56 to $30. The total tax becomes $80 ($50 + 30), the higher of the two taxes, and double taxation is eliminated. (The need for such a resourcing provision arises only if the Czech tax exceeds the applicable U.S. tax and the Czech credit permitted under its law and the treaty is limited to the U.S. tax imposed under the treaty on residents of the Czech Republic who are not U.S. citizens.)
>
> By reason of paragraph 4(a) of Article 1 (General Scope), Article 24 is not subject to the provisions of the "saving" clause of paragraph 3 of Article 1. Thus, the "saving" clause cannot be used to deny a Czech resident the benefit of the credits provided for in paragraph 1 or to deny a U.S. citizen or resident the benefit of the credits provided for in paragraphs 2 and 3.

That is a giant wall of text.  The most important part is in the technical explanation of paragraph 3.  Basically, the US has to give a tax credit for taxes paid to the Czech Republic against taxes it is charging a citizen solely by virtue of their citizenship.  This is subject to the requirement that at no time may the tax paid to the US be less than the tax that would have been paid by a non-US citizen in the same situation.  Because the US tax code doesn't allow for foreign tax credits on US source income, the treaty provides that the income may be "resourced" to be considered foreign source income to the extent required to provide the tax credit.  There is even an example!  It'd be great if the example included forms and showed multiple situations, however, it doesn't.

So let's try to work this out for Bob.  First, to review:

* **Wages** - done
* **Foreign Bank Interest** - done
* **US Bank Interest** - Taxable only by the Czech Republic for non-US citizens, so we need to resource this to provide a tax credit.
* **US Dividends** - Taxable by the US at a rate not to exceed 15%.  If there is a higher rate charged by the Czech Republic we will resource enough to get a credit and avoid double taxation.  In this case, the Czech Republic will need to provide a tax credit for some tax and the US may need to provide a credit for some tax.
* **US Capital Gains** - Taxable only by the Czech Republic for non-US citizens, so we need to resource this to provide a tax credit.

# Re-sourcing Interest and Gains Income

Interest and Gains are only taxable in the Czech Republic (residence country).  However, the US will tax Bob by virtue of his citizenship anyway.  Therefore, Bob gets to re-source enough of this income to receive a tax credit.  Unfortunately, the example in the technical notes doesn't tell us how to figure this out.  So we need more guidance.

Let's turn to [Publication 514 - Foreign Tax Credit for Individuals](https://www.irs.gov/publications/p514/).  The section on [Certain Income Re-Sourced By Treaty](https://www.irs.gov/publications/p514/ar02.html#en_US_2015_publink1000224498) tells us to use a separate 1116 for each amount we re-source.  The referenced section, [Tax Treaties](https://www.irs.gov/publications/p514/ar02.html#en_US_2015_publink1000224636) provides a link to a worksheet that is unfortunately not valid after August 10, 2010.  I wonder what happened on that day.

So let's try something.  In general, we know that that the US will never give a credit in excess of the tax paid.  We also know that we don't get to do category based calculations for tax paid.  In other words we can't look at our Interest income and then at the top tax bracket we are in and assume that is the tax rate for that income.  We have to use average tax, like we did on the 1116 for the foreign interest above.  So lets follow that model and see where it takes us.

In order to complete this form, we need to figure out how much foreign tax was paid on each piece of income.

## Bob's Foreign Taxes

Let's look at this is more detail now.  First, let's look at Bob's gross income (worldwide):

* $50,000 - Wages
* $100 - US Interest
* $1,000 - Foreign Interest
* $1,500 - US Source Dividends
* $16,000 - US Source Capital Gains
* **$68,600** - Total Gross Worldwide Income

Czech Taxable Income:

* $50,000 - Wages
* $100 - US Interest
* $1,500 - US Source Dividends
* $6,000 - US Source Capital Gains
* **$57,600** - Total Czech Taxed Income on Czech tax return.  The foreign bank interest was taxed at source and is omitted.  $10,000 in gains is also not subject to tax because of Czech domestic tax rules.

Total Czech Tax paid on Czech tax return: $7,640

Tax Percent: (7640/57600) = 13.26%

## Back to Form 1116

Therefore, the foreign tax paid on the $100 in US interest is 100\*.1326 = $13.  The foreign tax paid on the $6,000 in capital gains is 6000\*.1326 = $796.

To add these to the return we will need to add two copies of form 1116, as I understand it.

## Form 8833 Treaty-Based Return Position Disclosure

We may also need to use form 8833 to disclose that we are using a treaty to re-source the income.  Form 8833 requires us to cite the specific tax code we are overriding.  We are changing the sourcing rules:

Interest Income Sourcing rules are defined in [IRC 861(a)(1)](https://www.law.cornell.edu/uscode/text/26/861).

Gains are more complicated.  [IRC 865(a)](https://www.law.cornell.edu/uscode/text/26/865) defines the general sourcing rules for gains.  Generally speaking, non-US residents are not taxed on non-real property associated gains.  In section 865(g) it even goes on to say that US Citizens not resident in the US are considered non-residents.  It seems that the form may not be required for gains.

Further reading, reveals that [IRC 301.6114-1(b)](https://www.law.cornell.edu/cfr/text/26/301.6114-1#b_6) needs to be examined to see if we have to disclose.  Paragraph 6 would seem to require it as it says:

> (6) Except as provided in paragraph (c)(1)(iv) of this section, that a treaty alters the source of any item of income or deduction; 

However, continuing to read the law, you will discover [IRC 301.6114-2](https://www.law.cornell.edu/cfr/text/26/301.6114-1#c_2) which eliminates the forms because our amounts are below $10,000 in total.

> (2) Reporting is waived for an individual if payments or income items otherwise reportable under this section (other than by reason of paragraph (b)(8) of this section), received by the individual during the course of the taxable year do not exceed $10,000 in the aggregate or, in the case of payments or income items reportable only by reason of paragraph (b)(8) of this section, do not exceed $100,000 in the aggregate. 

So no form 8833.

## Where are we now?

[The tax return](/img/2017/tax/treaty1.pdf)

The return is now a bit longer.  We've added two new form 1116s to the end.  Bob's foreign tax credit on line 48 is now $294 reducing his tax bill from $562 to $268.  The foreign tax credit breaks down as:

* $41 from the $150 in foreign tax paid on the foreign bank interest
* $4 from the $13 in foreign tax paid on the US bank interest
* $249 from the $796 in foreign tax paid on the Czech taxed gains

# Re-sourcing Dividend Income

Dividends are different.  The US is entitled to tax them at a rate not to exceed 15% under the treaty.  A quick calculation shows that the maximum tax the US can levy on $1500 in dividends is (1500\*.15) $225.

Now for the fun part, let's try to figure out if there is double taxation here.  There are, as far as I can tell, no forms, instructions, examples, models or guidance on how to do this.  There is a lot of high-level commentary.  So let's try to apply it.

First, let's figure out how much tax the Czech's levied for this income (before credit): (1500\*.1326) $199

Second, let's figure out how much tax the US levied for this income.  This is way more complicated.  Let's use form 1116 as a guide for our thinking.  The form starts by allocating a percentage of the deductions to an item of income by dividing the item by the total gross income.  For Bob, this would be $1,500 in dividend income divided by his gross income of $68,600[^4].  That means that (1500/68600) 2.18% of the deduction is allocated to this income.  That allocation is (6300\*.0218) $137.  A quick bit of subtraction shows that the taxable income before personal exemption[^5] is (1500-137) $1363.

Form 1116 continues by setting the maximum tax credit as the amount of tax multiplied by the percentage of the pre-personal exemption income the item represents.  Pre-personal exemption income is $12,300 (1040 line 41) and the total tax is $562 (1040 lines 44 and 46).  Our reduced by deductions dividends are (1363/12300) 11.08% of the total pre-personal exemption income.  Therefore the tax associated with these dividends is (562\*.1108) $62.

Therefore we are entitled to a tax credit of $62 from the Czech Republic.  Why just $62?  The US tax return does a calculation on the Schedule D worksheet clearly showing a tax of 15% on the $1,000 in qualified dividends and since the FEIE is taken first in the tax brackets our $500 in normal dividends is clearly calculated using at least a 15% rate.  None of that matters.  You can only take a credit for taxes actually paid.  Bob paid $62 therefore his credit is limited.

Ok, but that leaves Bob with (199-62) $137 in tax paid to the Czech Republic.  He should be able to take a credit for that, right?  Nope, not so fast.  Don't forget that the US is entitled to tax at up to a 15% rate.  The total tax charged by the Czech Republic is less than that 15%.  So no US tax credit.

# Foreign Tax Credit vs Foreign Tax Deduction

This whole article has been written assuming that Bob will take a Foreign Tax Credit.  Bob could have instead chosen to take a deduction on Schedule A for the taxes paid.  Because Bob does not use Schedule A to itemize his deductions, he would need to have paid foreign tax in excess of his standard deduction before it would be a good idea to even consider deducting the taxes by itemizing.  In most situations it is better to take a credit anyway, but it isn't the only way.

# Conclusion and Open Questions

[The final tax return](/img/2017/tax/treaty1.pdf)

When this adventure started, Bob potentially owed over $16,000 in combined US and Czech taxes.  By carefully working through the FEIE and FTCs, we were able to find Bob a $62 tax credit to use on his Czech taxes.  We also excluded income and took tax credits to turn a $8,840 US tax bill into $268.

There are lots of open questions, some of which like #5 could have a huge impact on this tax return.

1. Should Bob be checking the box on form 1116 indicating the income is from a 1099 when doing the re-sourcing??
2. Can both the interest and the gains be reported on the same 1116 when doing the re-sourcing?
3. Do we really not need to file any 8833s?
4. Why aren't the excess taxes paid on the re-sourced amounts considered for carryover?
5. Should the FTC for the gains have been calculated differently?  The Czech tax system does not tax gains on assets held for more than 3 years[^3].  These gains are not even listed on the tax form.  One way to think about this is that those gains are taxed at 0%.  Using that logic, you could put all $16,000 in gains on form 1116 which would result in a credit that eliminates all tax due.  See [this tax return](/img/2017/tax/treaty1a.pdf) for details.
6. How would you handle a situation where dividend income needed to be re-sourced?  For example, if the tax imposed on $1,500 in gains had been $300, how do you get a tax credit for the $75 in excess taxes paid?  I don't see a way to do this on 1116 and I can't think of a way to re-source only part of the income.
7. How do you handle the $62 Czech tax credit?  Do you recalculate the Czech tax and total income ignoring the dividends entirely?  That should prevent this from becoming circular math.

Unrelated, I have no idea why IRS writes "resource" sometimes and "re-source" other times.  I've just tried to be consistent within a section.

If you've made it this far, please let me know.  If you find errors, please let me know.  If you know the answers to these questions or have other questions that should be being considered, let me know.

[^0]: Bob's foreign tax is based loosely on the tax system of the Czech Republic.  For this purpose, there is a 15% flat tax on all income.  Capital Gains on assets held more than three years are not taxed.  There is also a tax credit offered, essentially in lieu of a standard deduction, of $1000.  This explained in the re-sourcing section.

[^1]: I've actually found IRS to be a very helpful agency.  I also believe that there forms and manuals are mostly very understandable, especially for commonly used items.  I have noticed that IRS tends to fall down on the edge cases.  It also doesn't help that their funding has been reduced causing them to have to stop providing as much support for complex questions.

[^2]: You knew it was going to be the Czech Republic.

[^3]: If the total amount of gain is less than 100,000 CZK the gain is also tax exempt.

[^4]: Yep, gross income includes the excluded income here.  Weird.  I can't think of a reason why at this time.

[^5]: Nope, I don't know why the personal exemption is ignored here either.
