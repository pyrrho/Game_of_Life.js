$( ->
    window.game_of_life = GoL("#draw_space", $(window).width(), $(window).height())

    ## UI Setup
    $(".movable_pane").draggable()

    #Hide Anchor Functionality
    $("#hide").on "click", (event) ->
        $("#help_pane").slideUp()
        undefined

    # Button on click event setup
    $("#step_reset_set").buttonset()

    play = false
    $("#play").button()
    $("#play").on "click", (event) ->
        if not play
            play = true
            game_of_life.start()
        else
            play = false
            game_of_life.stop()
        undefined

    $("#step").button()
    $("#step").on "click", (event) ->
        game_of_life.step()
        undefined

    $("#reset").button()
    $("#reset").on "click", (event) ->
        game_of_life.reset()
        if play
            $("#play").click()
        undefined
    
    #That slider.
    min_hz = 0
    max_hz = 50
    $("#hz_slider").slider(
        min: min_hz
        max: max_hz
        value: 8
        step: 1
        slide: (event, ui) ->
            $("#hz").val ui.value
            game_of_life.setHz ui.value
            undefined
        change: (event, ui) ->
            $("#hz").val ui.value
            game_of_life.setHz ui.value
            undefined
        )
    $("#hz").on "change", (event) ->
        val = $("#hz").val()
        if isNaN(val)
            ui.val "NaN"
            return undefined
        val = parseInt(val)
        if val > max_hz then val = max_hz
        else if val < min_hz then val = min_hz
        $("#hz").val val
        $("#hz_slider").slider "value", val
        undefined

    # Setting the first help_pane tab as open, and showing the related
    # content
    $("div.tab_content:first").show()

    # Setting the callback for clicking on any element of the tab menu
    $("ul.tab_menu li").on "click", (event) ->
        # Make sure there aren't any currently open tabs and hide any
        # currently open content.
        $("ul.tab_menu li").removeClass("open")
        $(".tab_content").hide()
        # Add the `open` class to the selected tab.
        $(@).addClass("open")
        # Grab a handle to the tag referenced by the anchor in the tab
        # and fade that puppy in.
        activeTab = $(@).find("a").attr("href")
        $(activeTab).fadeIn()

        # Return False to stop propgation of the click event.
        false
    
    undefined
)