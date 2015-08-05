applescript = require('../inc/node-applescript/applescript');
$ = require('../inc/jquery-2.1.4.min.js');
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    autoPause:
      title: 'Auto Pause Codekit Filewatching'
      description: 'Auto pause/unpause Codekit file watching when Atom window is/isn\'t in focus'
      type: 'boolean'
      default: true
    autoStart:
      title: 'Auto Start Codekit'
      description: 'Auto start Codekit when Atom window is opened'
      type: 'boolean'
      default: true
    autoQuit:
      title: 'Auto Quit Codekit'
      description: 'Auto quit Codekit when Atom window is closed'
      type: 'boolean'
      default: true

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
    if atom.config.get('codekit-commands.autoStart')
      script = 'tell application "CodeKit" to launch'
      applescript.execString(script)

  quitCodekit: ->
    if atom.config.get('codekit-commands.autoQuit')
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
    if atom.config.get('codekit-commands.autoPause')
      script = "tell application \"CodeKit\" to pause file watching"
      applescript.execString(script)

  unpauseProject: ->
    if atom.config.get('codekit-commands.autoPause')
      script = "tell application \"CodeKit\" to unpause file watching"
      applescript.execString(script)
