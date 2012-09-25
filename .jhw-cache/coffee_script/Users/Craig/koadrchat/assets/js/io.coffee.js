(function() {

  jQuery(function() {
    var log_chat_message, socket;
    log_chat_message = function(message, type) {
      var li;
      li = jQuery("<li />").text(message);
      if (type === "system") {
        li.css({
          "font-weight": "bold"
        });
      } else if (type === "leave") {
        li.css({
          "font-weight": "bold",
          color: "#F00"
        });
      }
      return jQuery("#chat_log").append(li);
    };
    socket = io.connect("/");
    socket.on("entrance", function(data) {
      return log_chat_message(data.message, "system");
    });
    socket.on("exit", function(data) {
      return log_chat_message(data.message, "leave");
    });
    socket.on("chat", function(data) {
      return log_chat_message(data.message, "normal");
    });
    return jQuery("#chat_box").keypress(function(event) {
      if (event.which === 13) {
        socket.emit("chat", {
          message: jQuery("#chat_box").val()
        });
        return jQuery("#chat_box").val("");
      }
    });
  });

}).call(this);
