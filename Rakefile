task :build do
	print "Building Sass files..."
	`bundle exec sass --cache-location tmp/cache/sass --update src/css:dist/css -t compressed -f`
	puts " [Done]"
  print "Building CoffeeScript files..."
	`bundle exec coffee -c -b -o dist/js src/js`
	puts " [Done]"
end

task :watch do
  Process.fork do
    # In child
   exec("bundle exec sass --scss --watch src/css:dist/css --cache-location tmp/cache/sass")
  end
  
  Process.fork do
    exec("bundle exec coffee -w -b -c -o dist/js src/js")
  end
  Process.waitall
end
