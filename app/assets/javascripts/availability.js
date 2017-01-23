function Availability() {
  var container = $('.customize-wrapper .availability');
  var user_id = $('#user').attr('data-id');
  var that = this;

  this.init = function() {
    container.find('.add').click(function() {
      that.buildTimeBlock();
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

    this.changesMade();
  }

  this.buildTimeBlock = function(repeat) {
    var repeatBlock = $('<li>').addClass('block');
    var daysEl = $('<div>').addClass('days').html('<span>Repeat</span>');

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
  };

  this.changesMade = function() {
    var changes = 0;

    var formChange = function() {
      if (changes > 0) {
        container.find('.save').addClass('active');
      }
    };

    container.find('input').keypress(function(e) {
      changes += 1;
      formChange();
    });

    container.find('input').click(function(e) {
      changes += 1;
      formChange();
    });
  };

  var dayLookup = function(index) {
    var array = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return array[index];
  };

  this.init();
}
