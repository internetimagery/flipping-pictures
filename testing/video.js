// Generated by CoffeeScript 1.9.1
"use strict";
var Video,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Video = (function() {
  Video.prototype.vendor = "";

  Video.prototype.videoDuration = 0;

  Video.prototype.aspectRatio = 0;

  function Video(source, url, callback) {
    this._resize = bind(this._resize, this);
    this.scrub = bind(this.scrub, this);
    this.player = $(source);
    this.path = this._parseURL(url);
    this.player.html("");
    if (this.path.scheme === "https") {
      this.path.scheme = "http";
      this.path.source = this.path.source.replace(/^https?/, "http");
    }
    if (this.path.host.match(/vimeo.com/) && (this.path.path != null)) {
      this.vendor = "vimeo";
      this._loadVimeo(callback);
    }
    if (this.path.host.match(/youtu.?be/) && (this.path.path != null)) {
      this.vendor = "youtube";
      this._loadYoutube(callback);
    }
  }

  Video.prototype.scrub = function(time) {
    if ((0 < time && time < this.videoDuration)) {
      if (this.vendor = "vimeo") {
        this.vimeoAPI.api('seekTo', time);
        return this.vimeoAPI.api('pause');
      }
    }
  };

  Video.prototype._loadYoutube = function(callback) {
    var id, params, url;
    id = _.uniqueId("player_");
    url = "http://www.youtube.com/oembed";
    params = {
      url: this.path.source,
      format: "json"
    };
    this._crossDomainLoad(url + "?" + ($.param(params)), (function(_this) {
      return function(data) {
        _this.aspectRatio = data.height / data.width;
        _this.playerFrame = $(data.html).appendTo(_this.player);
        _this.playerFrame.attr("id", id);
        _this._resize();
        _this.player.resize(_this._resize);
        $("#output").text(JSON.stringify(data, null, "    "));
        return callback();
      };
    })(this));
    return console.log("youtube not yet supported");
  };

  Video.prototype._loadVimeo = function(callback) {
    var id, params, url;
    id = _.uniqueId("player_");
    url = "http://vimeo.com/api/oembed.json";
    params = {
      url: this.path.source,
      api: true,
      player_id: id,
      portrait: false,
      title: false,
      byline: false
    };
    return $.get(url, params, (function(_this) {
      return function(data) {
        _this.aspectRatio = data.height / data.width;
        _this.videoDuration = data.duration;
        _this.playerFrame = $(data.html).appendTo(_this.player);
        _this.playerFrame.attr("id", id);
        _this._resize();
        _this.player.resize(_this._resize);
        _this.vimeoAPI = $f(_this.playerFrame[0]);
        return _this.vimeoAPI.addEvent("ready", function(event, element) {
          return callback();
        });
      };
    })(this));
  };

  Video.prototype._resize = function() {
    var height;
    height = this.player.width() * this.aspectRatio;
    this.playerFrame.width(this.player.width());
    this.playerFrame.height(height);
    return this.player.height(height);
  };

  Video.prototype._parseURL = function(url) {
    var dom;
    dom = document.createElement("a");
    dom.href = url;
    return {
      source: url,
      scheme: dom.protocol.substr(0, dom.protocol.indexOf(":")),
      host: dom.hostname,
      port: dom.port,
      path: dom.pathname.match(/\/?(.*)/)[1],
      query: dom.search.substr(dom.search.indexOf("?") + 1),
      hash: dom.hash.substr(dom.hash.indexOf("#"))
    };
  };

  Video.prototype._crossDomainLoad = function(url, callback) {
    return $.get("http://query.yahooapis.com/v1/public/yql", {
      q: "select * from json where url = \"" + url + "\"",
      format: "json"
    }, function(data) {
      if (data.query.results) {
        return callback(data.query.results.json);
      }
    });
  };

  return Video;

})();
