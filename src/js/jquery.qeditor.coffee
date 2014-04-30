###
jquery.qeditor
==============

This is a simple WYSIWYG editor with jQuery, Bootstrap3.1, font-awesome.

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
<div class="btn-toolbar qeditor_toolbar" role="toolbar">
  <div class="btn-group">
    <button type="button" data-action="bold" class="btn btn-default btn-sm qe-bold" title="Bold" data-toggle="tooltip"><span class="fa fa-bold"></span></button>
    <button type="button" data-action="italic" class="btn btn-default btn-sm qe-italic" title="Italic" data-toggle="tooltip"><span class="fa fa-italic"></span></button>
    <button type="button" data-action="underline" class="btn btn-default btn-sm qe-underline" title="Underline" data-toggle="tooltip"><span class="fa fa-underline"></span></button>
    <button type="button" data-action="strikethrough" class="btn btn-default btn-sm qe-strikethrough" title="Strike-through" data-toggle="tooltip"><span class="fa fa-strikethrough"></span></button>
    <div class="btn-group qe-heading">
      <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" title="Heading">
        <span class="fa fa-text-height"></span>
      </button>
      <ul class="dropdown-menu qe-menu" role="menu">
        <li><a href="#" data-name="h2" class="qe-h2"><h2>Large</h2></a></li>
        <li><a href="#" data-name="h3" class="qe-h3"><h3>Medium</h3></a></li>
        <li><a href="#" data-name="h4" class="qe-h4"><h4>Small</h4></a></li>
      </ul>
    </div>
    <button type="button" data-action="insertorderedlist" class="btn btn-default btn-sm qe-ol" title="Insert Ordered-list" data-toggle="tooltip"><span class="fa fa-list-ol"></span></button>
    <button type="button" data-action="insertunorderedlist" class="btn btn-default btn-sm qe-ul" title="Insert Unordered-list" data-toggle="tooltip"><span class="fa fa-list-ul"></span></button>
    <button type="button" data-action="insertHorizontalRule" class="btn btn-default btn-sm qe-hr" title="Insert Horizontal Rule" data-toggle="tooltip"><span class="fa fa-minus"></span></button>
    <button type="button" data-action="blockquote" class="btn btn-default btn-sm qe-blockquote" title="Blockquote" data-toggle="tooltip"><span class="fa fa-quote-left"></span></button>
    <button type="button" data-action="pre" class="btn btn-default btn-sm qe-pre" title="Pre" data-toggle="tooltip"><span class="fa fa-code"></span></button>
    <button type="button" data-action="createLink" class="btn btn-default btn-sm qe-link" data-toggle="popover" title="Create Link"><span class="fa fa-link"></span></button>
    <button type="button" data-action="insertimage" class="btn btn-default btn-sm qe-image" data-toggle="popover" title="Insert Image"><span class="fa fa-picture-o"></span></button>
  </div>
  <div class="btn-group pull-right">
    <button type="button" data-action="removeFormat" class="btn btn-default btn-sm" title="Remove format" data-toggle="tooltip"><span class="fa fa-eraser"></span></button>
    <button type="button" onclick="return QEditor.toggleFullScreen(this);" class="btn btn-default btn-sm qe-fullscreen" title="Toggle Fullscreen" data-toggle="tooltip"><span class="fa fa-arrows-alt"></span></button>
  </div>
