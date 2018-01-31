local Erogodic = {
  _VERSION     = 'erogodic v0.1.0',
  _URL         = 'https://github.com/oniietzschan/erogodic',
  _DESCRIPTION = 'A library for scripting branching interactive narrative.',
  _LICENSE     = [[
    Massachusecchu... あれっ！ Massachu... chu... chu... License!

    Copyright (c) 1789 shru

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

local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end

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
  assertType(scriptFn, 'function', 'script function')
  self._attributes = {}
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
    self:_yield({
      msg = text,
      options = self._options,
    })
  end
  function env.msg(text)
    self:_yield({msg = text})
  end
  env.selection = setmetatable({}, {
    __call = function()
      return self._selection
    end,
  })
  function env.option(option)
    assertType(option, 'string', 'option')
    table.insert(self._options, option)
  end
  self._env = env
  setfenv(scriptFn, self._env)
  self._scriptCoroutine = coroutine.create(scriptFn)
end

function Script:_yield(node)
  for k, v in pairs(self._attributes) do
    node[k] = v
  end
  coroutine.yield(node)
end

function Script:addMacro(name, attributes)
  assertType(name, 'string', 'macro name')
  assertType(attributes, 'table', 'attributes')
  self._env[name] = function(text)
    for k, v in pairs(attributes) do
      self._attributes[k] = v
    end
    if text then
      self._env.msg(text)
    end
  end
  return self
end

function Script:defineAttributes(attributeNames)
  assertType(attributeNames, 'table', 'attributeNames')
  for _, attrName in ipairs(attributeNames) do
    assertType(attributeNames, 'table', 'attributeNames')
    self._env[attrName] = function(val)
      self._attributes[attrName] = val
    end
  end
  return self
end

function Script:extendEnvironment(t)
  assertType(t, 'table', 'environment table')
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
