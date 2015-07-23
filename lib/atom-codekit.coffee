applescript = require('../inc/node-applescript/applescript');
{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null
  activate: ->
    @switchProject(atom.workspace.getActivePaneItem())
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-codekit:previewProject': => @previewProject()
    @subscriptions.add atom.workspace.onDidChangeActivePaneItem (callback) => @switchProject(callback)

  deactivate: ->
    @subscriptions.dispose()

  startCodekit: ->
    script = 'tell application "CodeKit" to launch'
    applescript.execString(script)

  previewProject: ->
    script = 'tell application "CodeKit" to preview in browser'
    applescript.execString(script)

  switchProject: (newPanel) ->
    if newPanel
      if newPanel.buffer
        if newPanel.buffer.file
          script = "tell application \"CodeKit\" to select project containing path \"#{newPanel.buffer.file.path}\""
          applescript.execString(script)
