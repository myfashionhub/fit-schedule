function Calendar() {

  var that = this;
  var container = $('.customize-wrapper .calendars');

  this.init = function() {
    container.find('.update').click(function() {
      that.updateUserCalendar();
    });

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
      var radioButton = $('<input>').attr('type', 'radio').
                          attr('name', 'calendar');

      if (cal.id === userCal) {
        radioButton.attr('checked', true);
      }

      item.append(radioButton).append(calName);
      list.append(item);
    }
  };

  this.updateUserCalendar = function() {
    var calendar_id = $('.all-calendars input[type="radio"]:checked').
                        parent().attr('data-id');

    $.ajax({
      url: '/users',
      type: 'PUT',
      data: { calendar_id: calendar_id },
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
