//= require jquery
//= require underscore
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  var customizeTabs = [ 'studios', 'availability', 'calendar' ];

  window.customizeNav = new Navigation(
    '/customize', customizeTabs, $('.customize-nav'), '.customize-wrapper section'
  );
});
