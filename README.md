# afinity

Model/view/events object factory for modular user interface

---

### Install

#### Method 1

Install as NPM module.

```bash
npm install afinity --save
```

And include via CommonJS/Browserify.

```coffeescript
app = require 'afinity'
```

#### Method 2

The [minified library](https://github.com/eliot-akira/afinity/blob/master/dist/afinity.min.js) found in `dist` folder can be included after jQuery.

```html
<script src="afinity.min.js"></script>
```

Then it is exposed as `afinity` in the global scope.

```coffeescript
app = afinity
```

---

### Note

The library and examples are written in CoffeeScript for sweeter syntax, but it works well in vanilla JS also. Just throw in a healthy dose of parentheses, curly brackets, semicolons..

---

### Overview

The main method is `create`, which takes three properties: model, view, and events.

```coffeescript
obj = app.create
  model:
    counter: 0
  view:
    '#counter-view'
  events:
    'click .add': ->
      @set 'counter', @get()+1
    'click .subtract': ->
      @set 'counter', @get()-1

obj.on 'change:counter', ->
  console.log 'Counter changed to '+obj.get('counter')
```

- Model is the data or state of the object
- View is the HTML representation, with optional data-binding to model
- Events include user actions like click and submit, as well as internal events

Each object:

- is encapsulated
- can publish/subscribe events to communicate with other objects
- can be used as a prototype to clone similar objects
- can contain child objects to create nested structure, i.e. collections

---

### Object Methods

- on, trigger
- append, destroy

---

### Model

```coffeescript
obj = app.create
  model :
    message : 'Hello'

obj.set 'message', 'Hey'
```

Methods

- get, set

Events

- change
- change:property

---

### View templates

The HTML attribute `data-bind` is used to bind model property to view, and vice versa if it's an input element. All other templating logic like looping through collections, conditional states, must be handled by object methods, or in the context.

#### Template as string

Small templates may be given as a string.

```coffeescript
obj = app.create
  model:
    counter: 0
  view:
    '<span data-bind="counter"></div>'
  increment: (value) ->
    @set 'counter', @get('counter')+(value or 1)
  decrement: (value) ->
    @set 'counter', @get('counter')-(value or 1)

obj.increment(5).decrement(10)
```

#### Template format and style

There are two template helpers `html` and `css` to encapsulate both template and style within the object. This can be useful for building reusable components.

```coffeescript

{ form, input, button } = app.html
css = app.css

obj = app.create
  model:
    name: ''
    email: ''
  view:
    format:
      form ->
        input bind: 'name'
        input bind: 'email'
        button type: 'submit'
    style: css
      '&':
        border: '1px solid #ddd'
        'input, button':
          width: '100%'
  events:
    'submit': ->
      data = @get()
      # Do something with data
```

#### Template in document

The template can be already in the document.

```html
<form id="contact-form">
  <input type="text" name="name">
  <input type="email" name="email">
  <button type="submit">Send</button>
</form>
```

```coffeescript
obj = app.create view: '#contact-form'
```

If it's a form, the inputs are automatically bound as model properties.

#### Template in script tag

```html
<script type="text/template" id="single-post">
  <article class="single-post">
    <h1 data-bind="title"></h1>
    <small data-bind="date"></small>
    <main class="post-content" data-bind="html=content"></main>
  </article>
</script>
```

```coffeescript
Post = app.create view: '#single-post'

newPost = app.clone Post,
  title: 'New blog post'
  date: '2016-04-20'
  content: 'Lorem ipsum, lorem ipsum'

app.body.append '.post-list', newPost
```

---

### View methods

- $view

---

### Events

#### Internal

- create
- change
- append
- remove

#### DOM

- click, submit, keydown, etc.

---

### Clones and children

- append, each

---

### Credit

Originally based on Agility.js by Artur B. Adib - http://agilityjs.com

Forked, pulled requests, modularized, extended, refactored and caffeinated
