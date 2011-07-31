# http://jmlacroix.com/archives/cloudfront-publishing.html

# requires:
# - jekyll (gem install jekyll)
# - compass (gem install compass)
# - google closure http://closure-compiler.googlecode.com/files/compiler-latest.zip
# - thin (gem install thin)
# - optipng (brew install optipng)
# - s3cmd (brew install s3cmd, s3cmd --configure)
# - htmlcompressor http://code.google.com/p/htmlcompressor/
# - for building pages with JSON: gem install json

build_dir = '_site/'
cdn = ''
bucket = ''
sass_dir = "styles"
COMPILER_JAR = "~/Library/Google/compiler-latest/compiler.jar"
COMPRESSOR_JAR = "~/Library/Google/compiler-latest/htmlcompressor-1.4.jar"
libs_dir = "_libs/"
# anything in the external directory will not be uploaded when publishing. Before upload, it will be moved from the build_dir to a level up and prepended with _
external_dir = "external/"

task :default => :server

desc 'optimize all PNGs and JPGs'
task :optimize_images do
  system "ruby #{libs_dir}optimize_images.rb #{build_dir}"
end

desc 'Delete generated _site files'
task :clean do
  system "rm -rf #{build_dir}*"
  unless external_dir.empty?
    system "rm -rf _#{external_dir}"
  end
end

desc 'Start server with --auto'
task :server => ['build:testing'] do
  system "thin start -R #{libs_dir}thin.ru"
end

desc 'Build site with Jekyll'
namespace 'build' do
  
  task :jekyll => [:clean] do
    jekyll('--no-future')
  end
  
  desc 'compile css'
  task :compass, [:environment, :output_style] do |t, args|
    args.with_defaults(:environment => "development", :output_style => "expanded")
    system "compass compile --sass-dir #{sass_dir} --css-dir #{build_dir}#{sass_dir} -e #{args.environment} -s #{args.output_style}"
  end
  
  desc 'uses Google Compiler to optimize javascript'
  task :javascript_compile do
    system "ruby #{libs_dir}javascript_compile.rb #{build_dir} #{COMPILER_JAR}"
  end
  
  desc 'version and replace static content'
  task :version_static_content, :cdn do |t, args|
    system "ruby #{libs_dir}version_static_content.rb #{build_dir} #{args.cdn}"
  end
  
  desc 'compress all html'
  task :html_compress do
    system "ruby #{libs_dir}html_compress.rb #{build_dir} #{COMPRESSOR_JAR}"
  end
  
  desc 'this will move the external folder, if specified, out of the build directory'
  task :move_external do
    unless external_dir.empty?
      system "mv #{build_dir}#{external_dir} _#{external_dir}"
    end
  end
  
  task :testing => [:jekyll, :compass, :javascript_compile, :version_static_content, :html_compress, :move_external]
  
  # production build should gzip content and add the CDN
  task :production => [:jekyll] do
    Rake::Task['build:compass'].invoke('production', 'compressed')
    Rake::Task['build:javascript_compile'].invoke
    Rake::Task['build:version_static_content'].invoke(cdn)
    Rake::Task['build:html_compress'].invoke
    system "ruby #{libs_dir}gzip_content.rb #{build_dir}"
    Rake::Task['build:move_external'].invoke
  end
  
end

desc 'Build and deploy'
task :publish => 'build:production' do
  puts "Publishing site to bucket #{bucket}"
  system "ruby #{libs_dir}aws_s3_sync.rb #{build_dir} #{bucket}"
  
  # specify additional tasks here to upload items in external folder
end

def jekyll(opts = '')
  system 'jekyll ' + opts
end