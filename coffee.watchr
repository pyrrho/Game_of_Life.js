def brew(file)
    puts "Running coffee -o coffee/ -c #{file}"
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -c #{file}")
    puts out
end

watch(/src\/.*\.coffee/) {|md| brew md[0]}