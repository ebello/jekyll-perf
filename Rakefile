# http://jmlacroix.com/archives/cloudfront-publishing.html

# requires:
# - jekyll (gem install jekyll)
# - compass (gem install compass)
# - google closure http://closure-compiler.googlecode.com/files/compiler-latest.zip
# - thin (gem install thin)
# - optipng (brew install optipng)

build_dir = '_site/'
# cdn = 'http://cdn.westoverfinearts.com'
cdn = ''
# bucket = 'www.westoverfinearts.com'
bucket = 'site-testing'
sass_dir = "styles"
COMPILER_JAR = "~/Library/Google/compiler-latest/compiler.jar"
libs_dir = "_libs/"

task :default => :server

desc 'optimize all PNGs and JPGs'
task :optimize_images do
  system "ruby #{libs_dir}optimize_images.rb #{build_dir}"
end

desc 'Delete generated _site files'
task :clean do
  system "rm -rf #{build_dir}*"
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
  
  task :testing => [:jekyll, :compass, :javascript_compile, :version_static_content]
  
  # production build should gzip content and add the CDN
  task :production => [:jekyll] do
    Rake::Task['build:compass'].invoke('production', 'compressed')
    Rake::Task['build:javascript_compile'].invoke
    Rake::Task['build:version_static_content'].invoke(cdn)
    system "ruby #{libs_dir}gzip_content.rb #{build_dir}"
  end
  
end

desc 'Build and deploy'
task :publish => 'build:production' do
  puts "Publishing site to bucket #{bucket}"
  system "ruby #{libs_dir}aws_s3_sync.rb #{build_dir} #{bucket}"
end

def jekyll(opts = '')
  system 'jekyll ' + opts
end