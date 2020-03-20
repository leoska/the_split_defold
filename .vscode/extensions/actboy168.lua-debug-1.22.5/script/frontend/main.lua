local port = ...
local fs = require 'bee.filesystem'
local network = require 'frontend.network'
local select = require "common.select"
local proxy = require 'frontend.proxy'
local vscode
WORKDIR = fs.exe_path():parent_path():parent_path():parent_path()

local function update()
    while true do
        local pkg = vscode.recvmsg()
        if pkg then
            proxy.send(pkg)
        else
            return
        end
    end
end

local function run()
    if port then
        vscode = network('127.0.0.1:'..port)
    else
        vscode = require 'frontend.stdio'
        --vscode.debug(true)
    end
    proxy.init(vscode)

    while true do
        select.update(0.05)
        proxy.update()
        update()
    end
end

local log = require 'common.log'
log.root = (WORKDIR / "script"):string()
log.file = (WORKDIR / "client.log"):string()
print = log.info

local ok, errmsg = xpcall(run, debug.traceback)
if not ok then
    log.error(errmsg)
end
