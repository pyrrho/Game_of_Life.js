# Okay, what the hell is this pseudo regex? Ruby, you have regex's
# built in. Come on!
# Anway. These are all the files to bundle together.
$coffee_files = Dir.glob('src/*.coffee').join(' ')

def brew(csf)
    puts "Detected change in #{csf} at #{Time.now}"
    puts "Running coffee -o coffee/ -j -c #{$coffee_files}"
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -j GoL.coffee.js #{$coffee_files}")
    puts
end

def sass(ssf)
    puts "Sassing up some CSS from #{ssf} to #{ssf.sub(".scss", ".css").sub("sass/","css/")}"
    out = system("sass #{ssf} #{ssf.sub(".scss", ".css").sub("sass/", "css/")}")
    puts out
    puts
end
    

watch(/src\/.*\.coffee/) { |md| brew md[0] }
watch(/sass\/.*\.scss/) { |md| sass md[0]}