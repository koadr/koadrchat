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
      'focus #message_box': 'show_txt_msg_box',
      'click .share_msg_btn': 'add_message',
      'keyup #new_msg': 'char_countdown'
    };

    UsersIndex.prototype.initialize = function(collection, user, helper, online_users) {
      this.collection = collection;
      this.user = user;
      this.helper = helper;
      this.online_users = online_users;
      return this.collection.on('change', this.render, this);
    };

    UsersIndex.prototype.render = function() {
      $(this.el).html(this.template({
        recent_users: this.collection,
        current_user: this.user,
        helper: this.helper,
        online_users: this.online_users
      }));
      return this;
    };

    UsersIndex.prototype.show_txt_msg_box = function(event) {
      event.preventDefault();
      $('#message_box').remove();
      $('.new_message').css('height', 215);
      return $('#new_msg_text_box').toggle().focus();
    };

    UsersIndex.prototype.add_message = function(event) {
      var $content, input, messages, new_message, regex, topic_names, user,
        _this = this;
      event.preventDefault();
      $content = this.$('#new_msg').val();
      regex = /#\w+/gi;
      input = $content;
      topic_names = null;
      if (regex.test(input)) {
        topic_names = input.match(regex);
      }
      new_message = {
        content: $content,
        topic_names: topic_names
      };
      user = this.collection.filter(function(model) {
        return model.get('user_name') === _this.user;
      })[0];
      messages = user.get('messages');
      messages.push(new_message);
      if ($content.length > 0 && !($content.length > 150)) {
        return user.save();
      }
    };

    UsersIndex.prototype.char_countdown = function(event) {
      var $content, $share_btn, char_remaining;
      $content = this.$('#new_msg').val();
      $share_btn = this.$('.share_msg_btn');
      if ($content.length > 0 && $content.length <= 150) {
        $share_btn.removeClass("secondary tiny");
        $share_btn.addClass("medium");
      } else if (($content.length === 0) || ($content.length > 150)) {
        $share_btn.removeClass("medium");
        $share_btn.addClass("secondary tiny");
      }
      char_remaining = 150 - $content.length;
      if (char_remaining < 15) {
        return $('.char_count').html("<span class='red'>" + char_remaining + "</span>");
      } else {
        return $('.char_count').html("<span class='blue'>" + char_remaining + "</span>");
      }
    };

    return UsersIndex;

  })(Backbone.View);

}).call(this);
