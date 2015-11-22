function Calendar() {

  var that = this;

  this.init = function() {
    // when calendar is chosen var calendarId = $('')
    // this.updateUserCalendar(calendarId);

  };

  this.get = function() {
    $.ajax({
      url: '/calendars',
      type: 'GET',
      success: function(data) {
        console.log(data);
        if ('error' in data) {
          window.alert(data.error);
          var session = new Session('/');
          session.destroy();
        } else {
          that.populateCalendars(data.calendars);
        }
      }
    });
  }

  this.addEvent = function() {
    // Get class id & save appointment
  };

  this.populateCalendars = function(calendars) {  
    var list = $('.all-calendars');

    for (var i = 0; i < calendars.length; i++) {
      var cal = calendars[i];
      var item = $('<li>').html(cal.summary).attr('data-id', cal.id);
      list.append(item);
    }
  };

  this.updateUserCalendar = function(calendarId) {
    $.ajax({
      url: '/users',
      type: 'PUT',
      data: {
        calendar_id: calendarId,
        availability: availability
      },
      success: function(data) {
        console.log(data);
      },
      error: function(err) {
        console.log(err); 
      }
    });
  };

  this.getCurrentCalendar = function() {
    // if null then prompt to select
  };

  this.init();

}
