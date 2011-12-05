GoL = (canvas_element, width, height) ->
    #############################
    ## 'Global' vars            #
    #############################
    state_set =
        empty:
            "opacity": 0
        alive:
            "fill": "#1A301A"
            "stroke-opacity": .2
            "opactiy": 1


    #############################
    ## Object declarations      #
    #############################
    gol = {}
    gol.model = {}
    gol.view = {}
    gol.ctrl = {}


    ##############################
    ## Model                     #
    ##############################
    neighbor_set = [[ 1, 0], [ 1,-1],
                    [ 0,-1], [-1,-1],
                    [-1, 0], [-1, 1],
                    [ 0, 1], [ 1, 1]]

    gol.model.current_step = 0
    gol.model.cell_count = 0
    gol.model.live_cells = {}

    gol.model.raiseCell = (x, y) ->
        @live_cells[x] ?= {}
        @live_cells[x][y] = 0
        @cell_count += 1
        gol.view.colorRect x, y, state_set.alive
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
    
    gol.view.width = 0
    gol.view.height = 0
    gol.view.current_zoom = 1
    gol.view.scaled_node_size = node_size

    gol.view.zoom_offset = x: 0.5, y: 0.5
    gol.view.offset = x: 0, y: 0
    gol.view.grid_offset = x: 0, y :0
    gol.view.px_offset = x: 0, y: 0

    #Public Methods
    gol.view.resizeCanvas = (@width, @height) ->
        @paper.setSize @width, @height
        @drawGrid()
        undefined
    
    gol.view.set_zoom_offset = (page_x, page_y) ->
        @zoom_offset = x: page_x / @width, y: page_y / @height
        #console.log "pagex:#{page_x}, pagey:#{page_y}"
        #console.log "offsx:#{@zoom_offset.x}, offsy:#{@zoom_offset.y}"
        undefined

    gol.view.zoom = (delta) ->
        old_zoom = @current_zoom
        @current_zoom += zoom_scalar()*delta
        if @current_zoom > max_zoom then @current_zoom = max_zoom
        else if @current_zoom < min_zoom then @current_zoom = min_zoom

        if old_zoom != @current_zoom
            @scaled_node_size = node_size*@current_zoom

            #console.log "Old zoom: #{old_zoom}"
            #console.log "Current Zoom: #{@current_zoom}"
            #console.log "Old Width: #{@width / old_zoom}"
            #console.log "Old Height: #{@height / old_zoom}" 
            #console.log "New Width: #{@width / @current_zoom}"
            #console.log "New Height: #{@height / @current_zoom}"

            #current_zoom = @current_zoom
            #@moveOffset(@width/current_zoom - @width/old_zoom,
            #            @height/current_zoom - @height/old_zoom)
            #@moveOffset(@width/old_zoom - @width/current_zoom,
            #            @height/old_zoom - @height/current_zoom)
            #console.log "Dx: #{(@width / old_zoom - @width / @current_zoom)*@zoom_offset.x}"
            #console.log "Dy: #{(@height / old_zoom - @height / @current_zoom)*@zoom_offset.y}"

            @moveOffset(0,0)
            #_.defer => @drawGrid()
        undefined
    
    gol.view.moveOffset = (delta_x, delta_y) ->

        #console.log "delta_x: #{delta_x}, delta_y: #{delta_y}"
        #console.log "x grid:#{@grid_offset.x} px:#{@px_offset.x}" +
        #            "y grid:#{@grid_offset.y} px:#{@px_offset.y}"

        #Add to the offset
        @offset.x += delta_x
        @offset.y += delta_y
        @grid_offset = x: Math.floor(@offset.x / @scaled_node_size),\
                       y: Math.floor(@offset.y / @scaled_node_size)
        #There has to be a better way of doing this part....
        @px_offset = x: @offset.x % @scaled_node_size,\
                     y: @offset.y % @scaled_node_size
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
        #`@rects` gets repopulated in `@colorRect(. . .)`
        @rects = []

        node_cols = 1 + Math.ceil @width / @scaled_node_size
        node_rows = 1 + Math.ceil @height / @scaled_node_size

        for i in [0..node_cols]
            #Not a fan of this notation. 
            #M means `moveto`, L means `lineto`.
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
                    @colorRect x, y, state_set.alive if gol.model.live_cells[x][y]?

        @paper.circle(@grid_offset.x*@scaled_node_size + @px_offset.x,
                      @grid_offset.y*@scaled_node_size + @px_offset.y,
                      10*@current_zoom).attr "fill": "red"
        undefined), 3)

    gol.view.colorRect = (x, y, state) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        @rects[grid_x] ?= []
        @rects[grid_x][grid_y] ?= @paper.rect(grid_x * @scaled_node_size + @px_offset.x,
                                              grid_y * @scaled_node_size + @px_offset.y,
                                              @scaled_node_size, @scaled_node_size)
        @rects[grid_x][grid_y].attr state
        undefined

    gol.view.removeRect = (x, y) ->
        grid_x = x + @grid_offset.x
        grid_y = y + @grid_offset.y

        if @rects[grid_x]?[grid_y]?
            @rects[grid_x][grid_y].remove() 
            delete @rects[grid_x][grid_y]
        undefined

    gol.view.pageToGrid = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/@scaled_node_size),
        y: Math.floor((page_y-@px_offset.y)/@scaled_node_size)
    
    gol.view.pageToAbs = (page_x, page_y) ->
        x: Math.floor((page_x-@px_offset.x)/@scaled_node_size) - gol.view.grid_offset.x,
        y: Math.floor((page_y-@px_offset.y)/@scaled_node_size) - gol.view.grid_offset.y


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
    gol.ctrl.hz = 8
    gol.ctrl.running = undefined

    gol.ctrl.resolveMousedown = (page_x, page_y, button) ->
        @active[button] = true
        @page_last = x: page_x, y: page_y
        abs = gol.view.pageToAbs(page_x, page_y)
        #Starting a zoom?
        if @active[mouse_left] and @active[mouse_right]
            #gol.view.set_zoom_offset(page_x, page_y)
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
    #poluted by cached init logic.
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
