###
jquery.qeditor
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

QEDITOR_TOOLTIP_HTML = """
<div class="qeditor_tooltip" contenteditable="false">
    <input type="text" autocomplete="off">
    <div class="actions">
        <a href="javascript:;" class="cancel">Cancel</a>
        <a href="javascript:;" class="insert">Insert</a>
    </div>
</div>
"""

QEDITOR_TOOLBAR_HTML = """
<div class="qeditor_toolbar">
  <a href="#" data-action="bold" class="qe-icon qe-bold"><span class="fa fa-bold" title="Bold"></span></a> 
  <a href="#" data-action="italic" class="qe-icon qe-italic"><span class="fa fa-italic" title="Italic"></span></a> 
  <a href="#" data-action="underline" class="qe-icon qe-underline"><span class="fa fa-underline" title="Underline"></span></a> 
  <a href="#" data-action="strikethrough" class="qe-icon qe-strikethrough"><span class="fa fa-strikethrough" title="Strike-through"></span></a>		 
  <span class="vline"></span>
  <span class="qe-icon qe-heading">
    <ul class="qe-menu">
      <li><a href="#" data-name="h1" class="qe-h1">Heading 1</a></li>
      <li><a href="#" data-name="h2" class="qe-h2">Heading 2</a></li>
      <li><a href="#" data-name="h3" class="qe-h3">Heading 3</a></li>
      <li><a href="#" data-name="h4" class="qe-h4">Heading 4</a></li>
      <li><a href="#" data-name="h5" class="qe-h5">Heading 5</a></li>
      <li><a href="#" data-name="h6" class="qe-h6">Heading 6</a></li>
      <li class="qe-hline"></li>
      <li><a href="#" data-name="p" class="qe-p">Paragraph</a></li>
    </ul>
    <span class="icon fa fa-font"></span>
  </span>
  <span class="vline"></span>
  <a href="#" data-action="insertorderedlist" class="qe-icon qe-ol"><span class="fa fa-list-ol" title="Insert Ordered-list"></span></a> 
  <a href="#" data-action="insertunorderedlist" class="qe-icon qe-ul"><span class="fa fa-list-ul" title="Insert Unordered-list"></span></a> 
  <a href="#" data-action="indent" class="qe-icon qe-indent"><span class="fa fa-indent" title="Indent"></span></a> 
  <a href="#" data-action="outdent" class="qe-icon qe-outdent"><span class="fa fa-outdent" title="Outdent"></span></a> 
  <span class="vline"></span> 
  <a href="#" data-action="insertHorizontalRule" class="qe-icon qe-hr"><span class="fa fa-minus" title="Insert Horizontal Rule"></span></a> 
  <a href="#" data-action="blockquote" class="qe-icon qe-blockquote"><span class="fa fa-quote-left" title="Blockquote"></span></a> 
  <a href="#" data-action="pre" class="qe-icon qe-pre"><span class="fa fa-code" title="Pre"></span></a> 
  <a href="#" data-action="createLink" class="qe-icon qe-link"><span class="fa fa-link" title="Create Link" title="Create Link"></span></a> 
  <a href="#" data-action="insertImage" class="qe-icon qe-image"><span class="fa fa-picture-o" title="Insert Image"></span></a>
  <a href="#" data-action="undo" class="qe-icon qe-image"><span class="fa fa-undo" title="Undo"></span></a>
  <a href="#" onclick="return QEditor.toggleFullScreen(this);" class="qe-icon qe-fullscreen pull-right"><span class="fa fa-arrows-alt" title="Toggle Fullscreen"></span></a> 
</div>
"""
QEDITOR_ALLOW_TAGS_ON_PASTE = "div,p,ul,ol,li,hr,br,b,strong,i,em,img,h2,h3,h4,h5,h6,h7"
QEDITOR_DISABLE_ATTRIBUTES_ON_PASTE = ["style","class","id","name","width","height"]

