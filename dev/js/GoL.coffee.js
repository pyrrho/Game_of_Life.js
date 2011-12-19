(function() {
  var GoL;

  GoL = function(canvas_element, width, height) {
    var anim_duration, cell, dying_color, gol, max_zoom, min_zoom, mouse_left, mouse_right, neighbor_set, node_size, raising_color, scroll_threshold, stroke_opacity, zoom_scalar, _ref;
    raising_color = "#005500";
    dying_color = "#550000";
    stroke_opacity = 0.2;
    anim_duration = 125;
    gol = {};
    gol.model = {};
    gol.view = {};
    gol.ctrl = {};
    cell = function(born) {
      return {
        birthday: born,
        deathday: -1,
        state: "born",
        neighbors: 0
      };
    };
    neighbor_set = [
      {
        x: 1,
        y: 0
      }, {
        x: 1,
        y: -1
      }, {
        x: 0,
        y: -1
      }, {
        x: -1,
        y: -1
      }, {
        x: -1,
        y: 0
      }, {
        x: -1,
        y: 1
      }, {
        x: 0,
        y: 1
      }, {
        x: 1,
        y: 1
      }
    ];
    gol.model.current_step = 0;
    gol.model.cell_count = 0;
    gol.model.live_cells = {};
    gol.model.fresh_cells = [];
    gol.model.raiseCell = function(x, y) {
      var _base, _ref;
      if ((_ref = (_base = this.live_cells)[x]) == null) _base[x] = {};
      this.live_cells[x][y] = cell(this.current_step);
      this.fresh_cells.push([x, y]);
      this.cell_count += 1;
      gol.view.addRect(x, y);
      return;
    };
    gol.model.killCell = function(x, y) {
      delete this.live_cells[x][y];
      if ($.isEmptyObject(this.live_cells[x])) delete this.live_cells[x];
      this.cell_count -= 1;
      gol.view.removeRect(x, y);
      return;
    };
    gol.model.isAliveAt = function(x, y) {
      var _ref;
      return ((_ref = this.live_cells[x]) != null ? _ref[y] : void 0) != null;
    };
    gol.model.step = function() {
      var cell, cell_col, neighbor, neighbor_count, seeds, x, x_string, y, y_string, _base, _i, _len, _name, _name2, _ref, _ref2, _ref3, _ref4, _ref5;
      this.current_step += 1;
      seeds = {};
      _ref = this.live_cells;
      for (x_string in _ref) {
        cell_col = _ref[x_string];
        for (y_string in cell_col) {
          cell = cell_col[y_string];
          x = parseInt(x_string);
          y = parseInt(y_string);
          for (_i = 0, _len = neighbor_set.length; _i < _len; _i++) {
            neighbor = neighbor_set[_i];
            if (((_ref2 = this.live_cells[x + neighbor.x]) != null ? _ref2[y + neighbor.y] : void 0) != null) {
              this.live_cells[x + neighbor.x][y + neighbor.y].neighbors += 1;
            } else {
              if ((_ref3 = seeds[_name = x + neighbor.x]) == null) {
                seeds[_name] = {};
              }
              if ((_ref4 = (_base = seeds[x + neighbor.x])[_name2 = y + neighbor.y]) == null) {
                _base[_name2] = 0;
              }
              seeds[x + neighbor.x][y + neighbor.y] += 1;
            }
          }
        }
      }
      _ref5 = this.live_cells;
      for (x_string in _ref5) {
        cell_col = _ref5[x_string];
        for (y_string in cell_col) {
          cell = cell_col[y_string];
          neighbor_count = cell.neighbors;
          if (neighbor_count !== 2 && neighbor_count !== 3) {
            x = parseInt(x_string);
            y = parseInt(y_string);
            this.killCell(x, y);
          } else {
            cell.neighbors = 0;
          }
        }
      }
      for (x_string in seeds) {
        cell_col = seeds[x_string];
        for (y_string in cell_col) {
          neighbor_count = cell_col[y_string];
          if (neighbor_count === 3) {
            x = parseInt(x_string);
            y = parseInt(y_string);
            this.raiseCell(x, y);
          }
        }
      }
      return;
    };
    gol.model.reset = function() {
      gol.model.current_step = 0;
      gol.model.cell_count = 0;
      return gol.model.live_cells = {};
    };
    node_size = 15;
    min_zoom = 0.2;
    max_zoom = 10;
    zoom_scalar = function() {
      return gol.view.current_zoom * 0.0025;
    };
    gol.view.paper = Raphael(canvas_element.slice(1));
    gol.view.rects = {};
    gol.view.width = 0;
    gol.view.height = 0;
    gol.view.current_zoom = 1;
    gol.view.scaled_node_size = node_size;
    gol.view.zoom_offset = {
      x: 0.5,
      y: 0.5
    };
    gol.view.offset = {
      x: 0,
      y: 0
    };
    gol.view.grid_offset = {
      x: 0,
      y: 0
    };
    gol.view.px_offset = {
      x: 0,
      y: 0
    };
    gol.view.resizeCanvas = function(width, height) {
      this.width = width;
      this.height = height;
      this.paper.setSize(this.width, this.height);
      this.drawGrid();
      return;
    };
    gol.view.setZoomOffset = function(page_x, page_y) {
      this.zoom_offset = {
        x: page_x / this.width,
        y: page_y / this.height
      };
      return;
    };
    gol.view.zoom = function(delta) {
      var current_zoom, old_zoom;
      old_zoom = this.current_zoom;
      this.current_zoom += zoom_scalar() * delta;
      if (this.current_zoom > max_zoom) {
        this.current_zoom = max_zoom;
      } else if (this.current_zoom < min_zoom) {
        this.current_zoom = min_zoom;
      }
      if (old_zoom !== this.current_zoom) {
        this.scaled_node_size = node_size * this.current_zoom;
        current_zoom = this.current_zoom;
        this.moveOffset(-(this.width / old_zoom - this.width / current_zoom) * this.zoom_offset.x, -(this.height / old_zoom - this.height / current_zoom) * this.zoom_offset.y, false);
      }
      return;
    };
    gol.view.moveOffset = function(delta_x, delta_y, scale) {
      var _this = this;
      if (scale == null) scale = true;
      if (scale) {
        this.offset.x += delta_x * (1 / this.current_zoom);
        this.offset.y += delta_y * (1 / this.current_zoom);
      } else {
        this.offset.x += delta_x;
        this.offset.y += delta_y;
      }
      this.grid_offset = {
        x: Math.floor((this.offset.x * this.current_zoom) / this.scaled_node_size),
        y: Math.floor((this.offset.y * this.current_zoom) / this.scaled_node_size)
      };
      this.px_offset = {
        x: (this.offset.x * this.current_zoom) % this.scaled_node_size,
        y: (this.offset.y * this.current_zoom) % this.scaled_node_size
      };
      if (this.px_offset.x < 0) this.px_offset.x += this.scaled_node_size;
      if (this.px_offset.y < 0) this.px_offset.y += this.scaled_node_size;
      _.defer(function() {
        return _this.drawGrid();
      });
      return;
    };
    gol.view.drawGrid = _.throttle((function() {
      var i, j, node_cols, node_rows, x, y, _ref, _ref2, _ref3, _ref4;
      this.paper.clear();
      this.rects = {};
      node_cols = 1 + Math.ceil(this.width / this.scaled_node_size);
      node_rows = 1 + Math.ceil(this.height / this.scaled_node_size);
      for (i = 0; 0 <= node_cols ? i <= node_cols : i >= node_cols; 0 <= node_cols ? i++ : i--) {
        this.paper.path(("M" + (i * this.scaled_node_size + this.px_offset.x) + ",0") + ("L" + (i * this.scaled_node_size + this.px_offset.x) + "," + this.height)).attr({
          "stroke-opacity": .2
        });
      }
      for (j = 0; 0 <= node_rows ? j <= node_rows : j >= node_rows; 0 <= node_rows ? j++ : j--) {
        this.paper.path(("M0," + (j * this.scaled_node_size + this.px_offset.y)) + ("L" + this.width + "," + (j * this.scaled_node_size + this.px_offset.y))).attr({
          "stroke-opacity": .2
        });
      }
      for (x = _ref = 0 - this.grid_offset.x, _ref2 = node_cols - this.grid_offset.x; _ref <= _ref2 ? x < _ref2 : x > _ref2; _ref <= _ref2 ? x++ : x--) {
        if (gol.model.live_cells[x] != null) {
          for (y = _ref3 = 0 - this.grid_offset.y, _ref4 = node_rows - this.grid_offset.y; _ref3 <= _ref4 ? y < _ref4 : y > _ref4; _ref3 <= _ref4 ? y++ : y--) {
            if (gol.model.live_cells[x][y] != null) this.drawRect(x, y);
          }
        }
      }
      return;
    }), 3);
    gol.view.addRect = function(x, y) {
      var grid_x, grid_y, _base, _base2, _ref, _ref2;
      grid_x = x + this.grid_offset.x;
      grid_y = y + this.grid_offset.y;
      if ((_ref = (_base = this.rects)[grid_x]) == null) _base[grid_x] = {};
      if ((_ref2 = (_base2 = this.rects[grid_x])[grid_y]) == null) {
        _base2[grid_y] = this.paper.rect(grid_x * this.scaled_node_size + this.px_offset.x, grid_y * this.scaled_node_size + this.px_offset.y, this.scaled_node_size, this.scaled_node_size, this.scaled_node_size / 5).attr({
          "fill": raising_color,
          "stroke-opacity": 0.2,
          "transform": "S0.0",
          "opacity": 0
        }).animate({
          "transform": "S1.0",
          "opacity": 1,
          "stroke-width": 1
        }, anim_duration);
      }
      return;
    };
    gol.view.drawRect = function(x, y) {
      var grid_x, grid_y, _base, _base2, _ref, _ref2;
      grid_x = x + this.grid_offset.x;
      grid_y = y + this.grid_offset.y;
      if ((_ref = (_base = this.rects)[grid_x]) == null) _base[grid_x] = {};
      return (_ref2 = (_base2 = this.rects[grid_x])[grid_y]) != null ? _ref2 : _base2[grid_y] = this.paper.rect(grid_x * this.scaled_node_size + this.px_offset.x, grid_y * this.scaled_node_size + this.px_offset.y, this.scaled_node_size, this.scaled_node_size, this.scaled_node_size / 5).attr({
        "fill": raising_color,
        "stroke-opacity": 0.2,
        "stroke-width": 1
      });
    };
    gol.view.removeRect = function(x, y) {
      var grid_x, grid_y, _ref;
      grid_x = x + this.grid_offset.x;
      grid_y = y + this.grid_offset.y;
      if (((_ref = this.rects[grid_x]) != null ? _ref[grid_y] : void 0) != null) {
        this.rects[grid_x][grid_y].attr({
          "fill": dying_color
        }).animate({
          "opacity": 0,
          "transform": "S0.0"
        }, anim_duration);
        _.delay((function(rect) {
          if (rect.node.parentNode != null) rect.remove();
          return;
        }), anim_duration, this.rects[grid_x][grid_y]);
        delete this.rects[grid_x][grid_y];
        if ($.isEmptyObject(this.rects[grid_x])) delete this.rects[grid_x];
      }
      return;
    };
    gol.view.pageToGrid = function(page_x, page_y) {
      return {
        x: Math.floor((page_x - this.px_offset.x) / this.scaled_node_size),
        y: Math.floor((page_y - this.px_offset.y) / this.scaled_node_size)
      };
    };
    gol.view.pageToAbs = function(page_x, page_y) {
      return {
        x: Math.floor((page_x - this.px_offset.x) / this.scaled_node_size) - this.grid_offset.x,
        y: Math.floor((page_y - this.px_offset.y) / this.scaled_node_size) - this.grid_offset.y
      };
    };
    scroll_threshold = 5;
    _ref = [0, 2], mouse_left = _ref[0], mouse_right = _ref[1];
    gol.ctrl.action = "cell";
    gol.ctrl.place_action = "raise";
    gol.ctrl.drag_start = {
      x: 0,
      y: 0
    };
    gol.ctrl.page_last = {
      x: 0,
      y: 0
    };
    gol.ctrl.abs_last = {
      x: 0,
      y: 0
    };
    gol.ctrl.moving = false;
    gol.ctrl.hz = 4;
    gol.ctrl.running = void 0;
    gol.ctrl.resolveMousedown = function(page_x, page_y, button) {
      var abs;
      this.page_last = {
        x: page_x,
        y: page_y
      };
      abs = gol.view.pageToAbs(page_x, page_y);
      if (this.action === "cell") {
        if (gol.model.isAliveAt(abs.x, abs.y)) {
          gol.model.killCell(abs.x, abs.y);
          this.place_action = "kill";
        } else {
          gol.model.raiseCell(abs.x, abs.y);
          this.place_action = "raise";
        }
        this.abs_last = {
          x: abs.x,
          y: abs.y
        };
      } else {
        gol.view.setZoomOffset(page_x, page_y);
      }
      return;
    };
    gol.ctrl.resolveMouseup = function() {
      this.moving = false;
      return;
    };
    gol.ctrl.resolveMousemove = function(page_x, page_y) {
      var abs, delta_x, delta_y;
      delta_x = this.page_last.x - page_x;
      delta_y = this.page_last.y - page_y;
      if (!this.moving && Math.abs(delta_x) + Math.abs(delta_y) > scroll_threshold) {
        this.moving = true;
        this.drag_start = {
          x: this.page_last.x,
          y: this.page_last.y
        };
      }
      if (this.moving) {
        if (this.action === "cell") {
          abs = gol.view.pageToAbs(page_x, page_y);
          if (abs.x !== this.abs_last.x || abs.y !== this.abs_last.y) {
            this.abs_last = {
              x: abs.x,
              y: abs.y
            };
            if (this.place_action === "raise") {
              gol.model.raiseCell(abs.x, abs.y);
            } else if (gol.model.isAliveAt(abs.x, abs.y)) {
              gol.model.killCell(abs.x, abs.y);
            }
          }
        } else if (this.action === "move") {
          gol.view.moveOffset(-delta_x, -delta_y);
        } else {
          gol.view.zoom(delta_y);
        }
        this.page_last.x = page_x;
        this.page_last.y = page_y;
      }
      return;
    };
    gol.ctrl.setHz = function(hz) {
      var _this = this;
      this.hz = hz;
      anim_duration = 1000 / (2 * gol.ctrl.hz);
      if (anim_duration > 200) {
        anim_duration = 200;
      } else if (anim_duration < 30) {
        anim_duration = 0;
      }
      if (this.running != null) {
        clearTimeout(this.running);
        this.running = setInterval((function() {
          return gol.model.step();
        }), 1000 / this.hz);
      }
      return;
    };
    gol.ctrl.start = function() {
      var _ref2;
      var _this = this;
      if ((_ref2 = this.running) == null) {
        this.running = setInterval((function() {
          return gol.model.step();
        }), 1000 / this.hz);
      }
      return;
    };
    gol.ctrl.stop = function() {
      clearTimeout(this.running);
      delete this.running;
      return;
    };
    gol.ctrl.reset = function() {
      return this.stop();
    };
    (function() {
      var $raphael;
      var _this = this;
      $raphael = $(canvas_element);
      $raphael.on("mousedown", function(event) {
        if (event.button !== 0) return true;
        gol.ctrl.resolveMousedown(event.pageX, event.pageY);
        $raphael.on("mousemove", function(event) {
          gol.ctrl.resolveMousemove(event.pageX, event.pageY);
          return false;
        });
        return false;
      });
      $(window).on("mouseup", function(event) {
        if (event.button !== 0) return true;
        gol.ctrl.resolveMouseup();
        $raphael.off("mousemove");
        return false;
      });
      $(window).on("resize", _.debounce((function() {
        gol.view.resizeCanvas($(window).width(), $(window).height());
        return true;
      }), 90));
      return true;
    })();
    gol.step = function() {
      gol.model.step();
      return;
    };
    gol.start = function() {
      return gol.ctrl.start();
    };
    gol.stop = function() {
      return gol.ctrl.stop();
    };
    gol.setHz = function(hz) {
      return gol.ctrl.setHz(hz);
    };
    gol.reset = function() {
      gol.ctrl.reset();
      gol.model.reset();
      gol.view.drawGrid();
      return;
    };
    gol.setAction = function(action) {
      return gol.ctrl.action = action;
    };
    gol.view.resizeCanvas(width, height);
    return gol;
  };

  $(function() {
    var $interaction_cell, $interaction_move, $interaction_zoom, max_hz, min_hz, play, shift_is_down, space_is_down;
    window.game_of_life = GoL("#draw_space", $(window).width(), $(window).height());
    $(".movable_pane").draggable({
      cancel: ".no_drag"
    });
    $("#hide").on("click", function(event) {
      $("#help_pane").slideUp();
      return;
    });
    $("#simulation_set").buttonset();
    $("#interaction_set").buttonset();
    play = false;
    $("#play").button();
    $("#play").on("click", function(event) {
      if (!play) {
        play = true;
        $("#play").attr("value", "Pause");
        $("#play").addClass("ui-state-active");
        game_of_life.start();
      } else {
        play = false;
        $("#play").attr("value", "Play");
        $("#play").removeClass("ui-state-active");
        game_of_life.stop();
      }
      return;
    });
    $("#step").on("click", function(event) {
      game_of_life.step();
      return;
    });
    $("#reset").on("click", function(event) {
      game_of_life.reset();
      if (play) $("#play").click();
      return;
    });
    min_hz = 1;
    max_hz = 50;
    $("#hz_slider").slider({
      min: min_hz,
      max: max_hz,
      value: 4,
      step: 1,
      slide: function(event, ui) {
        $("#hz").val(ui.value);
        game_of_life.setHz(ui.value);
        return;
      },
      change: function(event, ui) {
        $("#hz").val(ui.value);
        game_of_life.setHz(ui.value);
        return;
      }
    });
    $("#hz").on("change", function(event) {
      var val;
      val = $("#hz").val();
      if (isNaN(val)) {
        $("#hz").val("NaN");
        return;
      }
      val = parseInt(val);
      if (val > max_hz) {
        val = max_hz;
      } else if (val < min_hz) {
        val = min_hz;
      }
      $("#hz").val(val);
      $("#hz_slider").slider("value", val);
      return;
    });
    $interaction_cell = $("#interaction_cell");
    $interaction_cell.on("click", function(event) {
      game_of_life.setAction("cell");
      return $("#draw_space").css("cursor", "default");
    });
    $interaction_move = $("#interaction_move");
    $interaction_move.on("click", function(event) {
      game_of_life.setAction("move");
      return $("#draw_space").css("cursor", "move");
    });
    $interaction_zoom = $("#interaction_zoom");
    $interaction_zoom.on("click", function(event) {
      game_of_life.setAction("zoom");
      return $("#draw_space").css("cursor", "n-resize");
    });
    shift_is_down = false;
    space_is_down = false;
    $(window).on("keydown", function(event) {
      if (event.which === 32) {
        space_is_down = true;
        $interaction_move.click();
      } else if (event.which === 16) {
        shift_is_down = true;
        $interaction_zoom.click();
      }
      return;
    });
    $(window).on("keyup", function(event) {
      if (event.which === 32) {
        space_is_down = false;
      } else if (event.which === 16) {
        shift_is_down = false;
      }
      if (shift_is_down) {
        $interaction_zoom.click();
      } else if (space_is_down) {
        $interaction_move.click();
      } else {
        $interaction_cell.click();
      }
      return;
    });
    $("div.tab_content:first").show();
    $("ul.tab_menu li").on("click", function(event) {
      var activeTab;
      $("ul.tab_menu li").removeClass("open");
      $(".tab_content").hide();
      $(this).addClass("open");
      activeTab = $(this).find("a").attr("href");
      $(activeTab).fadeIn();
      return false;
    });
    return;
  });

}).call(this);
