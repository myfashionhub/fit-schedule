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
          that.populateStudio(data.studio);
          // that.populateClasses(data.classes);
          that.suggestClasses(data.studio.id);
        },
        error: function(err) {
          console.log(err);
          window.alert('Please enter a valid schedule URL.');
        }
      });
    });
  };

  this.populateStudio = function(studio) {
    var name   = $('<a>').attr('src', studio.schedule_url).
                   attr('target','_blank').wrapInner(studio.name);
    $('.studio').attr('data-id', studio.id);
    $('.studio .name').html(name);
    $('.studio .address').html(studio.address);
    //window.location.hash = studio.id;
  };

  this.populateClasses = function(classes) {
    _.sortBy(classes, function(klass) {
      return klass.date || klass.start_time;
    });

    var dates = _.pluck(classes, 'date'),
        currentDate = dates[0],
        dateCounter = 0;
    
    var firstDate = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.classes .schedule').append(firstDate);

    for (var i=0; i < classes.length; i++) {
      if (classes[i].date !== currentDate) {
        currentDate = classes[i].date;
        dateCounter = 0;
      } else {
        dateCounter += 1;
      }

      if (dateCounter === 0) {
        var dateLi = $('<li>').addClass('date').html(convertDate(currentDate));
        $('.classes .schedule').append(dateLi);
      }

      var classLi = $('<li>').addClass('class'),
          name = $('<span>').addClass('title').html(classes[i].name),
          time = $('<span>').addClass('time').
                   html(classes[i].start_time+' - '+classes[i].end_time)
          instructor = $('<span>').addClass('instructor').
                         html(classes[i].instructor);
      classLi.append(name).append(time).append(instructor);
      $('.classes .schedule').append(classLi);
    }
  };

  this.suggestClasses = function(studio_id) {
    $.ajax({
      url: '/studios/'+studio_id,
      type: 'GET',
      success: function(data) {
        console.log(data);
        populateClassTypes(data.unique_classes);
      },
      error: function(err) {
        console.log(err);
      }
    });

    var populateClassTypes = function(classTypes) {
      $('.class-types').empty();

      for (var i=0; i < classTypes.length; i++) {
        var classLi = $('<li>').addClass('class');
        var name = $('<span>').addClass('name').html(classTypes[i]);
        var checkbox = $('<span>').addClass('checkbox').
                         html('<i class="fa fa-square-o"></i>');
        classLi.append(name).append(checkbox);
        $('.class-types').append(classLi)
      }

      var filter = new Filter();
      // Event listeners for saving suggested classes as filters
    }
  };

  var convertDate = function(dateObj) {
    var date = new Date(dateObj);
    return date.toDateString().replace(' ',', ').replace(/\s\d{4}/i, '');
  };

  this.showFavorites = function() {
    $.ajax({
      url: '/users/studios',
      type: 'GET',
      success: function(data) {
        console.log(data.studios);
        that.populateStudiosAndFilters(data.studios);
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.populateStudiosAndFilters = function(studios) {
    var studioUl = $('.schedule-wrapper .favorite-studios');

    for (var i=0; i < studios.length; i++) {
      var studioLi = $('<li>').addClass('studio');
      var studioName = $('<h4>').html(studios[i].studio.name).
                         attr('data-id', studios[i].studio.id);
      var editButton = $("<i class='fa fa-pencil-square-o'></i>").addClass('edit')

      var filters = studios[i].filters;
      var filterUl = $('<ul>');
      for (var j=0; j < filters.length; j++) {
        var filterLi = $('<li>').html(filters[j].class_name);
        filterUl.append(filterLi)
      }

      studioName.append(editButton)
      studioLi.append(studioName).append(filterUl);
      studioUl.append(studioLi);

      editButton.click(function(e) { that.editStudioFilters(e); });
    }
  };

  this.editStudioFilters = function(e) {
    var studioId = $(e.target).parent().attr('data-id');
  };

  this.init();

}
