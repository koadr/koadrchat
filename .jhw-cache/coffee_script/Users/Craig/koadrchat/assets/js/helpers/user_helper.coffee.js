(function() {

  Interact.Helper.User = (function() {

    function User(user, messages, collection) {
      this.user = user;
      this.collection = collection;
    }

    User.prototype.simpleFormat = function(str) {
      str = str.replace(/\r\n?/, "\n");
      str = $.trim(str);
      if (str.length > 0) {
        str = str.replace(/\n\n+/g, "</p><p>");
        str = str.replace(/\n/g, "<br />");
        str = "<p>" + str + "</p>";
      }
      return str;
    };

    User.prototype.get_recent_msg = function(user) {
      var messages;
      if (user.get('messages').length === 0) {
        return "";
      } else {
        messages = user.get('messages');
        return messages[messages.length - 1].content;
      }
    };

    return User;

  })();

}).call(this);
