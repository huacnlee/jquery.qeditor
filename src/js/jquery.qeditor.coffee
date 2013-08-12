###
jQuery.Qeditor
==============

This is a simple WYSIWYG editor with jQuery.

## Author:

    Jason Lee <huacnlee@gmail.com>

## Requirements:

    [jQuery](http://jquery.com)
    (Font-Awesome)[http://fortawesome.github.io/Font-Awesome/] - Toolbar icons

## Usage:

    $("textarea").qeditor();

and then you need filt the html tags,attributes in you content page.
In Rails application, you can use like this:

    <%= sanitize(@post.body,:tags => %w(strong b i u strike ol ul li address blockquote pre code br div p), :attributes => %w(src)) %>
###

QEDITOR_TOOLBAR_HTML = """
<div class="qeditor_toolbar">
  <a href="#" onclick="return QEditor.action(this,'bold');" title="Bold"><span class="icon-bold"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'italic');" title="Italic"><span class="icon-italic"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'underline');" title="Underline"><span class="icon-underline"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'strikethrough');" title="StrikeThrough"><span class="icon-strikethrough"></span></a>		 
  <span class="vline"></span> 
  <a href="#" onclick="return QEditor.action(this,'insertorderedlist');"><span class="icon-list-ol"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'insertunorderedlist');"><span class="icon-list-ul"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'indent')"><span class="icon-indent-left"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'outdent')"><span class="icon-indent-right"></span></a> 
  <span class="vline"></span> 
  <a href="#" onclick="return QEditor.action(this,'insertHorizontalRule');"><span class="icon-minus"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'formatBlock','blockquote');"><span class="icon-quote-left"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'formatBlock','PRE');"><span class="icon-code"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'createLink');"><span class="icon-link"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'insertimage');"><span class="icon-picture"></span></a> 
  <a href="#" onclick="return QEditor.toggleFullScreen(this);" class="pull-right"><span class="icon-fullscreen"></span></a> 
</div>
"""
QEDITOR_ALLOW_TAGS_ON_PASTE = "div,p,ul,ol,li,hr,br,b,strong,i,em,img,h2,h3,h4,h5,h6,h7"
QEDITOR_DISABLE_ATTRIBUTES_ON_PASTE = ["style","class","id","name","width","height"]

window.QEditor = 
  action : (el,a,p) ->
    editor = $(".qeditor_preview",$(el).parent().parent())
    editor.focus()
    p = false if p == null
    
    if a == "createLink"
      p = prompt("Type URL:")
      return false if p.trim().length == 0
    else if a == "insertimage"
      p = prompt("Image URL:")
      return false if p.trim().length == 0
    
    document.execCommand(a, false, p)
    editor.change() if editor != undefined
    false
  
  prompt : (title) ->
    val = prompt(title)
    if val
      return val
    else
      return false
  
  toggleFullScreen : (el) ->
    editor = $(el).parent().parent()
    if editor.data("qe-fullscreen") == "1"
      editor.css("width",editor.data("qe-width"))
            .css("height",editor.data("qe-height"))
            .css("top",editor.data("qe-top"))
            .css("left",editor.data("qe-left"))
            .css("position","static")
            .css("z-index",0)
            .data("qe-fullscreen","0")
    else
      editor.data("qe-width",editor.width())
            .data("qe-height",editor.height())
            .data("qe-top",editor.position().top)
            .data("qe-left",editor.position().left)
            .data("qe-fullscreen","1")
            .css("top",0)
            .css("left",0)
            .css("position","absolute")
            .css("z-index",99999)
            .css("width",$(window).width())
            .css("height",$(window).height())
    false
    
  renderToolbar : (el) ->
    el.parent().prepend(QEDITOR_TOOLBAR_HTML)
    
  version : ->
    "0.1.0"


(($) ->
  $.fn.qeditor = (options) ->
    if options == false
      this.each ->
        obj = $(this)
        obj.parent().find('.qeditor_toolbar').detach()
        obj.parent().find('.qeditor_preview').detach()
        obj.unwrap()
    else
      this.each ->
        obj = $(this)
        obj.addClass("qeditor")
        if options && options["mobile"]
           hidden_flag = $('<input type="hidden" name="did_editor_content_formatted" value="no">')
           obj.after(hidden_flag)
        else
          editor = $('<div class="qeditor_preview clearfix" style="overflow:scroll;" contentEditable="true"></div>')
          
          # use <p> tag on enter by default
          document.execCommand('defaultParagraphSeparator', false, 'p')
          
          currentVal = obj.val()
          # if currentVal.trim().lenth == 0
            # TODO: default value need in paragraph
            # currentVal = "<p></p>"
          
          editor.html(currentVal)
          editor.addClass(obj.attr("class"))
          obj.after(editor)
          
          # put value to origin textare when QEditor has changed value
          editor.change ->
            pobj = $(this);
            t = pobj.parent().find('.qeditor')
            t.val(pobj.html())
          
          # watch pasite event, to remove unsafe html tag, attributes
          editor.on "paste", ->
            txt = $(this)
            setTimeout ->
              els = txt.find("*")
              for attrName in QEDITOR_DISABLE_ATTRIBUTES_ON_PASTE
                els.removeAttr(attrName)
              els.find(":not("+ QEDITOR_ALLOW_TAGS_ON_PASTE +")").contents().unwrap()
            ,100
          
          # attach change event on editor keyup
          editor.keyup ->
            $(this).change()
            
          editor.on "click", (e) ->
            e.stopPropagation()
            
          obj.hide()
	        obj.wrap('<div class="qeditor_border"></div>')
	        obj.after(editor)
	        QEditor.renderToolbar(editor)
)(jQuery)