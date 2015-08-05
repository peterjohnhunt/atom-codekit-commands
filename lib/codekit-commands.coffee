applescript = require('../inc/node-applescript/applescript');
$ = require('../inc/jquery-2.1.4.min.js');
{CompositeDisposable} = require 'atom'

module.exports = CodekitCommands =
  config:
    someInt:
      type: 'integer'
      default: 23
      minimum: 1

  subscriptions: null

  activate: ->
    @switchProject(atom.workspace.getActivePaneItem())
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'codekit-commands:previewProject': => @previewProject()
    @subscriptions.add atom.commands.add 'atom-workspace', 'codekit-commands:refreshProject': => @refreshProject()
    @subscriptions.add atom.commands.add '.project-root > .header', 'codekit-commands:addProject': => @addProject()
    @subscriptions.add atom.workspace.onDidChangeActivePaneItem (callback) => @switchProject(callback)
    @subscriptions.add $(window).on 'load', => @startCodekit()
    @subscriptions.add $(window).on 'unload', => @quitCodekit()
    @subscriptions.add $(window).on 'blur', => @pauseProject()
    @subscriptions.add $(window).on 'focus', => @unpauseProject()

  deactivate: ->
    @subscriptions.dispose()


  startCodekit: ->
    script = 'tell application "CodeKit" to launch'
    applescript.execString(script)

  quitCodekit: ->
    script = 'tell application "CodeKit" to quit'
    applescript.execString(script)

  previewProject: ->
    script = 'tell application "CodeKit" to preview in browser'
    applescript.execString(script)

  refreshProject: ->
    script = 'tell application "CodeKit" to refresh browsers'
    applescript.execString(script)

  addProject: ->
    treeView = atom.packages.getLoadedPackage('tree-view');
    treeView = require(treeView.mainModulePath);
    packageObj = treeView.serialize();
    script = "tell application \"CodeKit\" to add project at path \"#{packageObj.selectedPath}\""
    applescript.execString(script)

  switchProject: (newPanel) ->
    if newPanel
      if newPanel.buffer
        if newPanel.buffer.file
          script = "tell application \"CodeKit\" to select project containing path \"#{newPanel.buffer.file.path}\""
          applescript.execString(script)

  pauseProject: ->
    script = "tell application \"CodeKit\" to pause file watching"
    applescript.execString(script)

  unpauseProject: ->
    script = "tell application \"CodeKit\" to unpause file watching"
    applescript.execString(script)
