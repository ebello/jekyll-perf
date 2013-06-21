jekyll-perf
=========

jekyll-perf is a static site generating framework that is focused on web performance and makes it easy to deploy a site to be hosted on Amazon S3.

Build your site
---------------
1. [Download](https://github.com/ebello/jekyll-perf/zipball/master) jekyll-perf
2. [Install framework dependencies](https://github.com/ebello/jekyll-perf/wiki/Installation) if you haven't before
3. [Configure options](https://github.com/ebello/jekyll-perf/wiki/Configuration)
4. Command line usage:

Development mode, continually regenerates site files
  
    thor dev
  
Build and serve on local machine

    thor build
  
Build and deploy to production

    thor deploy
  
Specify SSH login

    thor deploy -l=[SSH USER]
  
List all commands available

    thor list
  
Show help for one task

    thor help [TASK]

Dependencies
------------
* [Jekyll](https://github.com/mojombo/jekyll)
* [Compass](http://compass-style.org/)
* [Uglifier](https://github.com/lautis/uglifier)
* [Google Closure](https://developers.google.com/closure/compiler/)
* [Google htmlcompressor](http://code.google.com/p/htmlcompressor/)
* [Thin web server](http://code.macournoyer.com/thin/)
* [s3cmd](http://s3tools.org/s3cmd)
* [Thor](https://github.com/wycats/thor)
* [Foreman](https://github.com/ddollar/foreman)
* [RMagick](http://rmagick.rubyforge.org/)
