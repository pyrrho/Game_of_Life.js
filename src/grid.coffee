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
        $("#cell_count").text(@cell_count)
        GridView.colorRect grid_x, grid_y, _animation_set.alive
        undefined
    
    killCell: (grid_x, grid_y) ->
        delete @live_cells["#{grid_x}, #{grid_y}"]
        @cell_count -= 1
        $("#cell_count").text(@cell_count)
        GridView.colorRect grid_x, grid_y, _animation_set.empty
        undefined

    isAliveAt: (grid_x, grid_y) ->
        @live_cells["#{grid_x}, #{grid_y}"]?


window.GridView =
    _node_size: 30
    init: (width, height) ->
        #Set up the Raphael Canvas
        @paper = Raphael "draw_space"
        @drawGrid width, height

        #Capture browser events
        $("#draw_space").click (event) =>
            coord = @pageToGrid event.pageX, event.pageY 
            GridController.resolveClick coord.x, coord.y
        undefined

    drawGrid: (@width, @height) ->
        #Storing more variables for later use (width and height are
        #already stored)
        @node_cols = Math.ceil @width / @_node_size
        @node_rows = Math.ceil @height / @_node_size

        #(Re)Set the size of the Raphael Canvas
        @paper.setSize @width, @height

        #Draw them Rects
        @rects = []
        for i in [0..@node_cols]
            @rects[i] = []
            for j in [0..@node_rows]
                temp =  @paper.rect(i*@_node_size, j*@_node_size,
                                    @_node_size, @_node_size)
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
    resolveClick: (x, y) ->
        if GridModel.isAliveAt x, y
            GridModel.killCell x, y
        else
            GridModel.raiseCell x, y
        undefined

    
