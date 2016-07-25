function Calendar() {

  var that = this;
  var container = $('.customize-wrapper .calendars');
  var user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.init = function() {
    container.find('.update').click(function() {
      that.updateUser('calendar');
    });

    $('.customize-wrapper .availability .add').click(function() {
      that.buildTimeBlock();
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

  this.updateUser = function(attribute) {
    var data;

    if (attribute === 'calendar') {
      var calendar_id = $('.all-calendars input[type="radio"]:checked').
                        parent().attr('data-id');
      data = { calendar_id: calendar_id }
    } else if (attribute === 'availability') {
      var availability = that.collectAvailability();
    }

    $.ajax({
      url: '/users/'+user_id,
      type: 'PUT',
      data: data,
      success: function(response) {
        notify.build(response.msg, 'success');
      },
      error: function(err) {
        console.log(err);
        notify.build(err, 'error');
      }
    });
  };

  this.getUserAvailability = function() {
    $.ajax({
      url: '/users/'+user_id,
      type: 'GET',
      success: function(data) {
        that.populateAvailability(JSON.parse(data.user.availability));
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.collectAvailability = function() {
    $('.time-blocks li').each(function(block) {

    });
  };

  this.populateAvailability = function(array) {
    $('.availability .time-blocks').empty();

    var repeats = [];
    for (var i = 0; i < array.length; i++) {
      var item = array[i];
      var key = item.start_time + item.end_time;

      if (!repeats[key]) {
        repeats[key] = {
          start_time: item.start_time,
          end_time:   item.end_time,
          days:       []
        }
      }

      repeats[key].days.push(item.day);
    };

    for (key in repeats) {
      that.buildTimeBlock(repeats[key]);
    }
  }

  this.buildTimeBlock = function(repeat) {
    console.log('build time block')
    var repeatBlock = $('<li>').addClass('block');
    var daysEl = $('<div>').addClass('days').html('Repeat ');

    // Time input
    var timesEl = $('<div>').addClass('times');
    var startLabel = $('<span>').html('Start');
    var startInput = $('<input>').attr('type','text').addClass('start');
    var endLabel = $('<span>').html('End');
    var endInput = $('<input>').attr('type','text').addClass('end');

    if (repeat) {
      startInput.val(repeat.start_time);
      endInput.val(repeat.end_time);
    }

    timesEl.append(startLabel).append(startInput).
      append(endLabel).append(endInput);

    // Days repeated
    for (var i = 0; i < 7; i++) {
      var dayEl = $('<div>').addClass('day');
      var checkbox = $('<input>').attr('type', 'checkbox');

      if (repeat && repeat.days.indexOf(i) > -1) {
        checkbox.attr('checked', true);
      }

      var dayLabel = $('<span>').addClass('label').html(dayLookup(i));
      dayEl.append(dayLabel).append(checkbox);
      daysEl.append(dayEl);
    }

    repeatBlock.append(timesEl).append(daysEl);
    $('.availability .time-blocks').append(repeatBlock);
  }

  var dayLookup = function(num) {
    var dict = {
      0: 'Sun', 1: 'Mon', 2: 'Tue', 3: 'Wed',
      4: 'Thu', 5: 'Fri', 6: 'Sat'
    }

    return dict[num];
  };

  this.init();

}
