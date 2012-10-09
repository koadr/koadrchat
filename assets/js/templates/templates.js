
jade = (function(exports){
/*!
 * Jade - runtime
 * Copyright(c) 2010 TJ Holowaychuk <tj@vision-media.ca>
 * MIT Licensed
 */

/**
 * Lame Array.isArray() polyfill for now.
 */

if (!Array.isArray) {
  Array.isArray = function(arr){
    return '[object Array]' == Object.prototype.toString.call(arr);
  };
}

/**
 * Lame Object.keys() polyfill for now.
 */

if (!Object.keys) {
  Object.keys = function(obj){
    var arr = [];
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        arr.push(key);
      }
    }
    return arr;
  }
}

/**
 * Merge two attribute objects giving precedence
 * to values in object `b`. Classes are special-cased
 * allowing for arrays and merging/joining appropriately
 * resulting in a string.
 *
 * @param {Object} a
 * @param {Object} b
 * @return {Object} a
 * @api private
 */

exports.merge = function merge(a, b) {
  var ac = a['class'];
  var bc = b['class'];

  if (ac || bc) {
    ac = ac || [];
    bc = bc || [];
    if (!Array.isArray(ac)) ac = [ac];
    if (!Array.isArray(bc)) bc = [bc];
    ac = ac.filter(nulls);
    bc = bc.filter(nulls);
    a['class'] = ac.concat(bc).join(' ');
  }

  for (var key in b) {
    if (key != 'class') {
      a[key] = b[key];
    }
  }

  return a;
};

/**
 * Filter null `val`s.
 *
 * @param {Mixed} val
 * @return {Mixed}
 * @api private
 */

function nulls(val) {
  return val != null;
}

/**
 * Render the given attributes object.
 *
 * @param {Object} obj
 * @param {Object} escaped
 * @return {String}
 * @api private
 */

exports.attrs = function attrs(obj, escaped){
  var buf = []
    , terse = obj.terse;

  delete obj.terse;
  var keys = Object.keys(obj)
    , len = keys.length;

  if (len) {
    buf.push('');
    for (var i = 0; i < len; ++i) {
      var key = keys[i]
        , val = obj[key];

      if ('boolean' == typeof val || null == val) {
        if (val) {
          terse
            ? buf.push(key)
            : buf.push(key + '="' + key + '"');
        }
      } else if (0 == key.indexOf('data') && 'string' != typeof val) {
        buf.push(key + "='" + JSON.stringify(val) + "'");
      } else if ('class' == key && Array.isArray(val)) {
        buf.push(key + '="' + exports.escape(val.join(' ')) + '"');
      } else if (escaped && escaped[key]) {
        buf.push(key + '="' + exports.escape(val) + '"');
      } else {
        buf.push(key + '="' + val + '"');
      }
    }
  }

  return buf.join(' ');
};

/**
 * Escape the given string of `html`.
 *
 * @param {String} html
 * @return {String}
 * @api private
 */

