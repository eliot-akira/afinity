# afinity

```coffeescript
app = require 'afinity'

{ button, div, span } = app.html

ui = app.create
  model:
    counter : 0
  view:
    div 'Count: ', ->
      span bind:'counter'
      button class:'plus', '+'
      button class:'minus', '-'
  events:
    'click .plus':
      @set 'counter', @get('counter')+1
    'click .minus':
      @set 'counter', @get('counter')-1

app.body.append ui
```
