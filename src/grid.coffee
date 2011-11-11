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
        @live_cells[x][y] = 0
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
    node_size = 30

    # We're assuming that `canvas_element` is going to be in the form
    # `"#html_id"`, and for some reason Raphael wants to look for it in
    # the form `"html_id"`, so we're induldgin it.
    ret.view.paper = Raphael canvas_element.slice(1)

    ret.view.grid_offset = x: 0, y:0
    ret.view.px_offset = x:0, y:0

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

        _.defer => @drawGrid()
        undefined
        
    ret.view.drawGrid = _.throttle((() ->
        #So, we're gonna go for the brute-force here. I feel like
        #that's a pretty bad idea, but... premature optimizations and
        #all that.
        @paper.clear()

        @rects = []
        for i in [-1..@node_cols]
            @rects[i] = []
            for j in [-1..@node_rows]
                temp =  @paper.rect i * node_size + @px_offset.x, 
                                    j * node_size + @px_offset.y,
                                    node_size, node_size
                attrs = {}
                if ret.model.live_cells[i-@grid_offset.x]?[j-@grid_offset.y]?
                    attrs = state_set.alive
                else
                    attrs = state_set.empty
                temp.attr(attrs)
                @rects[i][j] = temp
        undefined), 5)

    ret.view.colorRect = (x, y, state) ->
        @rects[x+@grid_offset.x]?[y+@grid_offset.y]?.attr state
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
        @mouse_down = true
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
        if @mouse_down and not @moved
            @mouse_down = false
            grid = ret.view.pageToGrid(page_x, page_y)
            x = grid.x - ret.view.grid_offset.x
            y = grid.y - ret.view.grid_offset.y
            if ret.model.isAliveAt x, y
                ret.model.killCell x, y
            else
                ret.model.raiseCell x, y
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
                undefined
            undefined
        $("body").on "mouseup", (event) =>
            $raphael.off "mousemove"
            ret.ctrl.resolveMouseup event.pageX, event.pageY
            undefined
        undefined
    )()

    ret.step = () ->
        ret.model.step()
        undefined

    ret.view.resizeGrid(width, height)

    return ret