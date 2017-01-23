function Calendar() {

  var that = this;
  var container = $('.customize-wrapper .calendars');
  var user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.init = function() {
    container.find('.update').click(function() {
      that.update();
    });
  };

  this.getAllCalendars = function() {
    $.ajax({
      url: '/calendars',
      type: 'GET',
      success: function(data) {
        if ('error' in data) {
          notify.build(data.error, 'error');
          setTimeout(function() {
            var session = new Session('/');
            session.destroy();
          }, 1500);
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
    $('.all-calendars').empty();

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
      $('.all-calendars').append(item);
    }
  };

  this.update = function(attribute) {
    var calendar_id = $('.all-calendars input[type="radio"]:checked').
                      parent().attr('data-id');
    var data = { calendar_id: calendar_id }

    var user = new User(user_id);
    user.update(data);
  };

  this.init();

}
