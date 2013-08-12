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
  <a href="#" onclick="return QEditor.action(this,'bold');" class="qe-bold"><span class="icon-bold"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'italic');" class="qe-italic"><span class="icon-italic"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'underline');" class="qe-underline"><span class="icon-underline"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'strikethrough');" class="qe-strikethrough"><span class="icon-strikethrough"></span></a>		 
  <span class="vline"></span> 
  <a href="#" onclick="return QEditor.action(this,'insertorderedlist');" class="qe-ol"><span class="icon-list-ol"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'insertunorderedlist');" class="qe-ul"><span class="icon-list-ul"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'indent')" class="qe-indent"><span class="icon-indent-right"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'outdent')" class="qe-outdent"><span class="icon-indent-left"></span></a> 
  <span class="vline"></span> 
  <a href="#" onclick="return QEditor.action(this,'insertHorizontalRule');" class="qe-hr"><span class="icon-minus"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'formatBlock','blockquote');" class="qe-blockquote"><span class="icon-quote-left"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'formatBlock','pre');" class="qe-pre"><span class="icon-code"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'createLink');" class="qe-link"><span class="icon-link"></span></a> 
  <a href="#" onclick="return QEditor.action(this,'insertimage');" class="qe-image"><span class="icon-picture"></span></a> 
  <a href="#" onclick="return QEditor.toggleFullScreen(this);" class="qe-fullscreen pull-right"><span class="icon-fullscreen"></span></a> 
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
    border = $(el).parent().parent()
    if border.data("qe-fullscreen") == "1"
      QEditor.exitFullScreen()
    else
      QEditor.enterFullScreen(border)

    false
  
  enterFullScreen : (border) ->
    border.data("qe-fullscreen","1")
          .addClass("qeditor_fullscreen")
    border.find(".qeditor_preview").focus()
    border.find(".qe-fullscreen span").attr("class","icon-resize-small")
  
  exitFullScreen : () ->
    $(".qeditor_border").removeClass("qeditor_fullscreen")
                        .data("qe-fullscreen","0")
                        .find(".qe-fullscreen span").attr("class","icon-fullscreen")
    
  version : ->
    "0.1.1"


(($) ->
  $.fn.qeditor = (options) ->
    this.each ->
      obj = $(this)
      obj.addClass("qeditor")
      editor = $('<div class="qeditor_preview clearfix" style="overflow:scroll;" contentEditable="true"></div>')
      placeholder = $('<div class="qeditor_placeholder"></div>')
      
      $(document).keyup (e) ->
        QEditor.exitFullScreen() if e.keyCode == 27
        
      # use <p> tag on enter by default
      document.execCommand('defaultParagraphSeparator', false, 'p')
      
      currentVal = obj.val()
      # if currentVal.trim().lenth == 0
        # TODO: default value need in paragraph
        # currentVal = "<p></p>"
      
      editor.html(currentVal)
      editor.addClass(obj.attr("class"))
      obj.after(editor)
      
      # add place holder
      placeholder.text(obj.attr("placeholder"))
      editor.attr("placeholder",obj.attr("placeholder"))
      editor.append(placeholder)
      editor.focusin ->
        $(this).find(".qeditor_placeholder").remove()
      editor.blur ->
        t = $(this)
        if t.text().length == 0
          $(this).html('<div class="qeditor_placeholder">' + $(this).attr("placeholder") + '</div>' )
      
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
      editor.before(QEDITOR_TOOLBAR_HTML)
)(jQuery)