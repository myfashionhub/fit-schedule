function Navigation(tabs, ul, sectionSelector) {

  var that = this;
  var navLinks = ul.find('a');
  var cal = new Calendar();

  this.init = function() {
    this.toggleByHash();

    navLinks.click(function(e) {
      var index = navLinks.index(e.target);
      that.toggle(index);
    });
  };

  this.toggleByHash = function() {
    if ( window.location.pathname !== '/customize' &&
         window.location.pathname !== '/schedule' ) {
      return;
    }

    if ( window.location.hash !== '' ) {
      var index = tabs.indexOf( window.location.hash.replace('#','') );
      if ( index > -1 ) {
        that.toggle(index);
        return;
      }
    }
    this.toggle(0);
  };

  this.toggle = function(index) {
    window.location.hash = '#' + tabs[index];

    $(sectionSelector+'.active').removeClass('active');
    ul.find('a.active').removeClass('active');

    $(navLinks[index]).addClass('active');
    var targetSection = $($(sectionSelector)[index]);
    targetSection.addClass('active');

    if (targetSection.hasClass('calendars')) {
      cal.getAllCalendars();
    } else if (targetSection.hasClass('availability')) {
      cal.getUserAvailability();
    }
  };

  this.init();
}
