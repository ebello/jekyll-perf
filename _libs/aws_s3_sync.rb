# http://jmlacroix.com/archives/cloudfront-publishing.html

local   = ARGV[0]
s3_dest = ARGV[1]

if local == nil || s3_dest == nil 
  puts "syntax aws_s3_sync.rb local_source s3_dest"
  exit
end

# invalidate = "#{Dir.pwd}/aws_cf_invalidate.rb"
# if !File.exists?(invalidate)
#   puts "please download the aws_cf_invalidate.rb script"
#   exit
# end

s3_dest   = s3_dest.split('/')
s3_bucket = s3_dest.shift
s3_path   = s3_dest.join('/')

s3_path += '/' unless s3_dest.length == 0

# add far future expires and gzip headers for all .js and .css files
# cache-control private headers are added to get around proxy issues. AWS won't be serving non-gzipped versions so the Vary header doesn't apply. More info: http://code.google.com/speed/page-speed/docs/caching.html#LeverageProxyCaching
%x[ $(which s3cmd) sync #{local} s3://#{s3_bucket}/#{s3_path} --exclude '*' --rinclude '.css$|.js$' --acl-public --add-header "Expires: Tue, 19 Jan 2038 03:14:07 GMT" --add-header "Content-Encoding: gzip" --add-header "Cache-Control: private" ]

# add far future expires header for all images
%x[ $(which s3cmd) sync #{local} s3://#{s3_bucket}/#{s3_path} --exclude '*' --rinclude '.ico$|.jpg$|.png$|.gif$' --acl-public --add-header "Expires: Tue, 19 Jan 2038 03:14:07 GMT" ]

# add gzip headers for all html files
%x[ $(which s3cmd) sync #{local} s3://#{s3_bucket}/#{s3_path} --exclude '*' --rinclude '.html$' --acl-public --add-header "Content-Encoding: gzip" ]

# upload anything else
%x[ $(which s3cmd) sync #{local} s3://#{s3_bucket}/#{s3_path} --rexclude '.html$|.css$|.js$|.ico$|.jpg$|.png$|.gif$' --acl-public ]

# delete files that were removed
%x[ $(which s3cmd) sync #{local} s3://#{s3_bucket}/#{s3_path} --delete-removed ]

# invalidate all files on CDN
# files = %x[ cd _site && find . -type f ].split("\n").map do |f| 
#   s3_path + f[2,f.length]
# end
# 
# %x[ ruby #{invalidate} #{files.join(' ')} ]