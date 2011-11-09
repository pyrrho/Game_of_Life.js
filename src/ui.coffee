window.UI =
    init: () ->
        $(".movable_pane").draggable()
        $("#step").on "click", (event) ->
            GridModel.step()
            undefined
        undefined