(function() {

  window.Interact = {
    Models: {},
    Collections: {},
    Views: {},
    Helper: {},
    init: function() {
      var topics_page, users_page;
      this.user = $('#user_name').data('user');
      this.online_users = $('#bootstrapped_online_users').data('online_users');
      this.users_collection = new Interact.Collections.Users();
      this.user_helper = new Interact.Helper.User(this.user, this.user_messages, this.users_collection);
      this.topic_helper = new Interact.Helper.Topic(this.topics_collection);
      this.users_collection.reset($('#bootstrapped_recent_users').data('recent_users'));
      this.topics_collection = new Interact.Collections.Topics();
      this.topics_collection.reset($('#bootstrapped_topics').data('topics'));
      users_page = new Interact.Views.UsersIndex(this.users_collection, this.user, this.user_helper, this.online_users);
      topics_page = new Interact.Views.TopicsIndex(this.topics_collection, this.topic_helper);
      $("#user_show").html(users_page.render().el);
      return $("#trending_topics").html(topics_page.render().el);
    }
  };

  $(document).ready(function() {
    return Interact.init();
  });

}).call(this);
