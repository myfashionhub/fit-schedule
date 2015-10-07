function Calendar() {

  var that = this;

  this.init = function() {

  };

  this.get = function() {
    $.ajax({
      url: '/calendars',
      type: 'GET',
      success: function(data) {
        console.log(data);
        that.populateCalendars(data.calendars)
      }
    });
  }

  this.show = function() {

  };

  this.populateCalendars = function(calendars) {
    var list = $('.all-calendars');

    for (var i = 0; i < calendars.length; i++) {
      var cal = calendars[i];
      var item = $('<li>').html(cal.summary).attr('data-id', cal.id);
      list.append(item);
    }
  };

  this.init();

}
