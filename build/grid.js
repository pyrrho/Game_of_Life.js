
  window.GridView = {
    _node_size: 30,
    init: function(width, height) {
      var _this = this;
      this.paper = Raphael('draw_space');
      this.drawGrid(width, height);
      $('#draw_space').mousedown(function(event) {
        var coord;
        coord = _this.pageToGrid(event.pageX, event.pageY);
        return GridController.onMouseDown(coord.x, coord.y);
      });
      return;
    },
    drawGrid: function(width, height) {
      var i, j, _ref, _ref2;
      this.width = width;
      this.height = height;
      this.node_cols = Math.ceil(this.width / this._node_size);
      this.node_rows = Math.ceil(this.height / this._node_size);
      this.paper.setSize(this.width, this.height);
      for (i = 0, _ref = this.node_cols; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        for (j = 0, _ref2 = this.node_rows; 0 <= _ref2 ? j <= _ref2 : j >= _ref2; 0 <= _ref2 ? j++ : j--) {
          this.paper.rect(i * this._node_size, j * this._node_size, this._node_size, this._node_size).attr('stroke-opacity', .2);
        }
      }
      return;
    },
    pageToGrid: function(x, y) {
      return {
        x: Math.floor(x / this._node_size),
        y: Math.floor(y / this._node_size)
      };
    }
  };

  window.GridController = {
    onMouseDown: function(x, y) {
      return alert("Mouse Down at: " + [x, y]);
    }
  };
