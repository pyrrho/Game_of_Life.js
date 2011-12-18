GoL = (canvas_element, width, height) ->
    #############################
    ## 'Global' vars            #
    #############################
    raising_color = "#005500"
    dying_color = "#550000"
    stroke_opacity = 0.2
    anim_duration = 125
    

    #############################
    ## Object declarations      #
    #############################
    gol = {}
    gol.model = {}
    gol.view = {}
    gol.ctrl = {}

    cell = (born) ->
        birthday: born
        deathday: -1
        state: "born"
        neighbors: 0

    ##############################
    ## Model                     #
    ##############################
    neighbor_set = [{x: 1, y: 0}, {x: 1, y:-1},
                    {x: 0, y:-1}, {x:-1, y:-1},
                    {x:-1, y: 0}, {x:-1, y: 1},
                    {x: 0, y: 1}, {x: 1, y: 1}]

    gol.model.current_step = 0
    gol.model.cell_count = 0
    gol.model.live_cells = {}
    gol.model.fresh_cells = []

    gol.model.raiseCell = (x, y) ->
        @live_cells[x] ?= {}
        @live_cells[x][y] = cell(@current_step)
        @fresh_cells.push [x, y]
        @cell_count += 1
        gol.view.addRect x, y
        undefined

    gol.model.killCell = (x, y) ->
        delete @live_cells[x][y]
        if $.isEmptyObject @live_cells[x]
            delete @live_cells[x]
        @cell_count -= 1
        gol.view.removeRect x, y
        undefined
    
    gol.model.isAliveAt = (x, y) ->
        @live_cells[x]?[y]?

    gol.model.step = () ->
        #There's a better way to do this. Instead of repopulating the
        #`neighbor` counter and `seeds` object, `raiseCell` and
        #`killCell` should do the [in|de]crement.
        #TODO: Start a real TODO list and add this alteration to it.
        @current_step += 1
        seeds = {}
        #Step one, roll through the `live_cells` and increment its
        #neighbors' `neighbors` counter by one. (Well that was
        #unnecessarily repetitive.)
        for x_string, cell_col of @live_cells
            for y_string, cell of cell_col
                x = parseInt(x_string)
                y = parseInt(y_string)
                for neighbor in neighbor_set
                    #Of course, we only increment the `neighbor` count
                    #of cells that are already alive...
                    if @live_cells[x+neighbor.x]?[y+neighbor.y]?
                        @live_cells[x+neighbor.x][y+neighbor.y].neighbors += 1
                    #Otherwise, we populate the `seeds` object.
                    else
                        seeds[x+neighbor.x] ?= {}
                        seeds[x+neighbor.x][y+neighbor.y] ?= 0
                        seeds[x+neighbor.x][y+neighbor.y] += 1
        #Here we go _back_ over all the live cells, and kill the ones
        #that are either too friendly, or too lonely.
        for x_string, cell_col of @live_cells
            for y_string, cell of cell_col
                neighbor_count = cell.neighbors
                if neighbor_count isnt 2 and neighbor_count isnt 3
                    #This `parseInt`ing doesn't necessary need to be
                    #here, but x and y do need to be ints by the time
                    #we get to `gol.view.removeRect`.
                    x = parseInt(x_string)
                    y = parseInt(y_string)
                    @killCell(x, y)
                else
                    cell.neighbors = 0
        #Now we go through the seeded cells, and see if any of them
        #should be coming to life.
        for x_string, cell_col of seeds
            for y_string, neighbor_count of cell_col
                if neighbor_count is 3
                    x = parseInt(x_string)
                    y = parseInt(y_string)
                    @raiseCell(x, y)
        undefined

    gol.model.reset = () ->
        gol.model.current_step = 0
        gol.model.cell_count = 0
        gol.model.live_cells = {}


    #############################
    ## View                     #
    #############################
    node_size = 15
    min_zoom = 0.2
    max_zoom = 10
    zoom_scalar = -> gol.view.current_zoom * 0.0025

    #We're assuming that `canvas_element` is going to be in the form
    #`"#html_id"`, and for some reason Raphael wants to look for it in
    #the form `"html_id"`, so we're indulging it with the slice op.
    gol.view.paper = Raphael canvas_element.slice(1)
    gol.view.rects = {}
    
    gol.view.width = 0
    gol.view.height = 0
    gol.view.current_zoom = 1
    gol.view.scaled_node_size = node_size

    gol.view.zoom_offset = x: 0.5, y: 0.5
    gol.view.offset = x: 0, y: 0 #Offset from the origin.
    gol.view.grid_offset = x: 0, y :0
    gol.view.px_offset = x: 0, y: 0

    #Public Methods
    gol.view.resizeCanvas = (@width, @height) ->
        @paper.setSize @width, @height
        @drawGrid()
        undefined
    
    gol.view.setZoomOffset = (page_x, page_y) ->
        @zoom_offset = x: page_x / @width, y: page_y / @height
        undefined

    gol.view.zoom = (delta) ->
        old_zoom = @current_zoom
        @current_zoom += zoom_scalar()*delta
        if @current_zoom > max_zoom then @current_zoom = max_zoom
        else if @current_zoom < min_zoom then @current_zoom = min_zoom

        if old_zoom != @current_zoom
            @scaled_node_size = node_size*@current_zoom
            current_zoom = @current_zoom
            @moveOffset(-(@width/old_zoom - @width/current_zoom) * @zoom_offset.x,
                        -(@height/old_zoom - @height/current_zoom) * @zoom_offset.y,
                        false)
        undefined
    
    gol.view.moveOffset = (delta_x, delta_y, scale=true) ->
        if scale #Do we want to scale the delta by the current zoom?
            @offset.x += delta_x * (1/@current_zoom)
            @offset.y += delta_y * (1/@current_zoom)
        else #We're not scaling
            @offset.x += delta_x
            @offset.y += delta_y
        @grid_offset = x: Math.floor((@offset.x * @current_zoom) / @scaled_node_size),\
                       y: Math.floor((@offset.y * @current_zoom) / @scaled_node_size)
        #There has to be a better way of doing this part....
        @px_offset = x: (@offset.x * @current_zoom) % @scaled_node_size,\
                     y: (@offset.y * @current_zoom) % @scaled_node_size
        @px_offset.x += @scaled_node_size if @px_offset.x < 0
        @px_offset.y += @scaled_node_size if @px_offset.y < 0
        _.defer => @drawGrid()
        undefined
        
    #Rather than drawing every rectangle, we simply draw horizontal
    #and vertical lines that run the width or length of the page, then
    #go through the list of live cells to find out if one needs be
    #rendered.
    gol.view.drawGrid = _.throttle((() ->
        @paper.clear()
        #`@rects` gets repopulated in `@addRect(. . .)`
        @rects = {}

        node_cols = 1 + Math.ceil @width / @scaled_node_size
        node_rows = 1 + Math.ceil @height / @scaled_node_size

        for i in [0..node_cols]
            #Not a fan of this notation. #M means `moveto`, L means 
            #`lineto`.
            @paper.path("M#{i * @scaled_node_size + @px_offset.x},0" +
                        "L#{i * @scaled_node_size + @px_offset.x},#{@height}")
                        .attr "stroke-opacity": .2
        for j in [0..node_rows]
            @paper.path("M0,#{j * @scaled_node_size + @px_offset.y}" +
                        "L#{@width},#{j * @scaled_node_size + @px_offset.y}")
                        .attr "stroke-opacity": .2

        #An interesting heuristic. Do we iterate over all the live
        #cells in the model (an arbitrary number that will _probably_
        #stay small), or do we iterate over cells being displayed?
        #I'm going to go with the later, since I can cap its max
        for x in [0-@grid_offset.x ... node_cols-@grid_offset.x]
            if gol.model.live_cells[x]?
                for y in [0-@grid_offset.y ... node_rows-@grid_offset.y]
                    @drawRect x, y if gol.model.live_cells[x][y]?
        undefined), 3)

    gol.view.addRect = (x, y) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        @rects[grid_x] ?= {}
        @rects[grid_x][grid_y] ?= 
            @paper.rect(
                grid_x * @scaled_node_size + @px_offset.x,
                grid_y * @scaled_node_size + @px_offset.y,
                @scaled_node_size, @scaled_node_size,
                @scaled_node_size/5).
            attr(
                "fill": raising_color
                "stroke-opacity": 0.2
                "transform": "S0.0"
                "opacity": 0).
            animate(
                "transform": "S1.0"
                "opacity": 1
                "stroke-width": 1,
                anim_duration)
        undefined

    gol.view.drawRect = (x, y) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        @rects[grid_x] ?= {}
        @rects[grid_x][grid_y] ?= 
            @paper.rect(
                grid_x * @scaled_node_size + @px_offset.x,
                grid_y * @scaled_node_size + @px_offset.y,
                @scaled_node_size, @scaled_node_size,
                @scaled_node_size/5).
            attr(
                "fill": raising_color
                "stroke-opacity": 0.2
                "stroke-width": 1)

    gol.view.removeRect = (x, y) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        if @rects[grid_x]?[grid_y]?
            @rects[grid_x][grid_y].
            attr(
                "fill": dying_color
            ).
            animate(
                "opacity": 0
                "transform": "S0.0",
                anim_duration)
            _.delay ((rect) ->
                        rect.remove() if rect.node.parentNode?
                        undefined),
                    anim_duration,
                    @rects[grid_x][grid_y]
            delete @rects[grid_x][grid_y]
            if $.isEmptyObject @rects[grid_x]
                delete @rects[grid_x]
        undefined
        
    gol.view.pageToGrid = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/@scaled_node_size),
        y: Math.floor((page_y-@px_offset.y)/@scaled_node_size)
    
    gol.view.pageToAbs = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/@scaled_node_size) - @grid_offset.x,
        y: Math.floor((page_y-@px_offset.y)/@scaled_node_size) - @grid_offset.y


    #############################
    ## Controller               #
    #############################
    scroll_threshold = 5
    #For JS events, 0 represents the right mouse button, 2 the left
    [mouse_left, mouse_right] = [0, 2]

    gol.ctrl.active = [false, false]
    gol.ctrl.drag_start = x: 0, y: 0
    gol.ctrl.page_last = x: 0, y: 0
    gol.ctrl.abs_last = x: 0, y: 0
    gol.ctrl.moving = false
    gol.ctrl.hz = 4
    gol.ctrl.running = undefined

    gol.ctrl.resolveMousedown = (page_x, page_y, button) ->
        @active[button] = true
        @page_last = x: page_x, y: page_y
        abs = gol.view.pageToAbs(page_x, page_y)
        #Starting a zoom?
        if @active[mouse_left] and @active[mouse_right]
            gol.view.setZoomOffset(page_x, page_y)
        #Or messing with cells?
        else if @active[mouse_left]
            if gol.model.isAliveAt abs.x, abs.y
                gol.model.killCell abs.x, abs.y
                @active[mouse_left] = "kill"
            else
                gol.model.raiseCell abs.x, abs.y
                @active[mouse_left] = "raise"
            @abs_last = x: abs.x, y: abs.y
        #Dragging the canvas around?
        #else #if @active[mouse_right]
        undefined

    gol.ctrl.resolveMouseup = (button) ->
        @active[button] = false
        if not @active[mouse_left] and not @active[mouse_right]
            @moving = false
            _.defer => $("#draw_space").attr "oncontextmenu", " "
        undefined
    
    gol.ctrl.resolveMousemove = (page_x, page_y) ->
        #If we've moved past the threshold, that needs to be known and
        #acted upon.
        delta_x = @page_last.x-page_x
        delta_y = @page_last.y-page_y
        if not @moving and Math.abs(delta_x) +
                           Math.abs(delta_y) > scroll_threshold
            @moving = true
            $("#draw_space").attr "oncontextmenu", "return false"
            @drag_start = x: @page_last.x, y: @page_last.y

        if @moving
            if @active[mouse_left] and @active[mouse_right]
                gol.view.zoom(delta_y)
            else if @active[mouse_right]
                gol.view.moveOffset(-delta_x, -delta_y)
            else#if @active[mouse_left]
                abs = gol.view.pageToAbs(page_x, page_y)
                if abs.x isnt @abs_last.x or abs.y isnt @abs_last.y
                    @abs_last = x: abs.x, y: abs.y
                    if @active[mouse_left] is "raise"
                        gol.model.raiseCell abs.x, abs.y
                    else if gol.model.isAliveAt abs.x, abs.y
                        gol.model.killCell abs.x, abs.y
            @page_last.x = page_x
            @page_last.y = page_y
        undefined

    gol.ctrl.setHz = (hz) ->
        @hz = hz
        anim_duration = 1000/(2*gol.ctrl.hz)
        if anim_duration > 200 then anim_duration = 200
        else if anim_duration < 30 then anim_duration = 0
        if @running?
            clearTimeout(@running)
            @running = setInterval (=> gol.model.step()), 1000/@hz
        undefined

    gol.ctrl.start = () ->
        @running ?= setInterval (=> gol.model.step()), 1000/@hz
        undefined

    gol.ctrl.stop = () ->
        clearTimeout(@running)
        delete(@running)
        undefined

    gol.ctrl.reset = () ->
        @.stop()

    #############################
    ## HTML interactions. Final view calls. Return #
    #############################
    #Setting callbacks  
    #Closing over this bit of setup to keep the namespace from getting
    #polluted by cached init logic.
    ( ->
        $raphael = $(canvas_element)

        $raphael.on "mousedown", (event) =>
            gol.ctrl.resolveMousedown event.pageX, event.pageY, event.button
            $raphael.on "mousemove", (event) =>
                gol.ctrl.resolveMousemove event.pageX, event.pageY
                false
            false
        $(window).on "mouseup", (event) =>
            gol.ctrl.resolveMouseup(event.button)
            if not gol.ctrl.active[mouse_left] and not gol.ctrl.active[mouse_right]
                $raphael.off "mousemove"
            false
        $(window).on "resize", _.debounce (() =>
            gol.view.resizeCanvas($(window).width(), $(window).height())
            undefined
            ), 90
        true
    )()

    gol.step = () =>
        gol.model.step()
        undefined

    gol.start = () =>
        gol.ctrl.start()

    gol.stop = () =>
        gol.ctrl.stop()
    
    gol.setHz = (hz) =>
        gol.ctrl.setHz(hz)

    gol.reset = () =>
        gol.ctrl.reset()
        gol.model.reset()
        gol.view.drawGrid()
        undefined

    gol.view.resizeCanvas(width, height)

    return gol
