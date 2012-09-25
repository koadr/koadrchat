(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Interact.Views.MessagesIndex = (function(_super) {

    __extends(MessagesIndex, _super);

    function MessagesIndex() {
      return MessagesIndex.__super__.constructor.apply(this, arguments);
    }

    MessagesIndex.prototype.tagName = "li";

    MessagesIndex.prototype.initalize = function() {};

    MessagesIndex.prototype.template = function() {};

    return MessagesIndex;

  })(Backbone.View);

}).call(this);
