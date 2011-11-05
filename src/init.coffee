# This is identical to `$(document).ready([callback])`
$( ->
    GridView.init $(window).width(), $(window).height()
    UI.init()
    return this
)