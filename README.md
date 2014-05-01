jquery.qeditor with bootstrap3
==============

This is a simple WYSIWYG editor with jQuery.

[中文介绍请点这里](http://huacnlee.com/blog/jquery-qeditor-introduction/)

## screenshot

<img src="http://i.imgur.com/DgRqupP.png">

FullScreen mode

<img src="http://i.imgur.com/pp56xPi.png">


## Featrues

- Simple UI, Simple Use;
- Use font-awsome as toolbar icon;
- Remove complex html tag, attributes on paste, this can make you web page clean;
- Less code;
- Use `<p>` not `<br>` on press `Enter`, This can help you make a neat layout;
- PlaceHolder for WYSIWYG editor;
- FullScreen;

## Changelogs

You can see all of the release notes in here: [Release notes](https://github.com/gihnius/jquery.qeditor/releases)

## Browser support

- Safari
- Chrome
- Firefox
- IE (No test), maybe 8+

## Demo

You can try the [Demo app](http://cdn.qufor.com/jquery_qeditor/)

## Usage

```html
<textarea id="textarea_el"></textarea>
<script type="text/javascript">
$("#textarea_el").qeditor({});
</script>
```

## How to add custom toolbar icon

```js
// Custom a toolbar icon
var toolbar_btn_list = $("#textarea_el").parent().find(".qeditor_toolbar > .btn-group").first();
var btn = $('<button type="button" class="btn btn-default btn-sm" data-toggle="tooltip" title="Upload Image"><i class="fa fa-upload"></i></button>');

toolbar_btn_list.append(btn);

btn.click(function(){
  alert("Put you custom toolbar event in here.");
  return false;
});
```


## Build

```
$ bundle install
$ rake watch # or use "rake build" to release
```


## License

Apache V2 : http://choosealicense.com/licenses/apache
