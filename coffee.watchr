def brew(file)
    puts "This should run node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -c #{file}"
    # system("coffee -o /build -c #{file}")
    # system("coffee --help")
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -c #{file}")
    # out = `node C:/Users/rew/CoffeeScript/bin/coffee --help`
    puts out
end

watch(/src\/.*\.coffee/) {|md| brew md[0]}