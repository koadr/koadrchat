(function() {

  window.Interact = {
    Models: {},
    Collections: {},
    Views: {},
    Helper: {},
    init: function() {
      var users_page;
      this.collection = new Interact.Collections.User();
      this.collection.reset($('#bootstrapped_users').data('messages'));
      users_page = new Interact.Views.UsersIndex({
        collection: this.collection
      });
      return $("#user_enter").html(users_page.render().el);
    }
  };

  $(document).ready(function() {
    return Interact.init();
  });

}).call(this);