exports.escape = function escape(html){
  return String(html)
    .replace(/&(?!(\w+|\#\d+);)/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
};

/**
 * Re-throw the given `err` in context to the
 * the jade in `filename` at the given `lineno`.
 *
 * @param {Error} err
 * @param {String} filename
 * @param {String} lineno
 * @api private
 */

exports.rethrow = function rethrow(err, filename, lineno){
  if (!filename) throw err;

  var context = 3
    , str = require('fs').readFileSync(filename, 'utf8')
    , lines = str.split('\n')
    , start = Math.max(lineno - context, 0)
    , end = Math.min(lines.length, lineno + context);

  // Error context
  var context = lines.slice(start, end).map(function(line, i){
    var curr = i + start + 1;
    return (curr == lineno ? '  > ' : '    ')
      + curr
      + '| '
      + line;
  }).join('\n');

  // Alter exception message
  err.path = filename;
  err.message = (filename || 'Jade') + ':' + lineno
    + '\n' + context + '\n\n' + err.message;
  throw err;
};

  return exports;

})({});

jade.templates = {};
jade.render = function(node, template, data) {
  var tmp = jade.templates[template](data);
  node.innerHTML = tmp;
};

jade.templates["templates.js"] = function(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
}
return buf.join("");
}
jade.templates["topics_index"] = function(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div class="trending_box"><h3 class="capitalize trending_header">Trending on Koadr</h3>');
// iterate trending_topics.models
;(function(){
  if ('number' == typeof trending_topics.models.length) {
    for (var $index = 0, $$l = trending_topics.models.length; $index < $$l; $index++) {
      var topic = trending_topics.models[$index];

buf.push('<li>');
var __val__ = topic.get('_id')
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</li>');
    }
  } else {
    for (var $index in trending_topics.models) {
      var topic = trending_topics.models[$index];

buf.push('<li>');
var __val__ = topic.get('_id')
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</li>');
   }
  }
}).call(this);

buf.push('</div>');
}
return buf.join("");
}
jade.templates["users_index"] = function(locals, attrs, escape, rethrow, merge) {
attrs = attrs || jade.attrs; escape = escape || jade.escape; rethrow = rethrow || jade.rethrow; merge = merge || jade.merge;
var buf = [];
with (locals || {}) {
var interp;
buf.push('<div class="six columns"><div class="new_message"><img src="/images/default_profile.png"/><input id="message_box" type="text" placeholder="Share what\'s new..." class="nine"/><form id="new_msg_text_box"><li><a href="">');
var __val__ = "@" + current_user
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</a></li><p>View Your Profile</p><p class="char_count">150</p><textarea id="new_msg" type="text" placeholder="Share what\'s new..." class="nine"></textarea><a href="#" class="tiny share_msg_btn secondary radius button">Share</a></form></div>');
// iterate recent_users.models
;(function(){
  if ('number' == typeof recent_users.models.length) {
    for (var $index = 0, $$l = recent_users.models.length; $index < $$l; $index++) {
      var user = recent_users.models[$index];

buf.push('<div class="latest_messages"><img src="/images/default_profile.png" class="mini_profile_pic"/><a href="#">');
var __val__ = "@" + user.get('user_name')
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</a><p>');
var __val__ = helper.get_recent_msg(user)
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</p></div>');
    }
  } else {
    for (var $index in recent_users.models) {
      var user = recent_users.models[$index];

buf.push('<div class="latest_messages"><img src="/images/default_profile.png" class="mini_profile_pic"/><a href="#">');
var __val__ = "@" + user.get('user_name')
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</a><p>');
var __val__ = helper.get_recent_msg(user)
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</p></div>');
   }
  }
}).call(this);

buf.push('</div><div class="four columns end"><div class="chatroom"><div class="chatroom_header"><img src="/images/online_true.png"/><a href="#">');
var __val__ = "@" + current_user
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</a></div>');
// iterate online_users
;(function(){
  if ('number' == typeof online_users.length) {
    for (var $index = 0, $$l = online_users.length; $index < $$l; $index++) {
      var user = online_users[$index];

if ( user.user_name != current_user)
{
buf.push('<div class="chat_row"><img src="/images/default_profile_min.png"/><img');
buf.push(attrs({ 'src':("/images/online_" + (user.online) + ".png") }, {"src":true}));
buf.push('/><li>');
var __val__ = user.user_name
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</li></div>');
}
    }
  } else {
    for (var $index in online_users) {
      var user = online_users[$index];

if ( user.user_name != current_user)
{
buf.push('<div class="chat_row"><img src="/images/default_profile_min.png"/><img');
buf.push(attrs({ 'src':("/images/online_" + (user.online) + ".png") }, {"src":true}));
buf.push('/><li>');
var __val__ = user.user_name
buf.push(escape(null == __val__ ? "" : __val__));
buf.push('</li></div>');
}
   }
  }
}).call(this);

buf.push('</div></div>');
}
return buf.join("");
}