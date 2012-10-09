(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Interact.Views.UsersIndex = (function(_super) {

    __extends(UsersIndex, _super);

    function UsersIndex() {
      return UsersIndex.__super__.constructor.apply(this, arguments);
    }

    UsersIndex.prototype.className = 'row';

    UsersIndex.prototype.template = jade.templates["users_index"];

    UsersIndex.prototype.events = {
      'focus .message_box': 'show_message_dropdown'
    };

    UsersIndex.prototype.initalize = function() {};

    UsersIndex.prototype.render = function() {
      $(this.el).html(this.template({
        users: this.collection
      }));
      return this;
    };

    UsersIndex.prototype.show_message_dropdown = function(event) {
      var new_message_view;
      event.preventDefault();
      new_message_view = new Interact.Views.NewMessage();
      $('.message_box').remove();
      $('input').removeClass('.message_box');
      $('.new_message').append(new_message_view.render().el);
      $('.new_message').css('height', 215);
      return $('.new_message textarea').focus();
    };

    return UsersIndex;

  })(Backbone.View);

}).call(this);
