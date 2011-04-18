map "/" do
  run Rack::Directory.new('./_site')
end