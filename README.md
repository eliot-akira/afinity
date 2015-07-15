# afinity

Model/view/events object factory for modular user interface

---

### Install

The [minified library](https://github.com/eliot-akira/afinity/blob/master/dist/afinity.min.js) found in `dist` folder can be included after jQuery.

```html
<script src="afinity.min.js"></script>
```

Then it is exposed as `afinity` in the global scope.

```coffeescript
app = afinity
```

It can also be installed as an NPM module.

```bash
npm install afinity --save
```

And included via CommonJS/Browserify.

```coffeescript
app = require 'afinity'
```

---

### Note

The library and examples are written in CoffeeScript for sweeter syntax, but it works well in plain JS also.

---

### Model

```coffeescript
obj = app.create
  model :
    message : 'Hello'

obj.on 'change:message', ->
  console.log 'New message: ', obj.get 'message'

obj.set 'message', 'Hey'
```

Methods

- get, set
- on, trigger

---

### View

#### String

For quick prototyping, define the view template as a string.


```coffeescript
obj = app.create
  model:
    counter: 0
  view: '<span data-bind="counter"></div>'

app.body.append '#counter', obj
```

The HTML attribute `data-bind` is used to bind model to view, and vice versa if it's an input element.

There are two template helpers `html` and `css` to create encapsulate both template and style  within the object.

```coffeescript

{ div, input } = app.html
css = app.css

obj = app.create
  view:
    format:
      div class: 'name-input', ->
        input bind: 'name'
    style: css
      '&':
        border:'1px solid #ddd'
        'input': width:'100%'
```

#### Template in document

The template can be directly in the document.

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
