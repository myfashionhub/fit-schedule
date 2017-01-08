function Filter() {

  var that = this;
  this.user_id = $('#user').attr('data-id');
  var notify = new Notify();

  this.init = function() {

  };
  
  this.show = function(studio_id) {
    // Pre-check filters saved for user
    var filtersPromise = new Promise(function(resolve, reject) {
      $.ajax({
        url: '/users/'+that.user_id+'/filters?studio_id='+studio_id,
        type: 'GET',
        success: function(data) {
          resolve(data.filters);
        },
        error: function(err) {
          reject(err);
          console.log(err);
        }
      });
    });

    return filtersPromise;
  };

  this.update = function() {
    var studio_id = $('.studio-show .studio').attr('data-id');
    var classNames = [],
        classLis;

    if ($('.modal-dialog').hasClass('active')) {
      classLis = $('.modal-dialog .class-types .class');
    } else {
      classLis = $('.customize-wrapper .class-types .class')
    }

    _.each(classLis, function(classLi) {
      var checkbox = $(classLi).find('.checkbox');

      if (checkbox.attr('class').indexOf('selected') > -1) {
        var className = $(classLi).find('.name').html();
        classNames.push(className);
      }
    });

    $.ajax({
      url: '/users/'+that.user_id+'/filters',
      type: 'POST',
      data: {
        class_names: JSON.stringify(classNames),
        studio_id: studio_id
      },
      success: function(data) {
        var studioName = $('.studio-show .studio .name').html();
        var msg = 'Successfully saved your preferences for ' + studioName;
        notify.build(msg, 'success');
      },
      error: function(err) {
        console.log(err);
      }
    });
  };

  this.deleteStudioFilters = function(studio_id) {
    var deferred = $.Deferred();

    $.ajax({
      url: '/users/'+that.user_id+'/filters',
      type: 'DELETE',
      data: { studio_id: studio_id },
      success: function(data) {
        deferred.resolve(data.msg, 'success');
      },
      error: function(err) {
        deferred.resolve(err, 'error');
      }
    });

    return deferred.promise();
  };

  this.select = function() {
    // toggle selected class names

    $('.class .checkbox').click(function(e) {
      var checkbox  = $(e.target).parent();

      if (checkbox.attr('class').indexOf('selected') > 0) {
        checkbox.removeClass('selected');
        checkbox.empty().html("<i class='fa fa-square-o'></i>");
      } else {
        checkbox.addClass('selected');
        checkbox.empty().html("<i class='fa fa-check-square-o'></i>");
      }
    });

    $('.save-filters').click(function() { that.update(); });
  };

  this.init();

}
