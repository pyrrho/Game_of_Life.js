# Game\_Of\_Life.js #
How do I teach myself HTML5, CSS3 and Javascript?  
Yeah. This is how.

-----

### Introduction ###
This is my implementation of John Conway's [Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life). It is the first project I've embarked on using HTML5, [Sass](http://sass-lang.com/) and [CoffeScript](http://coffeescript.org/) for building a web-site front-end. (Actually... I guess it's more of a web-app?)

### Credits & How I Done It ###
To start; [HTML5](http://www.quackit.com/html_5/tags/), [CSS3](http://www.w3schools.com/cssref/default.asp), and [Javascript](http://www.ecmascript.org/).  
In truth, I didn't much use the ECMAScript standard to figure out JavaScript. Rather, I found [Douglas Crockford's](http://yuiblog.com/crockford/) video lectures on JavaScript to be a wonderful resource. Everyone should watch that first lecture. Really. It's not even about JavaScript.

After building a proficiency with those lectures, a _lot_ of playing around, and this wonderful [garden of JavaScript-gotchas](http://bonsaiden.github.com/JavaScript-Garden/), I abandoned JavaScript in favor of [CoffeeScript](http://coffeescript.org/). If you have any opinion on JavaScript&mdash;positive or negative&mdash;go check out CoffeeScript. I recommend starting with [The Little Book on CoffeeScript](http://arcturo.github.com/library/coffeescript/).

Similarly, after spending a great deal of time wrestling with CSS (Seriously? **Still** [no variables](http://s3.amazonaws.com/kym-assets/photos/images/original/000/000/578/1234931504682.jpg)?!), I gave up on that outmoded beast in favor of [Sass](http://sass-lang.com/). The added compilation step takes a bit longer than I'd like, but as a trade-off for variables, mix-ins and a bunch of super-handy functions, I'll take it.

On the topic of compilation, I found the [Watchr](https://github.com/mynyml/watchr) package to greatly improve my workflow.  
Automatic compilation in one simple Ruby script? Yes please.

In the actual production of this Game_Of_Life.js, I first have to attribute [JQuery](http://jquery.com/) for... well, for being JQuery. I mean, there are alternatives, but... What more is there to say? It's JQuery.

I used a few pieces from [JQuery UI](http://jqueryui.com/) in the creation of the control pane. I'm still really iffy on using JQuery UI in production code&mdash;the theme-roller just doesn't cut it for the kind of fine-grained control I'd like&mdash;but for this kind of prototype work, it was fantastically quick.

As a bonus to JQuery, I took advantage of a few of the amazingly cool helper functions offered by [Underscore.js](http://documentcloud.github.com/underscore/).

For the vector images that make up the canvas, I used [Raphael.js](http://raphaeljs.com/). There were a few quirks I ran into with this library, but they all boiled down to me not fully understanding SVGs, rather than Raphael not acting like a well-versed user would expect. So nuts to SVGs, I guess.

Because I didn't feel like bloating my stylesheet with vendor-specific prefixes (I mean, I had all of one vendor-specific rule... ¬_¬), I decided to play around with Lea Verou's [Prefix-Free](http://leaverou.github.com/prefixfree/). It got rid of a headache I didn't even have!

Finally I have to give major thanks to [Xueqiao Xu](https://github.com/qiao/) and his excellent [PathFinding.js](https://github.com/qiao/PathFinding.js) library which acted as a fantastic starting point for me. I've since moved a pretty good distance away from his work, but still. Good stuff.

-----

### License ###

This project is released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

-----

#### To Dos ####

 * Implement & test on Firefox, Opera, Safari.... IE?
 * Add `Turn off Animations` check box