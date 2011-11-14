GoL = (canvas_element, width, height) ->
    #############################
    ## 'Global' vars            #
    #############################
    state_set =
        empty:
            "fill": "white"
            "stroke-opacity": .2
        alive:
            "fill": "#1A301A"
            "stroke-opacity": .2


    #############################
    ## Object declarations      #
    #############################
    ret = {}
    ret.model = {}
    ret.view = {}
    ret.ctrl = {}


    ##############################
    ## Model                     #
    ##############################
    neighbor_set = [[ 1, 0], [ 1,-1],
                    [ 0,-1], [-1,-1],
                    [-1, 0], [-1, 1],
                    [ 0, 1], [ 1, 1]]

    ret.model.current_step = 0
    ret.model.cell_count = 0
    ret.model.live_cells = {}

    ret.model.raiseCell = (x, y) ->
        @live_cells[x] ?= {}
        @live_cells[x][y] = state_set.alive
        @cell_count += 1
        ret.view.colorRect x, y, state_set.alive
        undefined

    ret.model.killCell = (x, y) ->
        delete @live_cells[x][y]
        @cell_count -= 1
        if $.isEmptyObject @live_cells[x]
            delete @live_cells[x]
        ret.view.colorRect x, y, state_set.empty
        undefined
    
    ret.model.isAliveAt = (x, y) ->
        @live_cells[x]?[y]?

    ret.model.step = () ->
        #Wow... This is just.... Wow... So much kludge...
        @current_step += 1
        seeds = {}
        #I think this guy has been getting GC'd... why?
        ns = neighbor_set
        #So this shitstorm is supposed to roll through, hit every live
        #cell, and increment the neighbor count of all its neighbor_set
        #by one, checking to see if said neighbor is already alive.
        for x_s, cell_col of @live_cells
            for y_s, neighbor_count of cell_col
                x = parseInt(x_s)
                y = parseInt(y_s)
                for n in neighbor_set
                    if @live_cells[n[0]+x]?[n[1]+y]?
                        @live_cells[n[0]+x][n[1]+y] += 1
                    else
                        seeds[n[0]+x] ?= {}
                        seeds[n[0]+x][n[1]+y] ?= 0
                        seeds[n[0]+x][n[1]+y] += 1
        #Here we go _back_ over all them live cells, and kill the ones
        #that are either too friendly, or too lonely.
        for x_s, cell_col of @live_cells
            for y_s, neighbor_count of cell_col
                if neighbor_count isnt 2 and neighbor_count isnt 3
                    x = parseInt(x_s)
                    y = parseInt(y_s)
                    @killCell(x, y)
                else
                    @live_cells[x_s][y_s] = 0
        #Now we go through the list of effected dead cells, and see if
        #any of them should be coming to life or not.
        for x_s, cell_col of seeds
            for y_s, neighbor_count of cell_col
                if neighbor_count is 3
                    x = parseInt(x_s)
                    y = parseInt(y_s)
                    @raiseCell(x, y)
        undefined


    #############################
    ## View                     #
    #############################
    node_size = 15

    # We're assuming that `canvas_element` is going to be in the form
    # `"#html_id"`, and for some reason Raphael wants to look for it in
    # the form `"html_id"`, so we're induldgin it.
    ret.view.paper = Raphael canvas_element.slice(1)

    ret.view.grid_offset = x: 0, y:0
    ret.view.px_offset = x:0, y:0
    ret.view.width = 0
    ret.view.height = 0
    ret.view.node_cols = 0
    ret.view.node_rows = 0

    #Public Methods
    ret.view.resizeGrid = (@width, @height) ->
        #Storing more variables for later use (width and height are
        #already stored).
        @node_cols = 1 + Math.ceil @width / node_size
        @node_rows = 1 + Math.ceil @height / node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height

        #Draw that grid
        @drawGrid()
        undefined
    
    ret.view.moveOffset = (delta_x, delta_y) ->
        #Add to the offset
        @px_offset.x += delta_x
        @px_offset.y += delta_y
        $("#debug_pane p span:eq(0)").text "X:#{@px_offset.x} Y:#{@px_offset.y}"

        if Math.abs(@px_offset.x) >= node_size
            if @px_offset.x > 0 
                @grid_offset.x += Math.floor(@px_offset.x / node_size)
            else
                @grid_offset.x += Math.ceil(@px_offset.x / node_size)
            @px_offset.x = @px_offset.x % node_size
        
        if Math.abs(@px_offset.y) >= node_size
            if @px_offset.y > 0 
                @grid_offset.y += Math.floor(@px_offset.y / node_size)
            else
                @grid_offset.y += Math.ceil(@px_offset.y / node_size)
            @px_offset.y = @px_offset.y % node_size

        $("#debug_pane p span:eq(1)").text "G_X:#{@grid_offset.x} G_Y:#{@grid_offset.y}"
        _.defer => @drawGrid()
        undefined
        
    ret.view.drawGrid = _.throttle((() ->
        #New plan. Instead of drawing every rectangle, I'm gonna just
        #horizontal and vertical lines that run the entire width or
        #length of the page, then go through the list of live cells
        #to find out if one needs be rendered.
        @paper.clear()
        @rects = []

        for i in [0..@node_cols]
            #Not a fan of this notation. 
            #M means `moveto`, L means `lineto`, and the lowercase
            #relative instructions don't seem to be working.
            @paper.path("M#{i * node_size + @px_offset.x},0" +
                       "L#{i * node_size + @px_offset.x},#{@height}")
                        .attr "stroke-opacity": .2
        for j in [0..@node_rows]
            @paper.path("M0,#{j * node_size + @px_offset.y}" +
                        "L#{@width},#{j * node_size + @px_offset.y}")
                .attr "stroke-opacity": .2

        for x in [-@grid_offset.x-1 ... @node_cols-@grid_offset.x]
            if ret.model.live_cells[x]?
            #An interesting heuristic. Do we iterate over all the live
            #cells in the model's column (an arbitrary number that
            #will _probably_ stay small) or do we iterate over the
            #number of rows being displayed?
            #I'm gonna go with the later, since I can cap its max
                for y in [-@grid_offset.y-1 ... @node_rows-@grid_offset.y]
                    @colorRect x, y, ret.model.live_cells[x][y] if ret.model.live_cells[x][y]?
        undefined), 3)

    ret.view.colorRect = (x, y, state) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        @rects[grid_x] ?= []
        @rects[grid_x][grid_y] ?= @paper.rect(grid_x * node_size + @px_offset.x,
                                              grid_y * node_size + @px_offset.y,
                                              node_size, node_size)
        @rects[grid_x][grid_y].attr state
        undefined

    ret.view.pageToGrid = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/node_size),
        y: Math.floor((page_y-@px_offset.y)/node_size)


    #############################
    ## Controller               #
    #############################
    scroll_threshold = 15

    ret.ctrl.resolveMousedown = (page_x, page_y) ->
        @last = x: page_x, y: page_y
        @moved = false
        undefined
    
    ret.ctrl.resolveMousemove = (page_x, page_y) ->
        #If we've moved far enough, that needs to be related. And we
        #won't bother checking if we have  started moving
        @moved = true if not @moved and Math.abs((@last.x-page_x)) +
                                        Math.abs((@last.y-page_y)) >
                                        scroll_threshold
        if @moved
            ret.view.moveOffset(page_x-@last.x, page_y-@last.y)
            @last.x = page_x
            @last.y = page_y
        undefined
    
    ret.ctrl.resolveMouseup = (page_x, page_y) ->
        if not @moved
            grid = ret.view.pageToGrid(page_x, page_y)
            x = grid.x - ret.view.grid_offset.x
            y = grid.y - ret.view.grid_offset.y
            if ret.model.isAliveAt x, y
                ret.model.killCell x, y
            else
                ret.model.raiseCell x, y
            $("#debug_pane p span:eq(2)").text "Click G X:#{grid.x} Y:#{grid.y}"
            $("#debug_pane p span:eq(3)").text "::::::::::::: X:#{x} Y:#{y}"
        undefined


    #############################
    ## HTML interactions. Final view calls. Return #
    #############################
    #Setting callbacks
    #Closing over this bit of setup to keep the namespace
    #from getting poluted by cached init logic.
    ( ->
        $raphael = $(canvas_element)
        $raphael.on "mousedown", (event) =>
            ret.ctrl.resolveMousedown event.pageX, event.pageY
            $raphael.on "mousemove", (event) =>
                ret.ctrl.resolveMousemove event.pageX, event.pageY
                false
            false
        $(window).on "mouseup", (event) =>
            $raphael.off "mousemove"
            ret.ctrl.resolveMouseup event.pageX, event.pageY
            undefined
        $(window).on "resize", _.debounce (() =>
            ret.view.resizeGrid($(window).width(), $(window).height())
            undefined
            ), 90
        undefined
    )()

    ret.step = () ->
        ret.model.step()
        undefined

    ret.view.resizeGrid(width, height)

    return ret