# This is identical to `$(document).ready([callback])`
$( ->
    window.game_of_life = GoL("#draw_space", $(window).width(), $(window).height()) 
    $(".movable_pane").draggable()
    $("#step").on "click", (event) ->
        game_of_life.step()
        undefined

    $("ul.tab_menu li:first").addClass("active")
    $("div.tab_content:first").show()

    $("ul.tab_menu li").on "click", (event) ->
        $("ul.tab_menu li").removeClass("active") #Remove any "active" class
        $(@).addClass("active") #Add "active" class to selected tab
        $(".tab_content").hide() #Hide all tab content
        activeTab = $(@).find("a").attr("href") #Find the rel attribute value to identify the active tab + content
        $(activeTab).fadeIn()
        false
    undefined
)