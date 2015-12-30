//= require jquery
//= require underscore
//= require jquery_ujs
//= require_tree .

$(document).ready(function() {
  var customizeTabs = [ 'studio', 'availability', 'calendar' ];
  var scheduleTabs = [ 'classes', 'studios' ];
  window.customizeNav = new Navigation(
    customizeTabs, $('.customize-nav'), '.customize-wrapper section'
  );
  window.scheduleNav = new Navigation(
    scheduleTabs, $('.schedule-nav'), '.schedule-wrapper section'
  );

  listenForHashChange();
});

function listenForHashChange() {
  $(window).on('hashchange', function() {
    if ( window.location.pathname === '/customize' ) {
      window.customizeNav.toggleByHash();
    } else if ( window.location.pathname === '/schedule' ) {
      window.scheduleNav.toggleByHash();
    }
  });
}
