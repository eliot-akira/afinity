
var app = afinity;

var obj = app.create({
  model : {
    message : 'Hello'
  }
});

obj.on('change:message', function(data) {
  console.log('New message: ', obj.get('message'));
});

obj.set('message', 'Hey');
