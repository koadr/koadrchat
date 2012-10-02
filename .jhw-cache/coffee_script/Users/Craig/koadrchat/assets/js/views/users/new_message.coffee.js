(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Interact.Views.NewMessage = (function(_super) {

    __extends(NewMessage, _super);

    function NewMessage() {
      return NewMessage.__super__.constructor.apply(this, arguments);
    }

    NewMessage.prototype.tagName = "form";

    NewMessage.prototype.initalize = function() {};

    NewMessage.prototype.template = jade.templates["new_message_form"];

    NewMessage.prototype.render = function() {
      $(this.el).html(this.template());
      return this;
    };

    return NewMessage;

  })(Backbone.View);

}).call(this);
