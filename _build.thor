# ==== Installation
# 
#   1. bundle install --gemfile=_Gemfile (if bundler isn't installed: gem install bundler)
#   2. Download Google Closure jar: 
#      http://closure-compiler.googlecode.com/files/compiler-latest.zip
#   3. Download htmlcompressor jar, place in same directory as Closure jar.
#      http://code.google.com/p/htmlcompressor/
#   4. Install optipng for optimizing PNGs (brew install optipng)
#   5. Install s3cmd to upload to Amazon S3 (brew install s3cmd, s3cmd --configure)
#
# ==== Configuration
#
#   - change constants in Deploy class as appropriate for Amazon bucket name and server IP
#   - if not using external directory, blank out EXTERNAL_DIR constant under Build class
#
# ==== Usage
#
#   Development mode, continually regenerates html and CSS:
#     thor dev
#
#   Build and serve on local machine:
#     thor build
#
#   Build and deploy to production:
#     thor deploy
#
#   Specify SSH login:
#     thor deploy -l=[SSH USER]
#
#   Specify different location for Google Closure:
#     thor build --compiler=[COMPILER LOCATION]
#
#   Specify different location for htmlcompressor:
#     thor build --compressor=[COMPRESSOR LOCATION]
#
#   List all tasks: 
#     thor list
#   
#   Show help for one task: 
#     thor help [TASK]
#

class Deploy < Thor
  CDN_URL = "" # include full domain (http://domain.net) without trailing slash
  BUCKET = ""
  SERVER_PROD = ""
  SERVER_STAGING = ""
  WEB_DIR = ""
  class_option :ssh_user, :aliases => '-l'
  
  default_task :production
  
  desc "amazon BUCKET", "deploys site to specified amazon bucket"
  def amazon(bucket)
    puts "Publishing site to bucket #{bucket}"
    system "ruby #{Build.libs_dir}aws_s3_sync.rb #{Build.build_dir} #{bucket}"
  end
  
  desc "server SERVER", "deploys site to specified server"
  def server(server)
    puts "Publishing site to server #{server}"
    # rsync -v = verbose, -z = compress, -r = recurse, -c = use checksums to check for new files, -t = preserve modification times, -O = omit directory times
    if options.ssh_user?
      system "rsync -vzrctO --delete -e ssh #{Build.build_dir} #{options[:ssh_user]}@#{server}:#{WEB_DIR}"
    else
      system "rsync -vzrctO --delete -e ssh #{Build.build_dir} #{server}:#{WEB_DIR}"
    end
  end
  
  desc "site CDN BUCKET SERVER", "builds, prepares, and deploys site to specified bucket and server"
  def site(cdn = "", bucket = "", server = "")
    invoke "build:production", [cdn]
    unless bucket.empty?
      invoke "build:gzip", [] # gzip here only for amazon's sake
      invoke :amazon, [bucket]
    end
    unless server.empty?
      invoke :server, [server]
      
      # specify additional tasks here to upload items to server from external folder
    end
  end
  
  desc "production", "builds, prepares, and deploys site to production environment"
  def production
    invoke :site, [CDN_URL, BUCKET, SERVER_PROD]
  end
  
  desc "staging", "builds, prepares, and deploys site to staging environment"
  def staging
    # invoke :site, [CDN_URL_STAGING, BUCKET_STAGING, SERVER_STAGING] 
  end
end

class Dev < Thor
  default_task :dev
  
  desc "dev", "starts local server and continuously regenerates html and css"
  method_option :port, :aliases => "-p", :default => 3000
  def dev
    procfile = "_Procfile"
    File.open(procfile, "w") {|file|
      file.puts "compass: compass watch --sass-dir #{Build.sass_dir} --css-dir #{Build.css_dir} -e development -s expanded"
      file.puts "jekyll: jekyll #{Build.build_dir} --auto"
      file.puts "server: thin start -R #{Build.libs_dir}thin.ru -p #{options[:port]}"
    }
    system "foreman start -f #{procfile}"
  end
end