</div>
"""

QEDITOR_ALLOW_TAGS_ON_PASTE = "div,p,ul,ol,li,hr,br,b,strong,i,em,img,h2,h3,h4,h5,h6,h7"
QEDITOR_DISABLE_ATTRIBUTES_ON_PASTE = ["style","class","id","name","width","height"]

window.QEditor =
  actions : ['bold','italic','underline','strikethrough','insertunorderedlist','insertorderedlist','blockquote','pre']

  action : (el,a,p) ->
    editor = $(".qeditor_preview", $(el).parent().parent().parent())
    editor.find(".qeditor_placeholder").remove()
    editor.focus()
    p = false if p == null

    # pre, blockquote params fix
    if a == "blockquote" or a == "pre"
      p = a
      a = "formatBlock"

    if a == "createLink"
      p = prompt("Type URL:")
      return false if p.trim().length == 0
    else if a == "insertimage"
      p = prompt("Image URL:")
      return false if p.trim().length == 0

    if QEditor.state(a)
      # remove style
      document.execCommand(a,false,null)
    else
      # apply style
      document.execCommand(a, false, p)

    editor.change()
    QEditor.checkSectionState(editor)
    false

  state: (action) ->
    document.queryCommandState(action) == true

  prompt : (title) ->
    val = prompt(title)
    if val
      return val
    else
      return false

  toggleFullScreen : (el) ->
    border = $(el).parent().parent().parent()
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
                        .find(".qe-fullscreen span").attr("class","fa fa-arrows-alt")

  getCurrentContainerNode : () ->
    if window.getSelection
      node = window.getSelection().anchorNode
      containerNode = if node && node.nodeType == 3 then node.parentNode else node
    return containerNode

  checkSectionState : (editor) ->
    for a in QEditor.actions
      link = editor.parent().find(".qeditor_toolbar button[data-action=#{a}]")
      if QEditor.state(a)
        link.addClass("active")
      else
        link.removeClass("active")

  version : ->
    "0.3.0"

do ($=jQuery)->
  $.fn.qeditor = (options) ->
    this.each ->
      obj = $(this)
      obj.addClass("qeditor")
      editor = $('<div class="qeditor_preview clearfix" contentEditable="true"></div>')
      placeholder = $('<div class="qeditor_placeholder"></div>')

      $(document).keyup (e) ->
        QEditor.exitFullScreen() if e.keyCode == 27

      # use <p> tag on enter by default
      document.execCommand('defaultParagraphSeparator', false, 'p')

      currentVal = obj.val()

      editor.html(currentVal)
      editor.addClass(obj.attr("class"))

      # add place holder
      placeholder.text(obj.attr("placeholder"))
      editor.attr("placeholder",obj.attr("placeholder") || "")
      if currentVal == ''
        editor.append(placeholder)

      editor.focusin ->
        QEditor.checkSectionState(editor)
        $(this).find(".qeditor_placeholder").remove()

      editor.blur ->
        t = $(this)
        QEditor.checkSectionState(editor)
        if t.html().length == 0 or t.html() == "<br>" or t.html() == "<p></p>"
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
          els.find(":not(#{QEDITOR_ALLOW_TAGS_ON_PASTE})").contents().unwrap()
          txt.change()
          true
        ,100

      # attach change event on editor keyup
      editor.on 'keyup', (e) ->
        QEditor.checkSectionState(editor)
        $(this).change()

      ## do not need
      # editor.on "click", (e) ->
      #   QEditor.checkSectionState(editor)
      #   e.stopPropagation()

      editor.keydown (e) ->
        # wrap the first line by <p>
        if $(this).html().trim().length == 0
          document.execCommand("formatBlock",false,"p")
        node = QEditor.getCurrentContainerNode()
        nodeName = ""
        if node and node.nodeName
          nodeName = node.nodeName.toLowerCase()
        if e.keyCode == 13 && !(e.ctrlKey or e.shiftKey)
          if nodeName == "blockquote" or nodeName == "pre"
            e.stopPropagation()
            document.execCommand('InsertParagraph',false)
            document.execCommand("formatBlock",false,"p")
            document.execCommand('Outdent',false)
            return false

      obj.hide()
      obj.wrap('<div class="qeditor_border"></div>')
      obj.after(editor)

      # render toolbar & binding events
      toolbar = $(QEDITOR_TOOLBAR_HTML)
      toolbar.find('button[data-toggle=tooltip], button[data-toggle=popover]').mouseover ->
        $(this).tooltip('show');
        return false

      toolbar.find(".qe-heading .qe-menu a").click ->
        link = $(this)
        editor.focus()
        QEditor.action(this,"formatBlock",link.data("name"))
        editor.change()
        link.parent().parent().parent().removeClass("open")
        return false

      toolbar.find("button[data-action]").click ->
        editor.focus()
        QEditor.action(this,$(this).attr("data-action"))
        editor.change()
        QEditor.checkSectionState(editor)

      editor.before(toolbar)
