
app = afinity

{ div, span, section, button, input } = app.html

singleTodo = app.create
  model:
    todo: ''
  view:
    div ->
      input type:'checkbox'
      span bind:'todo'
  events:
    'click input': -> @destroy()

todoList = app.create
  model:
    todo: ''
  view:
    div ->
      section ->
        input class: 'todo-input', bind:'todo'
        button 'Create'
      section class: 'todo-list'
  events:
    'parent:append,child:destroy': -> @focus()
    'click button': -> @addNew()
    'keydown .todo-input': ( data ) ->
      if data.keyCode is 13 then @addNew() # enter

  addNew: ->
    if @get('todo') is ''
      @focus()
      return
    newTodo = app.clone singleTodo, model:@get()
    @append '.todo-list', newTodo
    @focus()

  focus: -> @set('todo', '').$('.todo-input').val('').focus()

app.body.append todoList
