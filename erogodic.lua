--[[

erogodic v3.0.0
===============

A library for scripting branching interactive narrative by shru.

https://github.com/oniietzschan/erogodic

Massachusecchu... あれっ！ Massachu... chu... chu... License!
-----------------------------------------------------------

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

--]]

local function assertType(obj, expectedType, name)
  assert(type(expectedType) == 'string' and type(name) == 'string')
  if type(obj) ~= expectedType then
    error(name .. ' must be a ' .. expectedType .. ', got: ' .. tostring(obj), 2)
  end
end

local PUSHED_SCRIPT = 'PUSHED_SCRIPT'

local Script = {}
local ScriptMetaTable = {__index = Script}

function Script:new(scriptFn)
  assertType(scriptFn, 'function', 'script function')
  self._attributes = {}
  self._selection = nil
  self._options = {}
  self._onMenu = false
  self._scriptStack = {}
  self._argsStack = {}
  self:_initEnvironment()
  self:_pushScript(scriptFn)
  return self
end

function Script:_initEnvironment()
  local env = setmetatable({}, {__index = _G})
  function env.get(attribute)
    return self._attributes[attribute]
  end
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
  function env.selection(option)
    return self._selection == option
  end
  function env.option(option)
    assertType(option, 'string', 'option')
    table.insert(self._options, option)
    return option
  end
  self._env = env
end

function Script:_pushScript(scriptFn, ...)
  setfenv(scriptFn, self._env)
  local scriptCoroutine = coroutine.create(scriptFn, ...)
  self._currentScript = scriptCoroutine
  self._currentArgs = {...}
  table.insert(self._scriptStack, scriptCoroutine)
  table.insert(self._argsStack, self._currentArgs)
end

function Script:_popScript()
  table.remove(self._scriptStack)
  table.remove(self._currentArgs)
  local len = #self._scriptStack
  self._currentScript = (len >= 1) and self._scriptStack[len] or nil
  self._currentArgs   = (len >= 1) and self._argsStack[len]   or nil
end

function Script:_yield(node)
  for k, v in pairs(self._attributes) do
    node[k] = v
  end
  coroutine.yield(node)
end

function Script:addMacro(name, fn)
  assertType(name, 'string', 'macro name')
  assertType(fn, 'function', 'macro function')
  self._env[name] = function(...)
    self:_pushScript(fn, ...)
    coroutine.yield(PUSHED_SCRIPT)
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
  error("Selection '" .. selection .. "' was not one of the options.")
end

function Script:next()
  if self:hasNext() == false then
    error('Script is finished.')
  end
  if self._onMenu then
    return self._currentNode -- Can not skip a question.
  end
  local isRunning, result = coroutine.resume(self._currentScript, unpack(self._currentArgs))
  if result == PUSHED_SCRIPT then
    return self:next()
  elseif isRunning == false then
    error('Error executing script: ' .. tostring(result))
  end

  self._currentNode = result

  if self:hasNext() == false then
    self:_popScript()
    if self._currentScript ~= nil then
      return self:next()
    end
  end

  return self._currentNode
end

function Script:hasNext()
  return self._currentScript ~= nil and coroutine.status(self._currentScript) == 'suspended'
end

return function(...)
  return setmetatable({}, ScriptMetaTable)
    :new(...)
end
