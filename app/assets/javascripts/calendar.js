function Calendar() {

  var that = this;

  this.init = function() {
    // when calendar is chosen var calendarId = $('')
    // this.updateUserCalendar(calendarId);

    this.renderGrid();
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

  this.renderGrid = function() {
    var days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
    
    var hourLabel = $('<li>').addClass('hour-label');
    for (var i=0; i<24; i++) {
      var hour = $('<div>').html(twelveHours(i));
      hourLabel.append(hour);
    }
    $('.calendar').append(hourLabel);

    _.each(days, function(day) {
      var label = $('<div>').addClass('label').html(day);
      var dayLi = $('<li>').addClass('day').html(label);

      for (var i=0; i<24; i++) {
        var hour = $('<div>').addClass('hour').html('&nbsp;').
                     attr('data-hour', i.toString());
        dayLi.append(hour);
      }

      $('.calendar').append(dayLi);
    });

    this.customize();
  };

  this.customize = function() {
    $('.day .hour').click(function() {
      var cancel = $('<div>').addClass('cancel').html('x');
      var label = twelveHours(parseInt($(this).attr('data-hour')));
      $(this).html(label).append(cancel);
      $(this).addClass('busy').attr('tabIndex',0).focus();

      $(this).keydown(function(e) {
        var start = $(this);
        if (e.keyCode === 16) {
          $('.day .hour').click(function() {
            var end = $(this);
            highlight($(this).parent(), start, end);
          });
        }
      });
    });

    var highlight = function(dayLi, start, end) {
      var hours = dayLi.find('.hour');
      var startIdx = hours.index(start),
          endIdx = hours.index(end);

      for (var i=startIdx+1; i<endIdx; i++) {
        $(hours[i]).addClass('busy');
      }
    }
  };

  var twelveHours = function(num) {
    if (num === 0) {
      return '12 am'
    } else if (num < 12) {
      return num.toString() + ' am';
    } else if (num === 12) {
      return '12 pm'
    } else {
      return (num - 12).toString() + ' pm';
    }
  }

  this.init();

}
