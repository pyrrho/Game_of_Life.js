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

        #Capture browser events
        $draw_space = $("#draw_space")
        $draw_space.on "click", (event) =>
            $("#help_pane").show().fadeOut('slow')
            coord = @pageToGrid event.pageX, event.pageY 
            GridController.resolveClick coord.x, coord.y
            undefined
        $draw_space.on "mousedown", (event) =>
            GridController.last = x: event.pageX, y: event.pageY
            $draw_space.on "mousemove", (event) =>
                GridController.resolveMove event.pageX, event.pageY
            undefined
        $draw_space.on "mouseup", (event) =>
            $draw_space.off "mousemove"
            false
        $("body").on "mouseup", (event) =>
            $draw_space.off "mousemove"
            undefined
        undefined

    resizeGrid: (@width, @height) ->
        #Storing more variables for later use (width and height are
        #already stored). The +1 is for the potential over-flow when
        #we start moving the rectangles around
        @node_cols = 1 + Math.ceil @width / @_node_size
        @node_rows = 1 + Math.ceil @height / @_node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height
        
    drawGrid: () ->
        #So, we're gonna go for the brute-force here. I feel like
        #that's a pretty bad idea, but... premature optimizations and
        #all that.
        @rects = []
        for i in [0..@node_cols]
            @rects[i] = []
            for j in [0..@node_rows]
                temp =  @paper.rect i * @_node_size + @px_offset.x, 
                                    j * @_node_size + @px_offset.y,
                                    @_node_size, @_node_size
                temp.attr("stroke-opacity", .2)
                @rects[i][j] = temp
        undefined

    pageToGrid: (x, y) ->
        x: Math.floor(x / this._node_size),
        y: Math.floor(y / this._node_size)

    colorRect: (x, y, state) ->
        @rects[x][y].attr {fill: state.fill}
        undefined


window.GridController =
    resolveClick: (grid_x, grid_y) ->
        if isnt GridModel.isAliveAt grid_x, grid_y
            GridModel.raiseCell grid_x, grid_y
        else
            GridModel.killCell grid_x, grid_y
        click_coords = "( " + grid_x + ", " + grid_y + " )"
        $("#timer_pane span:eq(3)").text("click coords - " + click_coords)
        undefined

    resolveMove: (page_x, page_y) ->
        page_coords = "( " + page_x + ", " + page_y + " )"
        last_coords = "( " + @last.x + ", " + @last.y + " )"
        delta = [page_x - @last.x, page_y - @last.y]
        delta_coords = "( " + delta[0] + ", " + delta[1] + " )"
        $("#timer_pane span:eq(0)").text("page coords - " + page_coords)
        $("#timer_pane span:eq(1)").text("last coords - " + last_coords)
        $("#timer_pane span:eq(2)").text("delta coords - " + delta_coords)
        @last.x = page_x; @last.y = page_y
        undefined
    
