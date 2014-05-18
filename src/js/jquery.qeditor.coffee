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
    <button type="button" data-action="bold" class="btn btn-default btn-sm qe-bold" title="Bold" data-toggle="tooltip"><i class="fa fa-bold"></i></button>
    <button type="button" data-action="italic" class="btn btn-default btn-sm qe-italic" title="Italic" data-toggle="tooltip"><i class="fa fa-italic"></i></button>
    <button type="button" data-action="underline" class="btn btn-default btn-sm qe-underline" title="Underline" data-toggle="tooltip"><i class="fa fa-underline"></i></button>
    <button type="button" data-action="strikethrough" class="btn btn-default btn-sm qe-strikethrough" title="Strike-through" data-toggle="tooltip"><i class="fa fa-strikethrough"></i></button>
    <div class="btn-group qe-heading">
      <button type="button" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" title="Heading">
        <i class="fa fa-font"></i>
      </button>
      <ul class="dropdown-menu qe-menu" role="menu">
        <li><a href="#" data-name="h2" class="qe-h2"><h2>Large</h2></a></li>
        <li><a href="#" data-name="h3" class="qe-h3"><h3>Medium</h3></a></li>
        <li><a href="#" data-name="h4" class="qe-h4"><h4>Small</h4></a></li>
      </ul>
    </div>
    <button type="button" data-action="insertorderedlist" class="btn btn-default btn-sm qe-ol" title="Insert Ordered-list" data-toggle="tooltip"><i class="fa fa-list-ol"></i></button>
    <button type="button" data-action="insertunorderedlist" class="btn btn-default btn-sm qe-ul" title="Insert Unordered-list" data-toggle="tooltip"><i class="fa fa-list-ul"></i></button>
    <button type="button" data-action="insertHorizontalRule" class="btn btn-default btn-sm qe-hr" title="Insert Horizontal Rule" data-toggle="tooltip"><i class="fa fa-minus"></i></button>
    <button type="button" data-action="blockquote" class="btn btn-default btn-sm qe-blockquote" title="Blockquote" data-toggle="tooltip"><i class="fa fa-quote-left"></i></button>
    <button type="button" data-action="pre" class="btn btn-default btn-sm qe-pre" title="Pre" data-toggle="tooltip"><i class="fa fa-code"></i></button>
    <button type="button" data-action="createLink" class="btn btn-default btn-sm qe-link" data-toggle="popover" title="Create Link"><i class="fa fa-link"></i></button>
    <button type="button" data-action="insertimage" class="btn btn-default btn-sm qe-image" data-toggle="popover" title="Insert Image"><i class="fa fa-picture-o"></i></button>
  </div>
  <div class="btn-group pull-right">
    <button type="button" data-action="removeFormat" class="btn btn-default btn-sm" title="Remove format" data-toggle="tooltip"><i class="fa fa-eraser"></i></button>
    <button type="button" onclick="return QEditor.toggleFullScreen(this);" class="btn btn-default btn-sm qe-fullscreen" title="Toggle Fullscreen" data-toggle="tooltip"><i class="fa fa-arrows-alt"></i></button>
  </div>
