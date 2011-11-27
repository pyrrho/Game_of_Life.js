# These are all the coffee files to be watched and bundle together.
$coffee_files_list = Dir.glob('src/*.coffee')
$coffee_files = $coffee_files_list.join(' ')

# These are all the sass files to be watched and compiled
$sass_files = Dir.glob('sass/*.scss')

puts "Watching the following coffee files:"
puts "#{$coffee_files_list}"
puts
puts "Watching the following scss files:"
puts "#{$sass_files}"
puts
puts "Watchr script is active. Code away."
puts

def brew(csf)
    puts "Detected change in #{csf} at #{Time.now}"
    puts "Running coffee -o coffee/ -j -c #{$coffee_files}"
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -j GoL.coffee.js #{$coffee_files}")
    puts out
    puts
end

def sass(ssf)
    puts "Detected change in #{ssf} at #{Time.now}"
    css_path = ssf.sub(".scss", ".css").sub("sass/","css/")
    puts "Sassing it to #{css_path}"
    out = system("sass #{ssf} #{css_path}")
    puts out
    puts
end
    

watch(/src\/.*\.coffee/) { |md| brew md[0] }
watch(/sass\/.*\.scss/) { |md| sass md[0] }