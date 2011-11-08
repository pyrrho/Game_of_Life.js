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
        for i in [0..@node_cols]
            for j in [0..@node_rows]
                @paper.rect(i*@_node_size, j*@_node_size,
                            @_node_size, @_node_size).attr('stroke-opacity', .2)
        undefined

    pageToGrid: (x, y) ->
        #Fuck yeah, implicit retuns!
        x: Math.floor(x / this._node_size),
        y: Math.floor(y / this._node_size)


window.GridController = 
    onMouseDown: (x, y) ->
        alert "Mouse Down at: " + [x, y]
