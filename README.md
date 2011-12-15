# Game\_Of\_Life.js #
How do I teach myself HTML5, CSS3 and Javascript?  
Yeah. This is how.

-----

### Introduction ###
This is my implementation of John Conway's [Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life). It is the first project I've embarked on using HTML5, [Sass](http://sass-lang.com/) and [CoffeScript](http://coffeescript.org/) for building a web-site (I guess it's more of a web-app?) front-end.

### Credits & How I done it ###
To start, [HTML5](http://www.quackit.com/html_5/tags/), [CSS3](http://www.w3schools.com/cssref/default.asp), and [Javascript](http://www.ecmascript.org/). In truth, I didn't much use the ECMAScript standard to figure out JavaScript. Rather, I found [Douglas Crockford's](http://yuiblog.com/crockford/) video lectures on JavaScript to be a wonderful resource.

After building a proficiency with those lectures, a _lot_ of playing around, and this wonderful [JavaScript-gotchas garden](http://bonsaiden.github.com/JavaScript-Garden/), I actually abandoned JavaScript in favor of [CoffeeScript](http://coffeescript.org/). If you have any opinion on JavaScript&mdash;positive or negative&mdash;go check out CoffeeScript. I recommend starting with [The Little Book on CoffeeScript](http://arcturo.github.com/library/coffeescript/).

Similarly, after spending a great deal of time wrestling with CSS (Seriously? **Still** [no variables](http://s3.amazonaws.com/kym-assets/photos/images/original/000/000/578/1234931504682.jpg)?!), I gave up on that outmoded beast in favor of [Sass](http://sass-lang.com/). The compilation step there takes a bit longer than I'd really like, but for variables, mix-ins and a bunch of super-handy functions, I'll take it, hands down.

On the topic of compilation, I found a simple script written to accommodate the [Watchr](https://github.com/mynyml/watchr) package to greatly improve my workflow. Automatic compilation, for the win.

In the actual production of this Game_Of_Life.js, I first have to attribute [JQuery](http://jquery.com/) for... well, for being JQuery. I mean... There are alternatives, but it's JQuery, so.  
[JQuery UI](http://jqueryui.com/) was used in the creation of the control pane. I'm still not sure how much I like the way that turned out.  
As a bonus to JQuery, I took advantage of a few of the amazingly cool helper functions offered by [Underscore.js](http://documentcloud.github.com/underscore/). It's not actually that much like JQuery, but the authors are billing it as "the tie to JQuery's tux," or something like that.

For the vector images that make up the canvas that represents the simulated Game of Life, I used [Raphael.js](http://raphaeljs.com/). There were a few quirks I ran into with this library, but they all boiled down to me not fully understanding SVGs, rather than Raphael not acting properly. So nuts to SVGs, really, but Raphael is a really smooth library.

Finally I have to give a big credit to [Xueqiao Xu](https://github.com/qiao/) and his excellent [PathFinding.js](https://github.com/qiao/PathFinding.js) library, which acted as a fantastic starting point for me. I've since moved a pretty good distance away from his work, but still. Good stuff.


### License ###

This project is released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).