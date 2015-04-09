// Generated by CoffeeScript 1.9.1
var Slider,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Slider = (function() {
  Slider.prototype.sliderLocation = {};

  Slider.prototype.dragHandles = "<div class='grip'></div>";

  Slider.prototype.colMargin = 10;

  Slider.prototype.colData = {};

  Slider.prototype.colSorted = [];

  Slider.prototype.events = {
    "scrub": [],
    "update": []
  };

  function Slider(slider, colData) {
    var id, sliderInternal;
    this.colData = colData;
    this._deactivateSlider = bind(this._deactivateSlider, this);
    this._activateSlider = bind(this._activateSlider, this);
    this.removeCol = bind(this.removeCol, this);
    this.splitCol = bind(this.splitCol, this);
    this._rebuildCols = bind(this._rebuildCols, this);
    this._updateData = bind(this._updateData, this);
    this._scrubVideo = bind(this._scrubVideo, this);
    this.addEvent = bind(this.addEvent, this);
    if (!this.colData) {
      id = _.uniqueId("shot_");
      this.colData = {
        id: {
          CLASS: "default",
          CSS: {
            background: "grey"
          },
          CONTENT: "This is a default column. Check log for structure",
          RANGE: [0, 1]
        }
      };
      console.log(this.colData);
    }
    this.slider = $("<table><tr></tr></table>").appendTo($(slider));
    sliderInternal = this.slider.find("tr");
    this.sliderLocation = this.slider.offset();
    this.sliderLocation.width = this.slider.width();
    this._rebuildCols();
  }

  Slider.prototype.addEvent = function(name, callback) {
    if (_.isFunction(callback)) {
      return this.events[name].push(callback);
    }
  };

  Slider.prototype._scrubVideo = function(e) {
    var j, len, percent, ref, results, run;
    percent = (e.pageX - this.sliderLocation.left) / this.sliderLocation.width;
    if (percent > 1) {
      percent = 1;
    }
    if (percent < 0) {
      percent = 0;
    }
    ref = this.events["scrub"];
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      run = ref[j];
      results.push(run(percent));
    }
    return results;
  };

  Slider.prototype._updateData = function(e) {
    var col, columns, freshData, i, id, j, k, lastLoc, len, len1, px, ref, ref1, results, run;
    lastLoc = 0;
    freshData = {};
    this.colSorted = [];
    columns = $(this.slider).find("td");
    for (j = 0, len = columns.length; j < len; j++) {
      col = columns[j];
      id = $(col).attr("id");
      freshData[id] = $.extend({}, this.colData[id]);
      freshData[id].RANGE[0] = lastLoc;
      lastLoc += $(col).width();
      freshData[id].RANGE[1] = lastLoc;
      this.colSorted.push(id);
    }
    for (id in freshData) {
      col = freshData[id];
      ref = col.RANGE;
      for (i in ref) {
        px = ref[i];
        col.RANGE[i] = px / lastLoc;
      }
    }
    this.colData = freshData;
    ref1 = this.events["update"];
    results = [];
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      run = ref1[k];
      results.push(run(this.colData));
    }
    return results;
  };

  Slider.prototype._rebuildCols = function() {
    var column, id, j, k, len, len1, map, margin, rangeMap, ref, ref1, sliderInternal, val;
    this._deactivateSlider();
    sliderInternal = this.slider.find("tr");
    sliderInternal.html("");
    margin = (this.colMargin * 2) / this.sliderLocation.width;
    rangeMap = _.map(this.colData, function(value, key, list) {
      return value.RANGE[1];
    });
    rangeMap = _.sortBy(rangeMap);
    this.colSorted = [];
    for (j = 0, len = rangeMap.length; j < len; j++) {
      map = rangeMap[j];
      ref = this.colData;
      for (id in ref) {
        val = ref[id];
        if (val.RANGE[1] === map) {
          this.colSorted.push(id);
        }
      }
    }
    ref1 = this.colSorted;
    for (k = 0, len1 = ref1.length; k < len1; k++) {
      id = ref1[k];
      column = $("<td></td>").addClass(this.colData[id].CLASS).css(this.colData[id].CSS).html(this.colData[id].CONTENT).attr("id", id).width((this.colData[id].RANGE[1] - this.colData[id].RANGE[0]) * this.sliderLocation.width);
      sliderInternal.append(column);
    }
    return this._activateSlider();
  };

  Slider.prototype.splitCol = function(parent, data) {
    var baseRange, col, id, multiplier, previous, segment;
    this._updateData();
    if (typeof parent === "object") {
      parent = parent.attr("id");
    }
    multiplier = 0.5 / _.size(data);
    baseRange = this.colData[parent].RANGE[1] - this.colData[parent].RANGE[0];
    segment = baseRange * multiplier;
    previous = this.colData[parent].RANGE[0] + segment;
    this.colData[parent].RANGE[1] = previous;
    for (id in data) {
      col = data[id];
      col.RANGE = [];
      col.RANGE.push(previous);
      previous = previous + segment;
      col.RANGE.push(previous);
      this.colData[id] = col;
    }
    return this._rebuildCols();
  };

  Slider.prototype.removeCol = function(id) {
    var index, middle;
    this._updateData();
    if (typeof id === "object") {
      id = id.attr("id");
    }
    index = this.colSorted.indexOf(id);
    if (!index) {
      if (this.colSorted.length > 1) {
        this.colData[this.colSorted[1]].RANGE[0] = 0;
      } else {
        return alert("You cannot remove the last column.");
      }
    } else if (index === (this.colSorted.length - 1)) {
      this.colData[this.colSorted[this.colSorted.length - 2]].RANGE[1] = 1;
    } else {
      middle = ((this.colData[id].RANGE[1] - this.colData[id].RANGE[0]) * 0.5) + this.colData[id].RANGE[0];
      this.colData[this.colSorted[index - 1]].RANGE[1] = middle;
      this.colData[this.colSorted[index + 1]].RANGE[0] = middle;
    }
    delete this.colData[id];
    return this._rebuildCols();
  };

  Slider.prototype._activateSlider = function() {
    return this.slider.colResizable({
      liveDrag: true,
      fixed: true,
      gripInnerHtml: this.dragHandles,
      draggingClass: "grip-drag",
      onDrag: this._scrubVideo,
      onResize: this._updateData,
      minWidth: this.colMargin,
      hoverCursor: "col-resize",
      headerOnly: true
    });
  };

  Slider.prototype._deactivateSlider = function() {
    return this.slider.colResizable({
      disable: true
    });
  };

  return Slider;

})();
