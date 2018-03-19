function User(user_id) {
  this.id = user_id;

  var that = this;
  var notify = new Notify();

  this.update = function(data) {
    $.ajax({
      url: '/users/'+that.id,
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
}
