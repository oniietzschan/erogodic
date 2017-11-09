local Erogodic = {
  _VERSION     = 'erogodic v0.0.0',
  _URL         = 'https://github.com/oniietzschan/erogodic',
  _DESCRIPTION = 'A library for scripting branching interactive narrative.',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 Retia Adolf

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 【AS IZ】, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE. PLEASE HAVE A FUN AND BE GENTLE WITH THIS SOFTWARE.
  ]]
}

local Script = {}
local ScriptMetaTable = {__index = Script}

function Erogodic:__call(...)
  return self:newScript(...)
end

function Erogodic:newScript(...)
  return setmetatable({}, ScriptMetaTable)
    :initialize(...)
end

function Script:initialize(scriptFn)
  self._selection = nil
  self._options = {}
  self._onMenu = false
  self:_setScriptCoroutine(scriptFn)
  return self
end

function Script:_setScriptCoroutine(scriptFn)
  local env = setmetatable({}, {__index = _G})
  function env.menu(text)
    self._onMenu = true
    coroutine.yield({
      msg = text,
      options = self._options,
    })
  end
  function env.msg(text)
    coroutine.yield({msg = text})
  end
  env.selection = setmetatable({}, {
    __call = function()
      return self._selection
    end,
  })
  function env.option(option, callbackFn)
    assert(type(option) == 'string')
    table.insert(self._options, option)
  end
  self._env = env
  setfenv(scriptFn, self._env)
  self._scriptCoroutine = coroutine.create(scriptFn)
end

function Script:extendEnvironment(t)
  for k, v in pairs(t) do
    self._env[k] = v
  end
  return self
end

function Script:select(selection)
  for _, option in ipairs(self._options) do
    if option == selection then
      self._selection = selection
      self._options = {}
      self._onMenu = false
      return self:next()
    end
  end
  error("selection '" .. selection .. "' was not one of the options.")
end

function Script:next()
  if self._onMenu then
    return self._currentNode -- Can not skip a question.
  end
  local isRunning
  isRunning, self._currentNode = coroutine.resume(self._scriptCoroutine)
  if isRunning == true then
    return self._currentNode
  else
    error('Error executing script: ' .. self._currentNode)
  end
end

function Script:hasNext()
  local status = coroutine.status(self._scriptCoroutine)
  return status == 'suspended'
end

local ErogodicMetaTable = {
  __index = Erogodic,
  __call = Erogodic.__call,
}

return function() return setmetatable({}, ErogodicMetaTable) end
