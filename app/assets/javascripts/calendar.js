function Calendar() {

  var that = this;

  this.init = function() {
    // when calendar is chosen var calendarId = $('')
    // this.updateUserCalendar(calendarId);

  };

  this.getAllCalendars = function() {
    $.ajax({
      url: '/calendars',
      type: 'GET',
      success: function(data) {
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
    var userCal = $('#user').attr('data-calendar');

    for (var i = 0; i < calendars.length; i++) {
      var cal = calendars[i];
      var item = $('<li>').attr('data-id', cal.id);
      var calName = $('<span>').addClass('name').html(cal.summary);
      var checkbox;

      if (cal.summary === userCal) {
        checkbox = $('<i class="fa fa-check-square-o"></i>');
      } else {
        checkbox = $('<i class="fa fa-square-o"></i>');
      }

      item.append(checkbox).append(calName);
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

  this.getUserCalendar = function() {
    var calendar_id = $('#user').attr('data-calendar');
    if (calendar_id == undefined) {
      // prompt to select
      this.getAllCalendars();
    }

  };

  this.init();

}
