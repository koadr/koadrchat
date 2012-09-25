(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Interact.Views.UsersIndex = (function(_super) {

    __extends(UsersIndex, _super);

    function UsersIndex() {
      return UsersIndex.__super__.constructor.apply(this, arguments);
    }

    UsersIndex.prototype.tagName = "li";

    UsersIndex.prototype.initalize = function() {};

    UsersIndex.prototype.template = jade.templates["users_index"]();

    UsersIndex.prototype.render = function() {
      $(this.el).html(this.template);
      return this;
    };

    return UsersIndex;

  })(Backbone.View);

}).call(this);