window.QEditor = 
  actions : ['bold','italic','underline','strikethrough','insertunorderedlist','insertorderedlist','blockquote','pre']
  
  action : (el,a,p) ->
    editor = $(".qeditor_preview",$(el).parent().parent())
    editor.find(".qeditor_placeholder").remove()
    editor.focus()
    p = false if p == null
    
    # pre, blockquote params fix
    if a == "blockquote" or a == "pre"
      p = a
      a = "formatBlock"
    
    
    if (a == "createLink" or a == "insertImage") and !p
      editor.parent().find('.qeditor_tooltip').data({el:el, a:a}).show().find('input').val('http://').focus()
      return false
    
    if QEditor.state(a)
      # remove style
      document.execCommand(a,false,null)
    else
      # apply style
      document.execCommand(a, false, p)
    QEditor.checkSectionState(editor)
    editor.change()
    false    
    
  state : (action) ->
    document.queryCommandState(action) == true
  
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
    border.find(".qe-fullscreen span").attr("class","fa fa-compress")
  
  exitFullScreen : () ->
    $(".qeditor_border").removeClass("qeditor_fullscreen")
                        .data("qe-fullscreen","0")
                        .find(".qe-fullscreen span")
                        .attr("class","fa fa-arrows-alt")
    $(".qeditor_border").find(".qeditor_preview").focus()
    
  getCurrentContainerNode : () ->
    if window.getSelection
      node = window.getSelection().anchorNode
      containerNode = if node.nodeType == 3 then node.parentNode else node
    return containerNode
    
  checkSectionState : (editor) ->
    for a in QEditor.actions
      link = editor.parent().find(".qeditor_toolbar a[data-action=#{a}]")
      if QEditor.state(a)
        link.addClass("qe-state-on")
      else
        link.removeClass("qe-state-on")
    
  version : ->
    "0.2.0"

do ($=jQuery)->
  $.fn.qeditor = (options) ->
    this.each ->
      obj = $(this)
      obj.addClass("qeditor")
      editor = $('<div class="qeditor_preview clearfix" contentEditable="true" tabindex="2"></div>')
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
      editor.attr("placeholder",obj.attr("placeholder") || "")
      editor.append(placeholder)
      editor.focusin ->
        QEditor.checkSectionState(editor)
        $(this).find(".qeditor_placeholder").remove()
      editor.blur ->
        t = $(this)
        QEditor.checkSectionState(editor)
        if t.html().length == 0 or t.html() == "<br>" or t.html() == "<p></p>" 
          $(this).html('<div class="qeditor_placeholder">' + $(this).attr("placeholder") + '</div>' )

      # add tooltip
      editor.append(tooltip)
      
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
          els.find(":not(#{QEDITOR_ALLOW_TAGS_ON_PASTE})").contents().unwrap()
          txt.change()
          true
        ,100
    
      # attach change event on editor keyup
      editor.keyup (e) ->
        QEditor.checkSectionState(editor)
        $(this).change()
      
      editor.on "click", (e) ->
        QEditor.checkSectionState(editor)
        e.stopPropagation()
      
      editor.keydown (e) ->
        node = QEditor.getCurrentContainerNode()
        nodeName = ""
        if node and node.nodeName
          nodeName = node.nodeName.toLowerCase()
        if e.keyCode == 13 && !(e.shiftKey or e.ctrlKey)
          if nodeName == "blockquote" or nodeName == "pre"
            e.stopPropagation()
            document.execCommand('InsertParagraph',false)
            document.execCommand("formatBlock",false,"p")
            document.execCommand('outdent',false)
            return false             
          
      
      obj.hide()
      obj.wrap('<div class="qeditor_border"></div>')
      obj.after(editor)
    
      # render toolbar & binding events
      toolbar = $(QEDITOR_TOOLBAR_HTML)
      qe_heading = toolbar.find(".qe-heading")
      qe_heading.mouseenter ->
        $(this).addClass("hover")
        $(this).find(".qe-menu").show()
      qe_heading.mouseleave ->
        $(this).removeClass("hover")
        $(this).find(".qe-menu").hide()
      toolbar.find(".qe-heading .qe-menu a").click ->
        link = $(this)
        link.parent().parent().hide()
        QEditor.action(this,"formatBlock",link.data("name"))
        return false
      toolbar.find("a[data-action]").click ->
        QEditor.action(this,$(this).attr("data-action"))
      editor.before(toolbar)

      # render tooltip & binding events
      tooltip = $(QEDITOR_TOOLTIP_HTML)
      tooltip.find(".cancel").click ->
        tooltip.hide()
      tooltip.find('.insert').click ->
        val = tooltip.find('input').val().replace('javascript:','')
        if val.indexOf('http://') == -1 and val.indexOf('https://') == -1 or val.length <= 8
          return false
        data = tooltip.data()
        QEditor.action(data.el, data.a, val)
      editor.before(tooltip)
      editor.focus ->
          tooltip.hide()