</div>
"""

QEDITOR_ALLOW_TAGS_ON_PASTE = "a,div,p,ul,ol,li,hr,br,b,strong,i,em,img,h1,h2,h3,h4,h5,h6"
QEDITOR_DISABLE_ATTRIBUTES_ON_PASTE = ["style","class","id","name","width","height"]

window.QEditor =
  actions : ['bold','italic','underline','strikethrough','insertunorderedlist','insertorderedlist','blockquote','pre']

  action : (el,a,p) ->
    editor = $(".qeditor_preview", $(el).parent().parent().parent())
    editor.find(".qeditor_placeholder").remove()
    editor.focus()
    p = false if p == null

    if a == "blockquote" && !(QEditor.isWraped("blockquote") || QEditor.isWraped("pre"))
      QEditor.blockquote()
      return
    if a == "pre" && !(QEditor.isWraped("blockquote") || QEditor.isWraped("pre"))
      QEditor.code()
      return
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

    # # this to replace img pre blockquote by p after removeFormat
    # if a == "removeFormat" ## TODO: + check selected contains pre blockquote img
    #   document.execCommand("formatBlock", false, "p")

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
    border.find(".qe-fullscreen i").attr("class","fa fa-compress")

  exitFullScreen : () ->
    $(".qeditor_border").removeClass("qeditor_fullscreen")
                        .data("qe-fullscreen","0")
                        .find(".qe-fullscreen i").attr("class","fa fa-arrows-alt")

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

  selectContents: (contents) ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    start = contents.first()[0]
    end = contents.last()[0]
    range.setStart start, 0
    range.setEnd end, end.childNodes.length or end.length # text node don't have childNodes
    selection.removeAllRanges()
    selection.addRange range

  blockquote :  ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    rangeAncestor = range.commonAncestorContainer
    start = undefined
    end = undefined
    $blockquote = $(rangeAncestor).closest("blockquote")
    if $blockquote.length
      # remmove blockquote
      $contents = $blockquote.contents()
      $blockquote.replaceWith $contents
      QEditor.selectContents $contents
    else
      # wrap blockquote
      start = $(range.startContainer).closest("p, h1, h2, h3, h4, pre")[0]
      end = $(range.endContainer).closest("p, h1, h2, h3, h4, pre")[0]
      range.setStartBefore start
      range.setEndAfter end
      $blockquote = $("<blockquote>")
      $blockquote.html(range.extractContents()).find("blockquote").each ->
        $(this).replaceWith $(this).html()

      range.insertNode $blockquote[0]
      selection.selectAllChildren $blockquote[0]
      $blockquote.after "<p><br></p>"  if $blockquote.next().length is 0

  splitCode: (code) ->
    code.html $.map(code.text().split("\n"), (line) ->
      $("<p>").text line  if line isnt ""
    )

  code: ->
    selection = window.getSelection()
    range = selection.getRangeAt(0)
    rangeAncestor = range.commonAncestorContainer
    start = undefined
    end = undefined
    $contents = undefined
    $code = $(rangeAncestor).closest("code")
    if $code.length
      # remove code
      if $code.closest("pre").length
        # pre code
        QEditor.splitCode $code
        $contents = $code.contents()
        $contents = $("<p><br></p>")  if $contents.length is 0
        $code.closest("pre").replaceWith $contents
        QEditor.selectContents $contents
      else
        # inline code
        $contents = $code.contents()
        $code.replaceWith $code.contents()
        QEditor.selectContents $contents
    else
      # wrap code
      isEmptyRange = (range.toString() is "")
      isWholeBlock = (range.toString() is $(range.startContainer).closest("p, h1, h2, h3, h4").text())
      hasBlock = (range.cloneContents().querySelector("p, h1, h2, h3, h4"))
      if isEmptyRange or isWholeBlock or hasBlock
        # pre code
        start = $(range.startContainer).closest("p, h1, h2, h3, h4")[0]
        end = $(range.endContainer).closest("p, h1, h2, h3, h4")[0]
        range.setStartBefore start
        range.setEndAfter end
        $code = $("<code>").html(range.extractContents())
        $pre = $("<pre>").html($code)
        range.insertNode $pre[0]
        $pre.after "<p><br></p>"  if $pre.next().length is 0
      else
        # inline code
        $code = $("<code>").html(range.extractContents())
        range.insertNode $code[0]
      selection.selectAllChildren $code[0]

  isWraped: (selector) ->
    if QEditor.commonAncestorContainer()
      $(QEditor.commonAncestorContainer()).closest(selector).length isnt 0
    else
      false

  commonAncestorContainer: ->
    selection = document.getSelection()
    selection.getRangeAt(0).commonAncestorContainer  if selection.rangeCount isnt 0

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
        # wrap the first line by <p> and avoid firefox's <br>
        html_str = $(this).html().trim()
        if html_str.length == 0 || html_str == "<br>"
          document.execCommand("formatBlock",false,"p")
        # node = QEditor.getCurrentContainerNode()
        # nodeName = ""
        # if node and node.nodeName
        #   nodeName = node.nodeName.toLowerCase()
        # if e.keyCode == 13 && !(e.ctrlKey or e.shiftKey)
        #   if nodeName == "blockquote" or nodeName == "pre"
        #     e.stopPropagation()
        #     document.execCommand('InsertParagraph',false)
        #     document.execCommand("formatBlock",false,"p")
        #     document.execCommand('Outdent',false)
        #     return false
        if e.keyCode == 13 && !(e.ctrlKey or e.shiftKey)
         if document.queryCommandValue("formatBlock") is "pre"
           event.preventDefault()
           selection = window.getSelection()
           range = selection.getRangeAt(0)
           rangeAncestor = range.commonAncestorContainer
           $pre = $(rangeAncestor).closest("pre")
           range.deleteContents()
           isLastLine = ($pre.find("code").contents().last()[0] is range.endContainer)
           isEnd = (range.endContainer.length is range.endOffset)
           node = document.createTextNode("\n")
           range.insertNode node
           # keep two \n at the end, fix webkit eat \n issues.
           $pre.find("code").append document.createTextNode("\n")  if isLastLine and isEnd
           range.setStartAfter node
           range.setEndAfter node
           selection.removeAllRanges()
           selection.addRange range

      obj.hide()
      obj.wrap('<div class="qeditor_border"></div>')
      obj.after(editor)

      # render toolbar & binding events
      toolbar = $(QEDITOR_TOOLBAR_HTML)
      toolbar.find('button[data-toggle=tooltip], button[data-toggle=popover]').tooltip container: 'body'
      toolbar.find('button[data-toggle=tooltip], button[data-toggle=popover]').mouseover ->
        $(this).tooltip('show')
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
