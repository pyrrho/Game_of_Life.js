_state_set =
    empty:
        "fill": "white"
        "stroke-opacity": .2
    alive:
        "fill": "#1A301A"
        "stroke-opacity": .2

window.GridModel =
    _neighbors: [[ 1, 0],
                 [ 1,-1],
                 [ 0,-1],
                 [-1,-1],
                 [-1, 0],
                 [-1, 1],
                 [ 0, 1],
                 [ 1, 1]]
    init: () ->
        @current_step = 0
        @cell_count = 0
        @live_cells = {}
        undefined

    raiseCell: (x, y) ->
        @live_cells[x] ?= {}
        @live_cells[x][y] = 0
        @cell_count += 1
        GridView.colorRect x, y, _state_set.alive
        undefined
    
    killCell: (x, y) ->
        delete @live_cells[x][y]
        @cell_count -= 1
        if $.isEmptyObject @live_cells[x]
            delete @live_cells[x]
        GridView.colorRect x, y, _state_set.empty
        undefined

    isAliveAt: (x, y) ->
        @live_cells[x]?[y]?

    step: () ->
        #Wow... This is just.... Wow... So much kludge...
        @current_step += 1
        seeds = {}
        #So this shitstorm is supposed to roll through, hit every live
        #cell, and increment the neighbor count of all its neighbors
        #by one, checking to see if said neighbor is already alive.
        for x_s, cell_col of @live_cells
            x = parseInt(x_s) 
            for y_s, state of cell_col
                y = parseInt(y_s)
                for n in @_neighbors
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
                

        


window.GridView =
    _node_size: 30

    init: (width, height) ->
        #Set up the Raphael Canvas
        @paper = Raphael "draw_space"
        @grid_offset = x: 0, y: 0
        @px_offset = x: 0, y: 0
        @resizeGrid width, height
        @drawGrid()

        #Capturing browser events
        #Caching ftw
        $draw_space = $("#draw_space")
        $draw_space.on "mousedown", (event) =>
            GridController.resolveMousedown event.pageX, event.pageY
            $draw_space.on "mousemove", (event) =>
                GridController.resolveMousemove event.pageX, event.pageY
                undefined
            undefined
        $("body").on "mouseup", (event) =>
            $draw_space.off "mousemove"
            GridController.resolveMouseup event.pageX, event.pageY
            undefined
        undefined

    resizeGrid: (@width, @height) ->
        #Storing more variables for later use (width and height are
        #already stored).
        @node_cols = 1 + Math.ceil @width / @_node_size
        @node_rows = 1 + Math.ceil @height / @_node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height
        undefined
    
    moveOffset: (delta_x, delta_y) ->
        #Add to the offset
        @px_offset.x += delta_x
        @px_offset.y += delta_y

        if Math.abs(@px_offset.x) >= @_node_size
            if @px_offset.x > 0 then @grid_offset.x += 1 else @grid_offset.x -= 1
            @px_offset.x = @px_offset.x % @_node_size
        
        if Math.abs(@px_offset.y) >= @_node_size
            if @px_offset.y > 0 then @grid_offset.y += 1 else @grid_offset.y -= 1
            @px_offset.y = @px_offset.y % @_node_size
        #TODO: Hm. Looks like we should probably be moving, rather
        #than clearing elements....
        @paper.clear()
        @drawGrid()
        undefined
        
    drawGrid: () ->
        #So, we're gonna go for the brute-force here. I feel like
        #that's a pretty bad idea, but... premature optimizations and
        #all that.
        @rects = []
        for i in [-1..@node_cols]
            @rects[i] = []
            for j in [-1..@node_rows]
                temp =  @paper.rect i * @_node_size + @px_offset.x, 
                                    j * @_node_size + @px_offset.y,
                                    @_node_size, @_node_size
                attrs = {}
                if GridModel.live_cells[i-@grid_offset.x]?[j-@grid_offset.y]?
                    attrs = _state_set.alive
                else
                    attrs = _state_set.empty
                temp.attr(attrs)
                @rects[i][j] = temp
        undefined

    colorRect: (x, y, state) ->
        @rects[x+@grid_offset.x][y+@grid_offset.y].attr state
        undefined

    pageToGrid: (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/this._node_size),
        y: Math.floor((page_y-@px_offset.y)/this._node_size)


window.GridController =
    theshold: 15
    resolveMousedown: (page_x, page_y) ->
        @last = x: page_x, y: page_y
        @moved = false
        @mouse_down = true
        undefined
    
    resolveMousemove: (page_x, page_y) ->
        #If we've moved far enough, that needs to be related. And we
        #won't bother checking if we have  started moving
        @moved = true if not @moved and Math.abs((@last.x-page_x)) +
                                        Math.abs((@last.y-page_y)) > @theshold
        if @moved
            GridView.moveOffset(page_x-@last.x, page_y-@last.y)
            @last.x = page_x
            @last.y = page_y
        undefined
    
    resolveMouseup: (page_x, page_y) ->
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
