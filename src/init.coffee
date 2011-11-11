# This is identical to `$(document).ready([callback])`
$( ->
    window.GridModel = GoL.model()
    window.GridView = GoL.view("draw_space", $(window).width(), $(window).height())
    window.GridController = GoL.controller()
    UI.init()
    undefined
)