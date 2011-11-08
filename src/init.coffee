# This is identical to `$(document).ready([callback])`
$( ->
    GridModel.init()
    GridView.init $(window).width(), $(window).height()
    UI.init()
    undefined
)