window.GridModel = 
    init: () ->
        @live_cells = []
        @seed_cells = []
        @dead_cells = []
        undefined

    raiseCell: (grid_x, grid_y) ->
        @live_cells.push [grid_x, grid_y]
        $('#cell_count').text(@live_cells.length)
        GridView.colorRect grid_x, grid_y
        undefined


window.GridView =
    _node_size: 30
    init: (width, height) ->
        #Set up the Raphael Canvas
        @paper = Raphael 'draw_space'
        @drawGrid width, height

        #Capture browser events
        $('#draw_space').mousedown (event) =>
            coord = @pageToGrid event.pageX, event.pageY 
            GridController.onMouseDown coord.x, coord.y
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
                temp.attr('stroke-opacity', .2)
                @rects[i][j] = temp
        undefined

    pageToGrid: (x, y) ->
        #Fuck yeah, implicit retuns!
        x: Math.floor(x / this._node_size),
        y: Math.floor(y / this._node_size)

    colorRect: (x, y) ->
        @rects[x][y].attr {fill: "#CCC"}
        undefined


window.GridController = 
    onMouseDown: (x, y) ->
        GridModel.raiseCell(x, y)
        undefined
