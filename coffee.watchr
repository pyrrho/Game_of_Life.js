# Okay, what the hell is this pseudo regex? Ruby, you have regex's
# built in. Come on!
# Anway. These are all the files to bundle together.
$files = Dir.glob('src/*.coffee').join(' ')

def brew(csf)
    puts "Detected change in #{csf}"
    puts "Running coffee -o coffee/ -j -c #{$files}"
    out = system("node C:/Users/rew/CoffeeScript/bin/coffee -o coffee/ -j GoL.coffee.js #{$files}")
end

def rnm(jsf)
    puts "Renaming #{jsf} to GoL.coffee.js"
    File.rename(jsf, "GoL.coffee.js")
end
    

watch(/src\/.*\.coffee/) { |md| brew md[0] }
watch(/coffe\/.*compile\.js/) { |md| rnm md[0] }