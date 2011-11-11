# This is identical to `$(document).ready([callback])`
$( ->
    window.game_of_life = GoL("#draw_space", $(window).width(), $(window).height()) 
    $(".movable_pane").draggable()
    $("#step").on "click", (event) ->
        game_of_life.step()
        undefined
    undefined
)