task :build do
	print "Building Sass files..."
	`bundle exec sass --cache-location tmp/cache/sass --update src/css:dist/css -t compressed -f`
	puts " [Done]"
  print "Building CoffeeScript files..."
	`bundle exec coffee -c -b -o dist/js src/js`
	puts " [Done]"
end

task :watch do
	 print "Starting watching."
   Thread.new do
     # In child
    `bundle exec sass --scss --watch src/css:dist/css --cache-location tmp/cache/sass`
   end
   print "."
   
   Thread.new do
     # In child
     `bundle exec coffee -w -b -c -o dist/js src/js`
   end
	 print "."
end
