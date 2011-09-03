
path = require 'path'
process = require '../process'

module.exports = (settings) ->
    # Validation
    throw new Error 'No shell provided' if not settings.shell
    shell = settings.shell
    # Default settings
    settings.workspace ?= shell.project_dir;
    throw new Error 'No workspace provided' if not settings.workspace
    settings.message_start ?= 'HTTP server successfully started'
    settings.message_stop ?= 'HTTP server successfully stopped'
    # Register commands
    http = null
    shell.on 'exit', () ->
        http.kill() if shell.isShell and not settings.detach and http
    shell.cmd 'http start', 'Start HTTP server', (req, res, next) ->
        if path.existsSync settings.workspace + '/server.js'
            cmd = 'node ' + settings.workspace + '/server'
        else if path.existsSync settings.workspace + '/server.coffee'
            cmd = 'coffee ' + settings.workspace + '/server.coffee'
        else if path.existsSync settings.workspace + '/app.js'
            cmd = 'node ' + settings.workspace + '/app'
        else if path.existsSync settings.workspace + '/app.coffee'
            cmd = 'coffee ' + settings.workspace + '/app.coffee'
        else
            next new Error 'Failed to discover a "server.js" or "app.js" file'
        http = process.start shell, settings, cmd, (err) ->
            message = "HTTP server started"
            res.cyan( message ).ln()
            res.prompt()
    shell.cmd 'http stop', 'Stop HTTP server', (req, res, next) ->
        process.stop settings, http, (err, success) ->
            if success
            then res.cyan('HTTP server successfully stoped').ln()
            else res.magenta('HTTP server was not started').ln()
            res.prompt()
