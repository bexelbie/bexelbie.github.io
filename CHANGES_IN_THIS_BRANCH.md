# How to use this branch

## Upgrading

ack

## Recommended usage testing with the official Jekyll Docker Container

    $ docker run -e BUNDLE_CACHE=1 --rm --label=jekyll --volume=$(pwd):/srv/jekyll -it -p $(boot2docker ip):4000:4000 jekyll/jekyll jekyll s --force_polling

  Note: `sudo` may be needed depending on your setup


## If you are not using the official Jekyll Docker Container

If you are not using the official jekyll docker container, it is probably safe to delete the following from Gemfile

    jekyll-watch

You can also delete the following from the .gitignore

    vendor
    .bundle

# Changes in this Branch

## The following PRs have been merged into this branch, prior to their merge by upstream

* Fix missing semi-colon: https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/62
* Add LinkedIn Icon: https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/67
* Add Email Icon: https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/77
* Separate Copyright from Site Title: https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/79
* Update for Jekyll-3.0 and move to jekyll-feed: https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/80

## Change Log

Sat Jan  9 15:46:39 CET 2016:

  * Merged upstream PRs ahead of upstream
    * PR 62 merged
    * PR 67 merged
    * PR 77 merged
    * PR 79 merged
    * PR 80 merged
  * Added Gemfile and updated .gitignore for use with the Jekyll Docker Container
  * Deleted sample data that is unneeded when doing a theme upgrade
    * _posts/2014-06-10-dinosaurs.markdown
    * _posts/2014-07-01-dreams.markdown
    * _posts/2014-07-08-failure-is-not-an-option.markdown
    * _posts/2014-08-24-science-has-not-yet-mastered-prophecy.markdown
    * _posts/2014-09-18-i-believe.markdown
    * _posts/2014-09-24-man-must-explore.markdown
    * about.html
    * contact.html
    * img/about-bg.jpg
    * img/contact-bg.jpg
    * img/home-bg.jpg
    * img/post-bg-01.jpg
    * img/post-bg-02.jpg
    * img/post-bg-03.jpg
    * img/post-bg-04.jpg
    * img/post-bg-05.jpg
    * img/post-bg-06.jpg
    * img/post-sample-image.jpg
  * Fixed typo in PR 67 - LinkedIn Footer
    * https://github.com/IronSummitMedia/startbootstrap-clean-blog-jekyll/pull/67/files#r49265217
  * Re-Merged PR 80 - for updated with {% feed_meta %}
