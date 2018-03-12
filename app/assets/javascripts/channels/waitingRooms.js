//= require cable
//= require_self
//= require_tree .

 
App.waiting_rooms = App.cable.subscriptions.create('WaitingRoomsChannel', {  
  received: function(data) {
    // $("#messages").removeClass('hidden')
    // return $('#messages').append(this.renderMessage(data));
  },

  renderMessage: function(data) {
    // return "<p> <b>" + data.user + ": </b>" + data.message + "</p>";
  }
});