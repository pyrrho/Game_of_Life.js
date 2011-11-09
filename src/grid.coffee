_animation_set =
    empty:
        "fill": "white"
        "stroke-opacity": .2
    alive:
        "fill": "#1A301A"
        "stroke-opacity": .2

window.GridModel = 
    init: () ->
        @cell_count = 0
        @live_cells = {}
        @seed_cells = {}
        @dead_cells = {}
        undefined

    raiseCell: (grid_x, grid_y) ->
        @live_cells["#{grid_x}, #{grid_y}"] = 0
        @cell_count += 1
        GridView.colorRect grid_x, grid_y, _animation_set.alive
        undefined
    
    killCell: (grid_x, grid_y) ->
        delete @live_cells["#{grid_x}, #{grid_y}"]
        @cell_count -= 1
        GridView.colorRect grid_x, grid_y, _animation_set.empty
        undefined

    isAliveAt: (grid_x, grid_y) ->
        @live_cells["#{grid_x}, #{grid_y}"]?


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
        @node_cols = Math.ceil @width / @_node_size
        @node_rows = Math.ceil @height / @_node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height
    
    moveOffset: (delta_x, delta_y) ->
        @px_offset.x += delta_x
        @px_offset.y += delta_y
        $("#timer_pane span:eq(1)").text("( " + (@px_offset.x % @_node_size) + "  " + (@px_offset.y % @_node_size) + " )")
        if @px_offset.x isnt @px_offset.x % @_node_size 
            if @px_offset.x > 0 then @grid_offset.x += 1 else @grid_offset.x -= 1
            @px_offset.x = @px_offset.x % @_node_size
            $("#timer_pane span:eq(1)").text("the X should have modulo'd")
        if @px_offset.y isnt @px_offset.y % @_node_size 
            if @px_offset.y > 0 then @grid_offset.y += 1 else @grid_offset.y -= 1
            @px_offset.y = @px_offset.y % @_node_size
            $("#timer_pane span:eq(2)").text("the Y should have modulo'd")
        offset = "( " + @px_offset.x + ", " + @px_offset.y + " )"
        $("#timer_pane span:eq(0)").text("page coords - " + offset)
        
        #TODO: Hm. Looks like we should probably be moving, rather
        #than clearing elements....
        @paper.clear()
        @drawGrid()
        
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
                temp.attr("stroke-opacity", .2)
                @rects[i][j] = temp
        undefined

    colorRect: (x, y, state) ->
        @rects[x][y].attr {fill: state.fill}
        undefined

    pageToGrid: (page_x, page_y) ->
        x: Math.floor(page_x / this._node_size),
        y: Math.floor(page_y / this._node_size)


window.GridController =
    theshold: 15
    resolveMousedown: (page_x, page_y) ->
        @last = x: page_x, y: page_y
        @moved = false
#        last_coords = "( " + @last.x + ", " + @last.y + " )"
#        $("#timer_pane span:eq(0)").text("last coords - " + last_coords)
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
#        page_coords = "( " + page_x + ", " + page_y + " )"
#        delta = [page_x - @last.x, page_y - @last.y]
#        delta_coords = "( " + delta[0] + ", " + delta[1] + " )"
#        $("#timer_pane span:eq(1)").text("page coords - " + page_coords)
#        $("#timer_pane span:eq(2)").text("delta coords - " + delta_coords+ "   " + @moved)
        undefined
    
    resolveMouseup: (page_x, page_y) ->
        if not @moved
            {x, y} = GridView.pageToGrid(page_x, page_y)
            if GridModel.isAliveAt x, y
                GridModel.killCell x, y
            else
                GridModel.raiseCell x, y
#            click_coords = "( " + page_x + ", " + page_y + " )"
#            $("#timer_pane span:eq(3)").text("click coords - " + click_coords)
        undefined