class Build < Thor  
  BUILD_DIR = "_site/"
  LIBS_DIR = "_libs/"
  SASS_DIR = "styles"
  CSS_DIR = "css"
  # anything in the external directory will not be uploaded when publishing. Before upload, it will be moved from the build_dir to a level up and prepended with _
  EXTERNAL_DIR = "external/"
  class_option :compiler, :default => "~/Library/Google/compiler-latest/compiler.jar"
  class_option :compressor, :default => "~/Library/Google/compiler-latest/htmlcompressor-1.5.2.jar"
  
  default_task :server
  
  def self.build_dir
    BUILD_DIR
  end
  
  def self.libs_dir
    LIBS_DIR
  end
  
  def self.sass_dir
    SASS_DIR
  end
  
  def self.css_dir
    CSS_DIR
  end
  
  def self.processed_external_dir
    "_#{EXTERNAL_DIR}"
  end
  
  desc "optimize_images", "optimize all PNGs"
  def optimize_images
    system "ruby #{LIBS_DIR}optimize_images.rb #{BUILD_DIR}"
  end
  
  desc "clean", "cleans build directory and external directory, if provided", :hide => true
  # method_option :external_dir
  def clean
    puts "cleaning build dir #{BUILD_DIR}"
    system "rm -rf #{BUILD_DIR}*"
    unless EXTERNAL_DIR.empty?
      puts "cleaning external dir _#{EXTERNAL_DIR}"
      system "rm -rf _#{EXTERNAL_DIR}"
    end
  end
  
  desc "jekyll", "builds static site", :hide => true
  def jekyll
    invoke :clean
    puts "building static site with jekyll"
    system "jekyll #{BUILD_DIR} --no-future"
  end
  
  desc "compass", "compile css with compass", :hide => true
  # method_option :sass_dir, :default => "styles", :required => true
  def compass(environment = "development", output_style = "expanded")
    puts "compiling css with compass"
    system "compass compile --sass-dir #{SASS_DIR} --css-dir #{BUILD_DIR}#{SASS_DIR} -e #{environment} -s #{output_style}"
  end
  
  desc "javascript_compile", "uses Google Compiler to optimize javascript", :hide => true
  def javascript_compile
    puts "optimizing JavaScript with Google Compiler"
    system "ruby #{LIBS_DIR}javascript_compile.rb #{BUILD_DIR} #{options[:compiler]}"
  end
  
  desc "version_static_content", "version and replace static content", :hide => true
  def version_static_content(cdn = "")
    puts "versioning static content"
    system "ruby #{LIBS_DIR}version_static_content.rb #{BUILD_DIR} #{cdn}"
  end
  
  desc "add_base_path", "adds a base path to all files referenced by links or elsewhere", :hide => true
  def add_base_path
    path = BUILD_DIR
    # return everything after first occurance of /
    path = path.slice(path.index('/')..-1)
    # remove trailing /
    path.chop! if path.end_with?('/')
    unless path.empty?
      puts "adding a base path to all files"
      system "ruby #{LIBS_DIR}add_base_path.rb #{BUILD_DIR} #{path}"
    end
  end
  
  desc "html_compress", "minifies all html", :hide => true
  def html_compress
    puts "minifying all html"
    system "ruby #{LIBS_DIR}html_compress.rb #{BUILD_DIR} #{options[:compressor]}"
  end
  
  desc "move_external", "this will move the external folder, if specified, out of the build directory", :hide => true
  def move_external
    unless EXTERNAL_DIR.empty?
      puts "moving all external files out of main site"
      system "mv #{BUILD_DIR}#{EXTERNAL_DIR} _#{EXTERNAL_DIR}"
    end
  end
  
  desc "gzip", "pre-compresses content", :hide => true
  def gzip
    puts "gzipping content"
    system "ruby #{LIBS_DIR}gzip_content.rb #{BUILD_DIR}"
  end
  
  desc "testing", "builds and prepares site for a testing environment"
  def testing
    invoke :compass
    invoke :jekyll
    invoke :javascript_compile
    invoke :version_static_content
    invoke :add_base_path
    invoke :html_compress
    invoke :move_external
  end
  
  desc "server", "builds, prepares, and hosts site locally using thin"
  method_option :port, :aliases => "-p", :default => 3000
  def server
    invoke :testing
    system "thin start -R #{LIBS_DIR}thin.ru -p #{options[:port]}"
  end
  
  # thor 0.14.6 has a bug that forces args to be defined for invoked tasks if the main task accepts an argument that isn't optional.
  # for example, if you remove the [] for `invoke :jekyll, []`, you'll receive an error that the jekyll task was called incorrectly.
  desc "production", "builds and prepares site for a production environment"
  def production(cdn)
    invoke :compass, ["production", "compressed"]
    invoke :jekyll, []
    invoke :javascript_compile, []
    invoke :version_static_content, [cdn]
    invoke :add_base_path, []
    invoke :html_compress, []
    invoke :move_external, []
  end
end