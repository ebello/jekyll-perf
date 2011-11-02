map "/" do
  Rack::Mime::MIME_TYPES.merge!({
    ".appcache" => "text/cache-manifest"
  })
  run Rack::Directory.new('./_site')
end