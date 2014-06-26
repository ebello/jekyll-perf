jekyll-perf
===========

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

Installing dependencies 
-----------------------
1. Create file '.ruby-version' in root directory, paste in ruby version 
(Currently ruby-2.0.0-p247)

2. Create file '.ruby-gemset' in root directory. Enter name of desired gemset.

3. 'cd' into the root directory to create gemset

4. Run 'bundle install --gemfile=_Gemfile' to install the gems 


Features
--------
### Development mode
CSS compression and JS compilation don't happen in dev mode in order to more easily debug

### Content blocks
Jekyll layouts only have one area where you can place content. If you've ever wanted to place content in multiple places, use the new [Liquid tag](https://github.com/rustygeldmacher/jekyll-contentblocks#usage) available in the contentblocks gem.

### Static asset versioning
All images, videos, CSS, and JS files are renamed based on the contents of their files. That means the browser can be told to cache these assets indefinitely. If there are changes to the assets a new filename will be used.

### Dependency management for JavaScript
Sass has partials in order to keep files neatly organized and separated for development and to allow upon compilation to join them all together into one CSS file for performance. The same can be done for JavaScript using the dependency management system provided by Sprockets and included in the jekyll-assets gem. See the [documentation](https://github.com/ixti/jekyll-assets#the-directive-processor) for more information.

### Compression and minification for CSS, JS, and HTML
CSS is compressed using the Sass engine. JavaScript is compiled with Uglifier, and HTML is minified down to one line in order to avoid unnecessary spaces and line breaks. All this means files get smaller so your site gets faster.

### Deployment for staging and production environments
Separate environments are already set up in the `_build.thor` file allowing you to deploy updates to either place by running `thor deploy:staging` or `thor deploy:production`.

### Low resolution image creation
If you want to support high resolution displays, place images at twice the size in a 2x folder, run `thor build:resize_2x_images` and low resolution images will be created automatically.

### Image optimization (PNG and JPEG)
Reduce the size of your images safely by running `thor build:optimize_images`.

### Automatic sprite generation
Create sprites that are perfect to use with Sass functions: vertically oriented with a fixed grid. All images are left and top aligned in the grid. See the `_build.thor` file for how to configure.

### Jekyll pages built with JSON
Having the data for a page in JSON format means you can build static HTML and have dynamic functionality using JavaScript, all while having one central place for the data.

### Liquid tag to extract information from JSON files
Reference data in other JSON pages by using the `json` Liquid tag. See the documentation in _plugins/json_tag.rb for usage.

### Dynamic site navigation
Primary and secondary navigation can be generated automatically based on YAML metadata on the page. Use `primarynavorder` or `navorder` to specify placement of page within the navigation. See the default layout for an example of how to generate the navigation.

### Amazon S3 deployment
If you're hosting your site on Amazon S3, all the appropriate headers for caching and gzip support in order to get the best performance are taken care of.

### Building With Vagrant
1. install [vagrant](http://www.vagrantup.com/) (tested with 1.6.3)
2. edit `Vagrantfile` and set the ports to unused ones on the host machine
  * currently 3000 (jekyll-perf default) and 4000 (jekyll default) are mapped to 3001 and 4001 respectively
  * `config.vm.network "forwarded_port", guest: 3000, host: 3001`
  * `config.vm.network "forwarded_port", guest: 4000, host: 4001`
3. start VM, (will download base virtual machine, if necessary): `vagrant up`
4. connect to VM via SSH: `vagrant ssh`
5. change to vagrant path which maps back to folder on host: `cd /vagrant`
6. run normal jekyll-perf commands, like: `thor build`
7. open up browser and point to http://localhost:3001/ (or the corresponding port you set above)


Dependencies
------------
* [Jekyll](https://github.com/mojombo/jekyll)
* [Compass](http://compass-style.org/)
* [Uglifier](https://github.com/lautis/uglifier)
* [Google Closure](https://developers.google.com/closure/compiler/)
* [Google htmlcompressor](http://code.google.com/p/htmlcompressor/)
* [s3cmd](http://s3tools.org/s3cmd)
* [Thor](https://github.com/wycats/thor)
* [RMagick](http://rmagick.rubyforge.org/)
* [jekyll-assets](https://github.com/ixti/jekyll-assets)
* [jekyll-contentblocks](https://github.com/rustygeldmacher/jekyll-contentblocks)
