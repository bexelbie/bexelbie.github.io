---
date: 2025-07-25 10:25:00 +0200
title: "Email was a bad idea, or: How I Learned to Love DNS records"
excerpt: ""
tags:
  - Coding
categories:
  - Technology
---

Recently I tried to move a mailing list subscription to a new email address on a different provider.  I never got a subscription verification email.  It turns out my new mail provider is more strict than my old one.  As a result, I’ve had the “opportunity” learn way more about SPF, DKIM, DMARC, ARC, and even some lions, tigers, and bears (oh my!) than I ever wanted to.  This is a roundup of what I’ve learned.

## Who is this email even from?

Before diving into all the acronyms, you need to understand that email has two different ‘froms’.

One ‘from,’ the FROM Header, is set by the sender in their email client and not validated by SPF.  This is the name and email address displayed to the user reading the email.  This is what you see in your email client.

The second ‘from’ is the ENVELOPE FROM or RETURN-PATH Header.  This is the information the receiving mail server gets in the `MAIL FROM` command sent by the sending mail server.  The RETURN-PATH header is written by the receiving mail server and is visible in your mail client when you show all headers.  Often, the receiving mail server preserves any old RETURN-PATHs as well, so you may see those too.

## SPF (Sender Policy Framework)

Now that we know who an email claims to be from, SPF helps us check whether it’s allowed to send on behalf of that domain. SPF records let receiving systems verify that the sender is authorized to send mail on behalf of a domain. This domain may or may not match the domain you see in your email client. The SPF record is a list of IP addresses, hostnames, and similar data that specifies where mail for a domain should originate.  Via a policy statement in the record, the sender can provide advice on what recipients should do if they get email from anywhere not listed.  Specifically suggest a policy: reject it, quarantine it, or simply do whatever you want with it.  These records are set by the sender in their domain’s DNS.  For my own email domain, bexelbie.com (don’t ask why it isn’t winglemeyer.org), I have SPF records for iCloud, Cloudflare, and Google, as any of those may originate email.

### What should you do?

- If you’re an email user: Use your mail provider’s sending host (SMTP) to ensure  a valid SPF check when the receiver gets your email.
- If you’re a provider: If at all possible, put together an exhaustive list of hosts your server uses and keep it up to date. 
- If you’re a mailing list provider: Set up SPF for your list domain so administrative messages pass. If you’re providing the  Envelope From (and you should be), you’ll also need the SPF record for that. If your top-level domain can’t do SPF for some reason, at least use SPF on your list subdomain. 

## DKIM (DomainKeys Identified Mail)

While SPF verifies who sent the email, DKIM helps us know if this email has been altered by a third-party. DKIM is a signature, think cryptography, that signs headers selected by the sender and the email body.  This lets recipients verify the email wasn’t altered in transit.  For DMARC alignment purposes (see below), the FROM header must be signed.

DKIM’s signature is verifiable via a public key in the domain’s DNS entry, which allows a receiver to verify both the email’s validity and if it was actually sent by the domain in question.  This is typically added by the outbound mail server before it gets to the receiver.

### What should you do?

- If you’re an email user: Other than holding your provider accountable, there is nothing you can do. 
- If you’re a provider: Use DKIM for your users. 
- If you’re a mailing list provider: Set up DKIM on your own messages and sign outgoing list email. It’s good practice, especially if you’re modifying the message by adding headers, footers, or even mangling existing headers.

## DMARC (Domain-based Message Authentication, Reporting, and Conformance)

DKIM and SPF can be combined to decide what to do with an email. DMARC is a policy statement about what the sender would like done with message failures.  DMARC is the policy the sending domain is recommending to receivers about what to do with email that lacks SPF and/or DKIM domain alignment, or when neither is present.  The sender can specify three options: `p=none` (meaning ignore these issues), `p=reject` (meaning throw away email that isn’t compliant), or `p=quarantine` (meaning quarantine this as possible spam).

DMARC has two sets of conditions it considers to determine if a message passes.  This is where a lot of confusion arises, as it is complicated.  DMARC passes only if at least one of the following two conditions is true:

1. The DKIM signature is valid AND the DKIM signing domain (from the `d=` tag in the DKIM-Signature) aligns (matches) with the FROM Header domain.
2. The SPF check passes for the ENVELOPE FROM domain AND the ENVELOPE FROM domain aligns (matches) with the FROM Header domain.

Note: DMARC HAS relaxed and strict modes.  Strict mode requires domains to align (match) exactly (e.g. bexelbie.com = bexelbie.com), while relaxed mode (the default) allows alignment (matching) to be only at the top-level (e.g. mail.winglemeyer.org = winglemeyer.org). 

### What should you do?

- If you’re an email user: Keep holding your provider accountable, because this is all on them.
- If you’re a provider: Set up a DMARC policy, ideally at least `p=quarantine` if you’re high volume. Monitor your DMARC returns. 
- If you’re a mailing list provider: Set up a DMARC policy, `p=none` is acceptable. Monitor your DMARC returns to see if quarantine makes more sense. 

## ARC (Authenticated Received Chain)

DKIM focused on attesting to the email content, ARC attests to the metadata. ARC is a set of headers that can be added by an intermediary (such as a mailing list, email forwarding service, or archiving system) to preserve SPF and DKIM alignment for DMARC.  While ARC is modeled after DKIM and includes cryptographic signatures, it signs metadata (like SPF/DKIM results) rather than the original message content.

ARC comes into play when email is forwarded. It solves the problem of legitimate intermediaries breaking SPF or DKIM when they modify the message.  These modifications are often helpful for readers and can include things like adding headers or footers, or modifying subject lines.  This allows the next receiver to trust the DKIM and SPF status reported by the intermediary when they perform their own DMARC analysis.  It also allows the receiver to consider ARC signed results when evaluating DMARC, even if local checks fail.

### What should you do?

- If you’re an email user: You’re probably your provider’s favorite customer now that you are laser focused on their accountability.
- If you’re a provider: Add ARC records if you’re forwarding mail.  
- If you’re a mailing list provider: Add ARC records as you are a mail forwarder. It’s doubly important if you’re modifying the email in any way that would break DKIM.

All of this complexity leads to one conclusion … email was a bad idea.  Additionally, it’s now almost all sent on behalf of companies or spam. The pockets of actual human to human email are shrinking. In a world like this email servers need all the help they can get to stop unwanted or fake mail. Use providers that set these headers. If you own a domain, set them too. If you’re using an external mail provider for your domain they should have guidance how to set these records up and should manage all of these headers and keys for you. It isn’t hard and it is necessary if you want your emails to be delivered. 

*Thanks to [Patrick Uiterwijk](https://puiterwijk.org) for reviewing an earlier draft of this post. Any mistakes that remain are probably mine, but feel free to blame DNS.*