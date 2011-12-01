# This is identical to `$(document).ready([callback])`
$( ->
    window.game_of_life = GoL("#draw_space", $(window).width(), $(window).height())

    ## UI Initialization and setup 
    $(".movable_pane").draggable()
    
    # Button on click event setup
    $("#step").on "click", (event) ->
        game_of_life.step()
        undefined
    $("#start").on "click", (event) ->
        game_of_life.start()
        undefined
    $("#stop").on "click", (event) ->
        game_of_life.stop()
        undefined
    $("#reset").on "click", (event) ->
        game_of_life.reset()
        undefined
    
    #Make me a slider!
    $("#hz_slide").slider(
        min: 4
        max: 50
        value: 8
        step: 1
        slide: (event, ui) ->
            $("#hz_value").text ui.value
            game_of_life.setHz ui.value
            undefined
        change: (event, ui) ->
            $("#hz_value").text ui.value
            game_of_life.setHz ui.value
            undefined
        )

    # Setting the first help_pane tab as open, and showing the related
    # content
    $("ul.tab_menu li:first").addClass("open")
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