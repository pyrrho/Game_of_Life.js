$coffee_src_dir = 'src/coffee/'
$sass_src_dir = 'src/sass/'

$coffee_out_dir = 'dev/js/'
$sass_out_dir = 'dev/css/'

# These are all the coffee files to be watched and bundle together.
$coffee_file_list = Dir.glob("#{$coffee_src_dir}*.coffee")
$coffee_files = $coffee_file_list.join(' ')

# These are all the sass files to be watched and compiled
$sass_file_list = Dir.glob("#{$sass_src_dir}*.scss")

puts "Watching the following coffee files:"
puts "#{$coffee_file_list}"
puts
puts "Watching the following scss files:"
puts "#{$sass_file_list}"
puts

def brew(csf)
    puts "Detected change in #{csf} at #{Time.now}"
    puts "coffee -o #{$coffee_out_dir} -j GoL.coffee.js #{$coffee_files}"
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o #{$coffee_out_dir} -j GoL.coffee.js #{$coffee_files}")
    puts out
    puts
end

def sass(ssf)
    puts "Detected change in #{ssf} at #{Time.now}"
    css_path = ssf.sub(".scss", ".css").sub($sass_src_dir, $sass_out_dir)
    puts "sass #{ssf} #{css_path}"
    out = system("sass #{ssf} #{css_path}")
    puts out
    puts
end


watch(/src\/coffee\/.*\.coffee/) { |md| brew md[0] }
watch(/src\/sass\/.*\.scss/) { |md| sass md[0] }

puts "Watchr script is active. Code away."
puts