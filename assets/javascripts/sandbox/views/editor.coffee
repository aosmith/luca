Sandbox.views.Editor = Luca.View.extend
  name: "editor"
  id: "editor_container"
  autoBindEventHandlers: true

  beforeRender: ()->
    _.bindAll @, "onChange"
    $(@el).append("<div id='coffee-script-editor' style='width:100%;height:100%;'/>")

  render: ()->
    Luca.View::render.apply(@, arguments)
    @

  afterRender: ()->
    height = @$el.parent().height()
    width = @$el.parent().width()

    height = 500 if height is 0

    @$el.width( width )
    @$el.height( height )

    @$('#coffee-script-editor').css
      height: "#{ height }px"
      width: "#{ width }px"
      position: "relative"

    @setupEditor()

  getSelection: ()->
    @editor.getSession().doc.getTextRange( @editor.getSelectionRange() );

  setupEditor: ()->
    @editor = ace.edit("coffee-script-editor")
    @editor.setTheme "ace/theme/twilight"
    @editor.session.setMode("ace/mode/coffee")
    @editor.setShowPrintMargin false
    @editor.getSession().setUseWrapMode(true);
    @editor.getSession().on('change', @onChange)
    @editor.session.setValue( localStorage.getItem("canvas-tool-editor-content") )
    @editor

  canvas: _.memoize ()->
    Luca.cache("canvas")

  onChange: _.idleShort ()->
    try
      code = @editor.session.getValue()
      localStorage.setItem("canvas-tool-editor-content", code)
      @newCompiled = CoffeeScript.compile(code,bare:true)

      if @newCompiled isnt @oldCompiled
        @canvas().run( @newCompiled )
        @oldCompiled = @newCompiled

    catch error
      false

