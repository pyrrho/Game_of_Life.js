window.GridView = {
    node_size: 30,

    init: function(width, height) {
        self = this;
        //Set up the Rapgael paper (canvas)
        self.paper = Raphael('draw_space');

        //Capture browser events
        $('#draw_space').mousedown(function(event) {
            coord = self.pageToGrid(event.pageX, event.pageY);
            GridController.onMouseDown(coord.x, coord.y);
        });

        //Set the initial size of the paper
        self.setSize(width, height);
    },

    setSize: function(width, height) {
        var node_size = this.node_size,
            nodes_rows, nodes_cols,
            i, j;

        //Store variables for later use
        this.width = width;
        this.height = height;
        this.node_cols = nodes_cols = Math.ceil(width / node_size);
        this.node_rows = nodes_rows = Math.ceil(height / node_size);

        //Set the paper size to that of the screen
        this.paper.setSize(width, height);

        //Draw them Rects
        for (i = 0; i < nodes_cols; i++) {
            for (j = 0; j < nodes_rows; j++) {
                rect = this.paper.rect(i*node_size, j*node_size,
                                       node_size, node_size);
                rect.attr('stroke-opacity', .2);
            }
        };
    },

    pageToGrid: function(x, y) {
        return {
            x: Math.floor(x / this.node_size),
            y: Math.floor(y / this.node_size)
        };
    },
};

window.GridController = {
    onMouseDown: function(x, y) {
        alert("Mouse Down at: " + [x, y]);
    },
};