GoL = {}

GoL.state_set =
    empty:
        "fill": "white"
        "stroke-opacity": .2
    alive:
        "fill": "#1A301A"
        "stroke-opacity": .2


GoL.model = () ->
    #Object to return
    model = {}
    model.curret_step = 0
    model.cell_count = 0
    model.live_cells = {}

    #Private vars
    neighbors = [[ 1, 0],
                 [ 1,-1],
                 [ 0,-1],
                 [-1,-1],
                 [-1, 0],
                 [-1, 1],
                 [ 0, 1],
                 [ 1, 1]]

    #Public methods 
    model.raiseCell = (x, y) ->
        @live_cells[x] ?= {}
        @live_cells[x][y] = 0
        @cell_count += 1
        GridView.colorRect x, y, GoL.state_set.alive
        undefined

    model.killCell = (x, y) ->
        delete @live_cells[x][y]
        @cell_count -= 1
        if $.isEmptyObject @live_cells[x]
            delete @live_cells[x]
        GridView.colorRect x, y, GoL.state_set.empty
        undefined
    
    model.isAliveAt = (x, y) ->
        @live_cells[x]?[y]?

    model.step = () ->
        #Wow... This is just.... Wow... So much kludge...
        current_step += 1
        seeds = {}
        #So this shitstorm is supposed to roll through, hit every live
        #cell, and increment the neighbor count of all its neighbors
        #by one, checking to see if said neighbor is already alive.
        for x_s, cell_col of @live_cells
            x = parseInt(x_s) 
            for y_s, state of cell_col
                y = parseInt(y_s)
                for n in neighbors
                    if @live_cells[n[0]+x]?[n[1]+y]?
                        @live_cells[n[0]+x][n[1]+y] += 1
                    else
                        seeds[n[0]+x] ?= {}
                        seeds[n[0]+x][n[1]+y] ?= 0
                        seeds[n[0]+x][n[1]+y] += 1
        #Here we go _back_ over all them live cells, and kill the ones
        #that are either too friendly, or too lonely.
        for x_s, cell_col of @live_cells
            x = parseInt(x_s) 
            for y_s, neighbors of cell_col
                y = parseInt(y_s)
                @live_cells[x_s][y_s] = 0
                if neighbors isnt 2 and neighbors isnt 3
                    @killCell(x, y)
        #Now we go through the list of effected dead cells, and see if
        #any of them should be coming to life or not.
        for x_s, cell_col of seeds
            x = parseInt(x_s)
            for y_s, neighbors of cell_col
                y = parseInt(y_s)
                if neighbors is 3
                    @raiseCell(x, y)
        undefined
    
    return model

GoL.view = (raphael_element, width, height) ->
    #Object & public vars
    view = {}
    view.grid_offset = x: 0, y:0
    view.px_offset = x:0, y:0

    view.paper = Raphael raphael_element

    #Private vars
    node_size = 30

    #Setting callbacks
    #Closing over this bit of setup to keep the GridView namespace
    #from getting poluted by cached init logic.
    ( ->
        $raphael = $("#"+raphael_element)
        $raphael.on "mousedown", (event) =>
            GridController.resolveMousedown event.pageX, event.pageY
            $raphael.on "mousemove", (event) =>
                GridController.resolveMousemove event.pageX, event.pageY
                undefined
            undefined
        $("body").on "mouseup", (event) =>
            $raphael.off "mousemove"
            GridController.resolveMouseup event.pageX, event.pageY
            undefined
        undefined
    )()

    #Public Methods
    view.resizeGrid = (@width, @height) ->
        #Storing more variables for later use (width and height are
        #already stored).
        @node_cols = 1 + Math.ceil @width / node_size
        @node_rows = 1 + Math.ceil @height / node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height

        #Draw that grid
        @drawGrid()
        undefined
    
    view.moveOffset = (delta_x, delta_y) ->
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
        
    view.drawGrid = _.throttle (() ->
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
                if GridModel.live_cells[i-@grid_offset.x]?[j-@grid_offset.y]?
                    attrs = GoL.state_set.alive
                else
                    attrs = GoL.state_set.empty
                temp.attr(attrs)
                @rects[i][j] = temp
        undefined), 5

    view.colorRect = (x, y, state) ->
        @rects[x+@grid_offset.x][y+@grid_offset.y].attr state
        undefined

    view.pageToGrid = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/node_size),
        y: Math.floor((page_y-@px_offset.y)/node_size)

    view.resizeGrid(width, height)
    return view


GoL.controller = () ->
    #Return objet
    ctrl = {}

    #Private vars
    threshold = 15

    #Public methods
    ctrl.resolveMousedown = (page_x, page_y) ->
        @last = x: page_x, y: page_y
        @moved = false
        @mouse_down = true
        undefined
    
    ctrl.resolveMousemove = (page_x, page_y) ->
        #If we've moved far enough, that needs to be related. And we
        #won't bother checking if we have  started moving
        @moved = true if not @moved and Math.abs((@last.x-page_x)) +
                                        Math.abs((@last.y-page_y)) > threshold
        if @moved
            GridView.moveOffset(page_x-@last.x, page_y-@last.y)
            @last.x = page_x
            @last.y = page_y
        undefined
    
    ctrl.resolveMouseup = (page_x, page_y) ->
        if @mouse_down and not @moved
            @mouse_down = false
            grid = GridView.pageToGrid(page_x, page_y)
            x = grid.x - GridView.grid_offset.x
            y = grid.y - GridView.grid_offset.y
            if GridModel.isAliveAt x, y
                GridModel.killCell x, y
            else
                GridModel.raiseCell x, y
        undefined
    
    return ctrl