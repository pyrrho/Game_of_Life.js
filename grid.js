window.GridView = {
    node_size: 30,

    init: function (width, height) {
        var node_size = this.node_size,
            nodes_hrz,
            nodes_vrt,
            i, j;

        this.paper = Raphael('draw_space');

        nodes_hrz = Math.ceil(width / node_size);
        nodes_vrt = Math.ceil(height / node_size);

        this.paper.setSize(nodes_hrz*node_size, nodes_vrt*node_size);

        for (i = 0; i < nodes_hrz; i++) {
            for (j = 0; j < nodes_hrz; j++) {
                rect = this.paper.rect(i*node_size, j*node_size,
                                       node_size, node_size);
                rect.attr('stroke-opacity', .2)

            }
        }
    },
};