function Studio() {

  var that = this;

  this.init = function() {
    
  };

  this.getClasses = function() {
    $('#studio-schedule').submit(function(e) {
      e.preventDefault();
      var url = $('#studio-schedule .url').val();

      $.ajax({
        url: '/classes',
        type: 'POST',
        data: { url: url },
        success: function(data) {
          console.log(data);
          that.populateStudio(data);
          that.populateClasses(data);
        },
        error: function(err) {
          console.log(err);
          window.alert('Please enter a valid schedule URL.');
        }
      });
    });
  };

  this.populateStudio = function(data) {
    var studio = data.studio;
    var name   = $('<a>').attr('src', studio.schedule_url).
                   attr('target','_blank').wrapInner(studio.name);
    $('.studio').attr('data-id', studio.id);
    $('.studio .name').html(name);
    $('.studio .address').html(studio.address);
    window.location.hash = studio.id;
  };

  this.populateClasses = function(data) {
    var classes = data.classes;

    _.sortBy(classes, function(klass) {
      return klass.date || klass.start_time;
    });

    var dates = _.pluck(classes, 'date'),
        currentDate = dates[0],
        dateCounter = 0;
    
    var firstDate = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.schedule').append(firstDate);

    for (var i=0; i < classes.length; i++) {
      if (classes[i].date !== currentDate) {
        currentDate = classes[i].date;
        dateCounter = 0;
      } else {
        dateCounter += 1;
      }

      if (dateCounter === 0) {
        var dateLi = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.schedule').append(dateLi);
      }

      var classLi = $('<li>').addClass('class'),
          name = $('<span>').addClass('title').html(classes[i].name),
          time = $('<span>').addClass('time').
                   html(classes[i].start_time+' - '+classes[i].end_time)
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor);
      classLi.append(name).append(time).append(instructor);
      $('.schedule').append(classLi);
    }

    this.suggestClasses(classes);
  };

  this.suggestClasses = function(classes) {
    var classTypes = _.uniq(_.pluck(classes, 'name'));
    classTypes = _.sortBy(classTypes, function(self) { return self; });

    for (var i=0; i < classTypes.length; i++) {
      var classLi = $('<li>').addClass('class').html(classTypes[i]);
      $('.class-types').append(classLi)
    }
  };

  var convertDate = function(dateObj) {
    var date = new Date(dateObj);
    return date.toDateString().replace(' ',', ').replace(/\s\d{4}/i, '');
  };

  this.init();

}
