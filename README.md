jquery.qeditor
==============

This is a simple WYSIWYG editor with jQuery.

[中文介绍请点这里](http://huacnlee.com/blog/jquery-qeditor-introduction/)

<img src="https://f.cloud.github.com/assets/5518/945320/a8f55670-0303-11e3-8cd5-a77e94a85dbf.png" width="626" />

## Featrues

- Simple UI, Simple Use;
- Use font-awsome as toolbar icon;
- Remove complex html tag, attributes on paste, this can make you web page clean;
- Less code;
- Use `<p>` not `<br>` on press `Enter`, This can help you make a neat layout;
- PlaceHolder for WYSIWYG editor;
- FullScreen;

## Browser support

- Safari
- Chrome
- Firefox
- IE (No test), maybe 8+

## Demo

You can try the [Demo app](http://huacnlee.github.io/jquery.qeditor).

## Usage

```html
<textarea id="post_body"></textarea>
<script type="text/javascript">
$("#post_body").qeditor({});
</script>
```

## How to add custom toolbar icon

```js
// Custom a toolbar icon
var toolbar = $("#post_body").parent().find(".qeditor_toolbar");
var link = $("<a href='#'><span class='icon-smile'></span></a>");
link.click(function(){
  alert("Put you custom toolbar event in here.");
  return false;
});
toolbar.append(link);
```


## Build

```
$ bundle install
$ rake watch # or use "rake build" to release
``` 


## License

Apache V2 : http://choosealicense.com/licenses/apache
