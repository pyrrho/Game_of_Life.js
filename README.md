my Game\_Of\_Life.js
=================
An implementation of John Conway's Game of Life implemented using HTML5, CSS3 and JavaScript (or CoffeScript. Haven't decided yet.)

The libraries I'm going to be using to make this are:

+ [Raphaeljs 2.0.0](raphaeljs.com/reference.html) for Vector Graphics.
+ [JQuerry](jquery.com) for... well, JQuery.

Currently I'm also looking into using:

+ [Backbone.js](documentcloud.github.com/backbone/) for an MVC backbone. Though I'm leaning away from it for the experience of writing an MVC JavaScript app from sratch.
+ [Underscore.js](documentcloud.github.com/underscore/) as either a dependency for Backbone, or just because it looks _awesome_.
+ [Modernizr](modernizer.com) for legacy support. Though I'm probably going to just be developing for Chrome. Maybe Firefox.
+ [Dr. JS](https://github.com/DmitryBaranovskiy/dr.js) (Link? Is this really all there is wrt documentation?) for documenting the JS I write up.

This entire project is probably going to be very heavily based on the excellent pathfinding libray of Xueqiao Xu, [PathFinding.js](https://github.com/qiao/PathFinding.js).


        <p>I did my best to follow web-coding "best practices." (I put "best practices" in quotations, not because I don't want my structure, style and code to be among the best out there, but because it's my experiences that these best practices are motivated by decades-old workaround, and petty squabbles.)
        <p>I did my best to keep the markup of this page sane, but it doesn't much use `article`, `section`, or other such specific tags. This kind of UI doesn't lend itself to index searches or Readability to begin with, so I figured a few extra `div` tags wouldn't hurt much.</p>
        <p>I wanted to do as much of the coloring, positioning, and user-interaction of textural elements in CSS as I could; I'm somewhat proud of the results. The slider is (unfortunately) JQuery because of some `mouseup` resolution oddities, as is the animation of the fading text. The rest is pure CSS. The hovering, selecting and transitioning of the buttons and tabs were put together in Sass (scss, specifically, because I love me some supersets) and compiled to pure CSS.</p>
        <p>The Canvas was heavily inspired by the excellent <a href="https://github.com/qiao/PathFinding.js">PathFinding.js</a> library from Xueqiao Xu. It uses a <a href="raphaeljs.com">Raphael.js</a> canvas for rendering simple vector graphics and <a href="jquery.com">JQuery</a> for properly capturing user input. The rest is a rather simple MCV program hashed together in <a href="coffeescript.org">CoffeeScript</a>.<p>
        <p>Because I'm incredibly lazy, I had to put together a <a title="Find this link!">Watchr</a> script to automate compiling both the CoffeeScript down to JavaScript, and the Sass down to CSS.</p>