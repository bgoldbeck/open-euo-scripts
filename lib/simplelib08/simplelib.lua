-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--[[ simplelib.lua                                                         ]]--
--[[ http://www.easyuo.com/openeuo/wiki/index.php/Simplelib                ]]--
--[[ v. 0.07                                                               ]]--
--[[ 20110108                                                              ]]--
--[[ ximan                                                                 ]]--
--[[ see end for credits                                                   ]]--
--[[ usage:                                                                ]]--
--[[ local sl = dofile(getinstalldir()..'lib/simplelib.lua')               ]]--
--[[ sl.slversion()  -- returns the version                                ]]--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- set version ----------------------------------------------------------------
local _cversion     = 0.07
local _creleasedate = '20110108'

-- see http://www.lua.org/pil/16.4.html to understand object model.
-- objects are implemented as closures, so the colon calling syntax
-- e.g. object:method() is --never-- valid to use with simplelib objects.
-- just use the dot operator, e.g. object.method()
-- this applies to the object returned by the initial dofile call, as well.


-------------------------------------------------------------------------------
-- POST EDIT FIXUP ------------------------------------------------------------
-------------------------------------------------------------------------------

-- fixup these locations:
--   update _probelinenum with proper value               ( near line no. 268 )
--   set debug to false                                   ( near line no. 111 )

-------------------------------------------------------------------------------
-- FUNCTION PREFIX MEANINGS ---------------------------------------------------
-------------------------------------------------------------------------------

-- a __ prefix denotes a name that is local to the library and 
-- not intended to be exposed in any way (added to any interface table)
-- i.e., call directly, but only from library file

-- a _ prefix to a name means that it is incorporated into a state or
-- interface table and should be called from that table, not directly.

-- a gen_ prefix signifies a chunk created by loadstring on a string
-- generated solely by the library.

-- a usr_ prefix signifies either a chunk created by loadstring upon
-- a string or, or a handler or function supplied by the library end-user.


-------------------------------------------------------------------------------
--INITIALIZATION---------------------------------------------------------------
-------------------------------------------------------------------------------

-- check if library is already initialized in current environment--------------
if simple_lib_soliton__ ~= nil then
    print(string.rep('-',80))
  if type(simple_lib_soliton__) ~= 'function' then
    print('Reinitializing simplelib.')
    print(string.rep('-',80))
 else
    print('The simplelib is already defined,'..
          ' returning initialized global library object.')
    print(string.rep('-',80))
    return simple_lib_soliton__()
  end
end

-- define unique placeholders and semaphore return values ---------------------
-- none of these should be returned to user unless
-- if a public closure produces an error, and inline
-- exception reporting is enabled, then return (ERR, _eref) tuple
local ES     = ''              -- empty string
local null   = {math.huge}     -- nil placeholder
local ET     = {null}          -- empty table        
local OK     = {{null}}        -- ok semaphore, results follow
local ERR    = {{{null}}}      -- error, error reference number follows
local EOF    = {{{{null}}}}    -- end of file reached
if null == ES or null == ET or null == OK or null == ERROR or null == EOF then
  print('Something odd about this version of Lua.')
  stop()
end

-- set error redirection ------------------------------------------------------
-- _flags: 
-- 'p' is print,
-- 'r' is record to file,
-- 'c' is call user supplied callback function, trumps 'i' if both specified
-- 'i' is inline error tuple (in lieu of default reraise action)
-- 'n' if 'i' is also specified, then function will return nil , eref
--     instead of ERR, eref
-- _file object added upon opening
local _credirection = {_filename=getinstalldir()..'/lib/slerrorlog.txt',
                      _flags='p', _maxfilesz=100000, _curfilesz=0}
                      

-- set verbosity --------------------------------------------------------------
-- states:
-- 'off' turn error recording completely off
-- 'lo'  errors sent to file only, if redirection so allows
-- 'med' errors sent to file and or output window
-- 'hi'  library will raise unhandled exception upon any error
local _cverbosity = 'med'

-- set local file name --------------------------------------------------------
local _cname      = '/lib/simplelib.lua'

-- localized print or remove --------------------------------------------------
local isdebug = true
local dbprint = function(...)
  if isdebug then print(...) end
end

-- type string lookup tables --------------------------------------------------
local ttyplk = 
  {
  _any       = 'a',
  _anybutnil = 'z',
  _number    = 'n',
  _string    = 's',
  _function  = 'f',
  _table     = 't',
  _boolean   = 'b',
  _nil       = '-',  
  }
  
local trevtyplk =
  {
  [ 97]      = 'any',
  [ 98]      = 'boolean',
  [102]      = 'function',
  [110]      = 'number',
  [114]      = 'ellipses',
  [115]      = 'string',
  [116]      = 'table',
  [122]      = 'anybutnil',
  ['-']      = 'nil',
  a          = 'any',
  b          = 'boolean',
  f          = 'function',
  n          = 'number',
  r          = 'ellipses',
  s          = 'string',
  t          = 'table',
  z          = 'anybutnil',
  [null]     = 'nil result',
  [ERR]      = 'error result',
  [OK]       = 'ok result',
  [ET]       = 'empty table',
  [ES]       = 'empty string',
  [EOF]      = 'end of file',
  }
 
 
-------------------------------------------------------------------------------
--CLOSURE - LIBRARY STATE------------------------------------------------------
-------------------------------------------------------------------------------

-- self var name used for state of simplelib closure object
-- use var name gself for shared generator state
-- use var name lself for local object states
local self = {
  errors      = {},
  name        = _cname,
  objects     = {},
  redirection = _credirection,
  version     = _cversion,
  verbosity   = _cverbosity,
  imported    = {_camel=false, _lower=false, _upper=false, _imported=false},
  }
-- other keys added at finalization:
-- pface -> public methods interface of the library
-- iface -> internal methods interface of the library
-- then meta table is set and sealed
  
  
-------------------------------------------------------------------------------
--ERROR TRACING, ALT DEBUG.GETINFO --------------------------------------------
-------------------------------------------------------------------------------

-- raise an error specifying depth -------------------------------------------- 
local __fmakeinfo = function(ndepth)
  local a = ndepth + 3 -- adj depth to match debug.getinfo depth!
  local b = 'err '..tostring(ndepth)
  if a >= 0 then
    error(b,a)
  end
  return
end
  
-- debug.info or replacement --------------------------------------------------
-- raise and catch an error at specific depth
local _fgetinfo = function(ndepth)
  local defret = {
  isfake          = '',
  linedefined     = 0,
  currentline     = 0,
  lastlinedefined = 0,
  func            = '',
  source          = '',
  nups            = 0,
  what            = 'Lua',
  namewhat        = 'field',
  name            = '',
  short_src       = ''
  }
  
  local ret = {} 
  -- 
  if debug ~= nil and type(debug) == 'table' and debug.getinfo ~= nil then
    -- if cheffe exposes it in future...
    ret = debug.getinfo(ndepth)
    if ret == nil then
      ret = defret
      ret.isfake = 'too high '
    else
      ret.isfake    = 'debug    '
      --ret.short_src = ret.short_src
    end    
  elseif info ~= nil and type(info) == 'table' and info.getinfo ~= nil then
    -- ximan expanded lua51.dll series
    ret = info.getinfo(ndepth)
    if ret == nil then
      ret = defret
      ret.isfake = 'too high '
    else
      ret.isfake    = 'info     '
      --ret.short_src = ret.short_src
    end 
  else --
    -- fake it
    local bres, serr = pcall(__fmakeinfo, ndepth)
    defret.isfake    = 'fake     '
    defret.short_src = tostring(serr)
    if string.sub(serr,1,3) == 'err' then
      defret.isfake = 'too high '
      defret.short_src = serr
      --dbprint(serr)
    else
      -- parse out a line number
      local i = string.find(serr,':',1,true) + 1
      local j = string.find(serr,':',i,true) - 1
      local s = string.sub(serr,i,j)
      --dbprint(s)
      defret.currentline = s
      defret.short_src   = string.sub(serr,1,i-2)
      --dbprint(defret.short_src)
    end
    ret = defret
  end -- end fake it else clause
  --dbprint(ret.isfake..ret.short_src..' '..ret.currentline)
  return ret 
end 

-- gather getinfo at every depth ----------------------------------------------
local _maxprobedepth = 16
-- fixup
local _probelinenum  = '265'                -- set after any edit of this file!
local _probelibname  = 'simplelib.lua'
local _probe = function(...)
  local i = 0
  local ginfo,tginfo = {},{_type = 'table:probe', _maxlvl = -1, _caller = -1}
  while i < _maxprobedepth do
    ginfo = self.iface.getinfo(i)           -- <--------- _problelinenum line #
    --if ginfo.isfake == 'too high ' then break end
    tginfo[i]=ginfo
    tginfo._maxlvl = i
    if string.find(ginfo.short_src,_probelibname,1,true) 
    and tostring(ginfo.currentline) == _probelinenum then
      tginfo._caller = i
    end
    i = i + 1
  end
  -- remove levels over top of stack
  i = i - 1
  while i > 0 do
    if tginfo[i].isfake == 'too high ' then tginfo._maxlvl = i -1 tginfo[i] = nil else break end
    i = i - 1
  end
  dbprint('_maxlvl is '..i)
  dbprint('_caller is '..tginfo._caller)
  i = 0
  --dbprint
  while i <= tginfo._maxlvl do
    --dbprint(tginfo[i].isfake..tginfo[i].short_src..' '..tginfo[i].currentline)
    i = i + 1
  end
  return tginfo
end


-------------------------------------------------------------------------------
--CONDITION REPORTING----------------------------------------------------------
-------------------------------------------------------------------------------

-- create a default exception table for entry into self.errors ----------------
local __mkex = function (name,msg,probe)
  local e = 
  {
  _type = 'table:exception',
  _errid   = 0,
  _errname = name  or 'SL unknown error: ',
  _errmsg  = msg   or ' no error message provided',
  _probe   = probe or self.iface.probe(),
  }
  return e  
end

-- empty the error record and garbage collect ---------------------------------
local _clrerrors = function()
  self.errors = {}
  collectgarbage('collect')
end

-- get error object from reference number -------------------------------------
local _geterr = function(n)
  if n == nil or type(n) ~= 'number' or self.errors[n] == nil then return nil end
  return self.errors[n]
end

-- log error to error file ----------------------------------------------------
local _logerr = function(n)
  if n==nil or type(n) ~= 'number' or self.errors[n] == nil then return nil end
  dbprint('logging '..tostring(n))
  dbprint(self.errors[n]._errname..self.errors[n]._errmsg)
  
  -- check if open, if not, open it
  if self.redirection._file == nil then
    self.redirection._file = openfile(self.redirection._filename,'w+b')
    self.redirection._file:setvbuf('full')
    self.redirection._curfilesz = 0    
  end
  
  local s = string.rep('-',80)..'\013\010'
  s = s..self.errors[n]._errname..self.errors[n]._errmsg
  
  if self.verbosity == 'hi' then
    -- add full stack trace
    if self.errors[n]._probe ~= nil and self.errors[n]._probe._maxlvl >= 0 then
      for i = 0,self.errors[n]._probe._maxlvl do
        s = s..self.errors[n]._probe[i].short_src..' '..self.errors[n]._probe[i].currentline..'\013\010'
      end
    end
  end
  
  -- write
  self.redirection._file:write(s)
  -- flush
  self.redirection._file:flush()
  -- update filesize
  self.redirection._curfilesz = self.redirection._curfilesz + #s
  -- if max size, close and reopen
  if self.redirection._maxfilesz < self.redirection._curfilesz then
    self.redirection._file:close()
    self.redirection._file = openfile(self.redirection._filename,'w+b')
    self.redirection._file:setvbuf('full')
    self.redirection._curfilesz = 0
  end
  
  return true
end

-- log error to output window -------------------------------------------------
local _printerr = function(n)
  if n == nil or type(n) ~= 'number' or self.errors[n] == nil then return nil end
  
  local s = string.rep('-',80)..'\013\010'
   print(s..self.errors[n]._errname..self.errors[n]._errmsg..s)
   return true
end

-- set condition reporting redirection ----------------------------------------
local _redirect = function(flags,filename,callback)
  if flags == nil or type(flags) ~= 'string' then return nil end
  local newflag = ''
  if string.find(flags,'p',1,true) then newflag = newflag..'p' end
  if string.find(flags,'i',1,true) then newflag = newflag..'i' end
  if string.find(flags,'r',1,true) then newflag = newflag..'r' end
  if string.find(flags,'c',1,true) then newflag = newflag..'c' end
  if string.find(flags,'n',1,true) then newflag = newflag..'n' end
  
  if filename ~= nil and type(filename) == 'string' and filename ~= '' then
    if self.redirection._file ~= nil then self.redirection._file:close() end
    self.redirection._file = nil
    self.redirection._filename  = filename
    self.redirection._curfilesz = 0
  end
  
  if callback ~= nil and type(callback) == 'function' then
    self.redirection._callback = callback
  end
  
  local oldflag = self.redirection._flags
  self.redirection._flags = newflag
  return oldflag
end

-- report/record condition according to verbosity/redirection -----------------
local _reporterr = function(...)
  local argz = {...}
  local cnt  = select('#',...)
  if cnt == 0 then return 0 end
  if argz[1] ~= nil then
    if type(argz[1]) == 'string' then
      local e = __mkex(nil,argz[1],nil)      
      local n = #self.errors + 1
      e._errid = n
      self.errors[n] = e
      if self.verbosity ~= 'off' then
        if string.find(self.redirection._flags,'p',1,true) and 
           self.verbosity ~= 'lo' then self.iface.printerr(n) end
        if string.find(self.redirection._flags,'r',1,true) then
          self.iface.logerr(n) end
      end
      return n
    elseif type(argz[1]) == 'table' and argz[1]._type == 'table:exception' then
      local n = #self.errors + 1
      argz[1]._errid = n
      self.errors[n] = argz[1]
      if self.verbosity ~= 'off' then
        if string.find(self.redirection._flags,'p',1,true) and
           self.verbosity ~= 'lo' then self.iface.printerr(n) end
        if string.find(self.redirection._flags,'r',1,true) then
          self.iface.logerr(n) end
      end
      return n
    else
      return 0
    end
  else
    return 0
  end  
end

-- redirect error according to redirection settings ---------------------------
local __redir = function(eref, lvl)
local level = 1
if lvl ~= nil and type(lvl) == 'number' then level = lvl end
    
    if     string.find(self.redirection._flags,'c',1,true) and
           type(self.redirection._callback) == 'function' then
      return self.redirection._callback(eref) 
    elseif string.find(self.redirection._flags,'i',1,true) then
      if string.find(self.redirection._flags,'n',1,true) then
        return nil, eref
      else
        return ERR, eref
      end
    else
      error(self.errors[eref]._errname..self.errors[eref]._errmsg,level)
    end

end


-------------------------------------------------------------------------------
--SIMPLE TRY CATCH EXCEPTION HANDLING FUNCTIONALITY ---------------------------
-------------------------------------------------------------------------------

-- dofile(getinstalldir()..'/lib/mttry.lua')
-- see http://failboat.me/2010/lua-exception-handling/
-- REMOVED
-- metatable based exception handling required debug access to
-- debug.getlocal for retrieving variable names


-- external try ---------------------------------------------------------------
-- (wrapped pcall, integrated into library condition reporting) 
-- for use in user scripts; not used internally, shouldn't be used to
-- wrap library objects (they are 'pre-wrapped with the internal try
-- variant defined further along).
local _ptry = function(ffunc,fhandler,...)
  local argz  = {...}
  local cnt   = select('#',...)
  local func  = ffunc
  local hndlr = fhandler

  if func  == nil or type(func)  ~= 'function'
  or hndlr == nil or type(hndlr) ~= 'function' then  
    -- report exception
    local e = __mkex('SL usage error: ',
                   'method try() was invoked improperly ',
                   self.iface.probe())
    if e._probe._maxlvl >= 0 then 
      e._errmsg = e._errmsg .. ' at line ' ..
      tostring(e._probe[e._probe._maxlvl].currentline) ..
      ' in ' .. e._probe[e._probe._maxlvl].short_src ..'.\013\010'
    else
      e._errmsg = e._errmsg .. '.\013\010' 
    end
    e._errmsg = e._errmsg ..'Example call: try(ffunction,fhandler,< any, ...>)\013\010'
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref)  
  end
  
  local retzh = ET
  local retz = {pcall(func,unpack(argz))}
  if retz ~= nil and retz[1] == true then
    -- ok, return everything after true  
    return unpack(retz,2)
  else
    -- pcall returned false, call supplied handler
    -- with whatever error info was returned
    retzh = {pcall(hndlr,unpack(retz,2))}
    if retzh ~= nil and retzh[1] == true then
      -- error was extinguished in handler
      -- return everything after first entry
      return unpack(retzh,2)
    else
      -- error was reraised in handler
      -- drop through
    end    
  end
  
    -- pcall returned false, error was raised by handler
    local e = {}
    local eref = 0
    -- intentionally raised, i.e., already reported?
    if retzh[2] ~= nil and type(retzh[2]) == 'string' then
      if string.find(retzh[2],'SLERRID:',1,true) then
        -- already reported in throwing function, so retrieve e,eref
        local s = string.sub(retzh[2],string.find(retzh[2],':',1,true)+1)
        e = self.errors[tonumber(s)]
        eref = e._errid
      else
        -- not reported yet, create error and report it
        print('CREATE')
        -- parse out a line number
        -- dbprint(retzh[2])
        local i = string.find(retzh[2],':',1,true) + 1
        local j = string.find(retzh[2],':',i,true) - 1
        local s = string.sub(retzh[2],1,j)        
        -- create e
        e = __mkex('SL user handler exception: ',
                   'a try() handler function raised an unknown exception.\013\010',
                   self.iface.probe())
        e._errmsg = e._errmsg .. 'At: ' ..
          s .. '.\013\010' ..
          'Exception text:' .. string.sub(retzh[2],j+2) .. '.\013\010'
        -- report it, get eref
        eref = self.iface.reporterr(e)
      end
    end
      
    -- inline, callback, or reraise according to redirection flags
  return __redir(eref) 
end

-- internal try ---------------------------------------------------------------
-- note the 'name' argument, builtin handler
-- used to wrap all public interface functions to capture all errors
-- record/redirect errors according to self.redirection._flags
local _itry = function(ffunc,fname,...)
  local argz = {...}
  local cnt  = select('#',...)
  local func = ffunc
  local name = fname
  
  -- argument mismatch
  if func == nil or type(func) ~= 'function'
  or name == nil or type(name) ~= 'string' then
    -- report exception
    local e = __mkex('SL logic error: ',
                   'an internal try() call was invoked improperly',
                   self.iface.probe())
    if e._probe._caller >= 0 then 
      e._errmsg = e._errmsg .. ' at line ' ..
      tostring(e._probe[e._probe._caller+2].currentline) ..'\013\010'..
      'in ' .. e._probe[e._probe._caller+2].short_src..'.\013\010'
    else
      e._errmsg = e._errmsg .. ' in ' .. self.name..'.\013\010' 
    end
  
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref) 
  end
  
  -- make protected call
  local retzh = ET
  local retz = {pcall(func,unpack(argz))}
  if retz ~= nil and retz[1] == true then
    -- pcall returned true, strip true and return remainder
    return unpack(retz,2)
  else
    -- pcall returned false, error was raised by function
    local e = {}
    local eref = 0
    -- intentionally raised, i.e., already reported?
    if retz[2] ~= nil and type(retz[2]) == 'string' then
      if string.find(retz[2],'SLERRID:',1,true) then
        -- already reported in throwing function, so retrieve e,eref
        local s = string.sub(retz[2],string.find(retz[2],':',1,true)+1)
        e = self.errors[tonumber(s)]
        eref = e._errid
      else
        -- not reported yet, create error and report it
        -- parse out a line number
        local i = string.find(retz[2],':',1,true) + 1
        local j = string.find(retz[2],':',i,true) - 1
        local s = string.sub(retz[2],i,j)        
        -- create e
        e = __mkex('SL logic error: ',
                   'library method '..fname..'() raised an unknown exception',
                   self.iface.probe())

        e._errmsg = e._errmsg .. ' at line ' ..
          s .. ' in ' .. self.name .. '.\013\010' ..
          'Exception text:' .. string.sub(retz[2],j+2) .. '.\013\010'
        -- report it, get eref
        eref = self.iface.reporterr(e)
      end
    end
      
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref) 
  end    
end


-------------------------------------------------------------------------------
--METATABLE - READ ONLY TABLES-------------------------------------------------
-------------------------------------------------------------------------------

local _onindex = function(t,k)
   -- provide line number(s)
   local a = self.iface.probe()
   local s = '".'
   if a ~= nil and a ~= ET and a._maxlvl >= 0 then
     s = '" at line '..tostring(a[a._maxlvl].currentline)..'.\013\010'
   end
   local e = __mkex('SL usage error: ',
                    'metatable blocked requested access to non-existent '..
                    'interface\013\010member named "'..tostring(k)..s,
                    a)
   local eref = self.iface.reporterr(e)
   
   return nil
end

local _searchindex = function(t,k)

   local kl = string.lower(k)
   for i,j in pairs(t) do
     local i = string.lower(i)
     if string.find(i,kl,1,true) ~= nil then return j end
   end

   local a = self.iface.probe()
   local s = '".'
   if a ~= nil and a ~= ET and a._maxlvl >= 0 then
     s = '" at line '..tostring(a[a._maxlvl].currentline)..'.\013\010'
   end
   local e = __mkex('SL usage error: ',
                    'library metatable blocked access to non-existent '..
                    'interface\013\010member named "'..tostring(k)..s,
                    a)
   local eref = self.iface.reporterr(e)
   
   return nil
end

local _onnew   = function(t,k,v) 
  print('SL usage error: cannot change or add to library interfaces.')
end

-- make returned closure tables 'read only'
  local _facemt =
  {
  __index     = _searchindex, --_onindex,
  __newindex  = _onnew,
  __metatable = 'SL warning    : simplelib interface metatables are sealed.'
  }
-- set this metatable on all returned interfaces


-------------------------------------------------------------------------------
--ARGUMENT PATTERN VALIDATION--------------------------------------------------
-------------------------------------------------------------------------------
  
-- report closest argument match ----------------------------------------------
local _closestmatch = function(pattern,i,j)

  --dbprint('pattern      '..tostring(pattern))
  --dbprint('i            '..tostring(i))
  --dbprint('j            '..tostring(j))
 
  if pattern == nil then return '' end
  if i < 1 then i = 1 end
  if j < 0 then j = 0 end
  
  --dbprint('pattern[i].p '..tostring(pattern[i].p))
  
  local s = tostring(pattern[i].p)
  local n = #s
  local msg = 'Example call: '..pattern.name..'('
  local r = 0
  for k = 1,n do
    if string.byte(s,k) == 114 then
      if r == 0 then
        msg = msg..'<'
        r = 1
      else
        msg = msg..' ... >'
        if k < n then msg = msg..', ' end
      end
    else
      msg = msg..trevtyplk[string.byte(s,k)]
      if k < n then msg = msg..', ' end
    end
  end
  return msg..')\013\010'
end

-- argument validation --------------------------------------------------------
local _argval = function(pattern, ...)
  local argz = {...}
  local cnt  = select('#',...)
  
  if pattern == nil or type(pattern) ~= 'table' or pattern.name == nil then
    error('argval() called without a valid pattern as first parameter',1)
  end
  
  -- shortcut: check for insufficient number of arguments
  if cnt < pattern.req then
    local p = self.iface.probe()
    local fn = pattern.name
    local ln = p[p._maxlvl].currentline
    dbprint(p._maxlvl..' '..p._caller)

    local s = 'SL usage error: '..cnt..' argument'
    if cnt ~= 1 then s = s..'s were' else s = s..' was' end
    s = s..' supplied to method '..fn
        ..'()\013\010at line '..ln..' while it appears that at least '
        ..pattern.req..' argument';
    if pattern.req == 1 then s = s..' is required.\013\010' else s = s..'s are required.\013\010' end
    
    local e = __mkex('SL usage error: ',
                     s,
                     p)
    local eref = self.iface.reporterr(e)
    return {_status=ERR, _eref=eref}
  end
  
  if cnt == 0 and pattern.req == 0 then return {_status=OK, _pat=0, _cnt=0, _argz={}} end
  
  -- best pattern number and amnt of args matched
  local pmax    = 0
  local match   = 0
  local encval  = ''
  local posvals = ''
  
  -- check for match each pattern in order
  --pause()
  for i = 1,pattern.num do
  
    -- check if proper number of arguments for the pattern
    if cnt >= pattern[i].lo and (cnt <= pattern[i].hi or pattern[i].rep == true) then
    
      -- match type and value (if given) of pattern against arguments
      local j,n = 1, string.len(pattern[i].p) -- current pattern location
      local r = 0                             -- location of last 'r'
      local a = 1                             -- current arg num
      while j <= n and a <= cnt do
      
        -- is this the repetitive operator
        if string.byte(pattern[i].p,j) == 114 then -- 'r'
        
          -- is the repetitive operator
          if r == 0 then
            r = j
          else
            j = r - 1 -- take into consideration final increment
            r = 0
          end
        else
        
          -- is not the repetitive operator
          -- does the argument type at a match the pattern at j
          -- debug print(string.char(string.byte(typlk['_'..type(argz[a])]))..' '
          -- debug ..string.char(string.byte(pattern[i].p,j)))
          -- debug pause()
          if     string.byte(pattern[i].p,j) ==
                 97                                     then -- 'a'
          
            -- match any
            if a > match then match, pmax = a, i end
            -- return on successful match of all arguments against pattern
            if a == cnt then return {_status=OK, _pat=i, _cnt=cnt, _argz=argz} end
            a = a + 1
          elseif string.byte(ttyplk['_'..type(argz[a])]) ==
                 string.byte(pattern[i].p,j) then -- 'n' 'b' 's' 'f' 't'
            
            -- match specific
            
            -- if value(s) specified for p[j], check arg[a] against it(them)
            local good = false
            if type(argz[a]) == 'string' then
            
              --string
              if pattern[i][j] ~= NULL and #pattern[i][j] > 0 then              
                for k,v in pairs(pattern[i][j]) do
                  if argz[a] == v then good = true break end
                end
                if good == false then
                  -- populate possible values
                  posvals = 'Possible values: ('
                  for k,v in pairs(pattern[i][j]) do
                    posvals = posvals..v..'|'
                  end
                  encval  = argz[a]
                  if #encval > 80 then encval = string.sub(encval,1,77)..'...' end
                  encval = encval..'\013\010'
                  posvals = string.sub(posvals,0, #posvals - 1)..')\013\010'
                end
              else
                good = true
              end
              
              -- value not matched, break out of while
              if good == false then break end
              
              --dbprint('good')
              
              if a > match then match, pmax = a, i end
              -- return on successful match of all arguments against pattern
              if a == cnt then return {_status=OK, _pat=i, _cnt=cnt, _argz=argz} end
              a = a + 1
            else
            
              -- not string
              if a > match then match, pmax = a, i end
              -- return on successful match of all arguments against pattern
              if a == cnt then return{_status=OK, _pat=i, _cnt=cnt, _argz=argz} end
              a = a + 1           
            end         -- end if type is string
          else 
          
            -- type doesn't match!
            -- break out of while to increment pattern
            
            break
          end           -- end if 'a' ... elseif specific ...
        
        end             -- end if 'r' ... else ...
        j = j + 1
      end               -- end while
    else
    
      -- wrong number of parameters
      -- specified for pattern to match
      
    end                 -- end if cnt >=...
  end                   -- end for  
  
  -- no patterns matched, report
  local p = self.iface.probe()
  local fn = pattern.name
  local ln = p[p._maxlvl].currentline

  local s = ' '..cnt..' argument' 
  if cnt ~= 1 then s = s..'s' end
  s = s..' supplied to method '..fn..'()\013\010at line '
      ..ln..' do'
  if cnt == 1 then s = s..'es' end
  s = s..' not appear to match any known calling patterns.\013\010'
  s = s..'Encountered call: '..pattern.name..'('
  for m = 1,cnt do
    s = s..type(argz[m])
    if m < cnt then s = s..', ' end
  end
  s = s..')\013\010'
  s = s.. self.iface.closestmatch(pattern, pmax, match)
  if posvals ~= '' then
    s = s..'Encountered value: '..tostring(encval)
    s = s..posvals
  end
  local e = __mkex('SL usage error: ',
                     s,
                     p)
  local eref = self.iface.reporterr(e)
  return {_status=ERR, _eref=eref}
end

-- set verbosity arg pattern --------------------------------------------------
local _verbositypattern =
  { name ='verbosity',
    num  = 1,
    req  = 0,
    [1]  = {lo=1, hi=1, rep = false, p='s', [1]={'off','lo','med','hi'}}
  } 
  
-- set verbosity function -----------------------------------------------------
local _verbosity  = function(...)
  local a = self.iface.argval(_verbositypattern,...)
  if a._status == ERR then
    -- continue without side effects
    return self.verbosity  
  end
  
  local oldval = self.verbosity
  if #a._argz > 0 then
    self.verbosity = a._argz[1]
  end
  return oldval
end


-------------------------------------------------------------------------------
--MAIN LIBRARY - CLOSURE GENERATORS -------------------------------------------
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- bmp ------------------------------------------------------------------------

-- bitmap manipulation functions

-- todo


-------------------------------------------------------------------------------
-- case -----------------------------------------------------------------------

-- case arg patterns ----------------------------------------------------------
local _casepattern =
  { name = 'case',
    num = 3,
    req = 1,
    [1] = {lo=1, hi=1, rep = false, p='t',     [1]={}},  
    [2] = {lo=1, hi=3, rep = true,  p='rtr',   [1]={}, [2]={}, [3]={}},
    [3] = {lo=1, hi=3, rep = false, p='rfr',   [1]={}, [2]={}, [3]={}},    
  }
  
local _onpattern =
  { name = 'case.on',
    num = 2,
    req = 1,
    [1] = {lo=1, hi=1, rep = true, p='a',      [1]={}},
    [2] = {lo=1, hi=4, rep = true, p='arar',   [1]={}, [2]={}, [3]={}, [4]={}},
  }
  
-- case object ----------------------------------------------------------------
local _case    = function(...)
  local a = self.iface.argval(_casepattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end

  -- build state info --------------------------------------------------------- 
  local cases = {}
  if     a._pat == 1 then
    cases = a._argz[1]
  elseif a._pat == 2 then
    for k,v in pairs(a._argz) do
      for l,w in pairs(v) do
        local ll = l
        if type(ll) ~= 'number' and type(ll) ~= 'string' then ll = tostring(ll) end
        cases[ll] = w
      end
    end
  elseif a._pat == 3 then
    for i = 1,a._cnt do
      cases[i] = a._argz[i]
    end
    cases['default'] = cases[a._cnt]
  else
    local e = __mkex('SL logic error: ',
                   'unexpected argument pattern encountered in case()',
                   self.iface.probe())
    if e._probe._caller >= 0 then 
      e._errmsg = e._errmsg .. ' at line ' ..
      tostring(e._probe[e._probe._caller+2].currentline) ..
      ' in ' .. self.name
    else
      e._errmsg = e._errmsg .. ' in ' .. self.name 
    end
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref) 
  end  

  -- on method ----------------------------------------------------------------
  local _on = function(...)
    local a = self.iface.argval(_onpattern,...)
    if a._status == ERR then
      return __redir(a._eref)
    end
    
    local largz   = {}
    local retval  = {}
    local current = nil
    
    local sel = a._argz[1]
    if type(sel) ~= 'number' and type(sel) ~= 'string' then sel = tostring(sel) end
      local f = nil
    if cases[sel] ~= nil then
      f = cases[sel]
    elseif cases.default ~= nil then
      f = cases.default
    else
      -- report exception
      local e = __mkex('SL usage error: ',
                     'no default case found for on() method',
                     self.iface.probe())
      if e._probe._caller >= 0 then 
        e._errmsg = e._errmsg .. ' at line ' ..
          tostring(e._probe[e._probe._maxlvl].currentline) ..
          ' in \013\010' .. e._probe[e._probe._maxlvl].short_src..'.\013\010'..
          'Passed selector value was "'..tostring(sel)..'".\013\010'
      else
        e._errmsg = e._errmsg .. ' in ' .. self.name..'.\013\010'..
          'Passed selector value was "'..tostring(sel)..'".\013\010'        
      end
  
      local eref = self.iface.reporterr(e)
      -- inline, callback, or reraise according to redirection flags
      return __redir(eref) --]] 
    end

    if type(f) ~= 'function' then
      return f
    end
    
    --retval = { f(unpack(a._argz,2)) }
    --if select('#',unpack(retval)) == 1 then retval = retval[1] end
    --return retval
    return f(unpack(a._argz,2))
  end
  
  -- case closure -------------------------------------------------------------
  return setmetatable({
    _type = 'interface:case',
    on = function(...) return self.iface.itry( _on, 'on', ...) end,
    },_facemt)
end


-------------------------------------------------------------------------------
-- chain ----------------------------------------------------------------------

-- a chain of functions, ( or chains, or machines, in 0.07+)
-- with monitor function

-- other executable graphs handled by machine closure

-- chain arg patterns ---------------------------------------------------------
local _chainpattern = 
  { name = 'chain',
    num = 3,
    req = 2,
    [1] = {lo=2, hi=2, rep = false, p='ff',    [1]={}, [2]={}},  
    [2] = {lo=2, hi=2, rep = false, p='ft',    [1]={}, [2]={}},
    [3] = {lo=2, hi=5, rep = true,  p='ffrfr', [1]={}, [2]={}, [3]={}, [4]={}, [5]={}},
  }
  
-- chain object ---------------------------------------------------------------
local _chain = function(...)
  local a = self.iface.argval(_chainpattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end 

  local mon   = nil
  local chain = {}
  local cnt   = 0
  local at    = 0
  
  if     a._pat == 1 then
    mon = a._argz[1]
    chain[1] = a._argz[2]
    cnt = 1
  elseif a._pat == 2 then
    mon = a._argz[1]
    chain = a._argz[2]
    cnt = table.maxn(chain)
  elseif a._pat == 3 then
    mon = a._argz[1]
    cnt = a._cnt - 1
    for i = 2, a._cnt do
      table.insert(chain, a._argz[i])
    end
  end
  
  -- dispose method -----------------------------------------------------------
  local _dispose = function()
    a = nil
    mon = nil
    chain = {}
    cnt = 0
    at  = 0
    collectgarbage('collect')
  end
  
  -- init method --------------------------------------------------------------
  local _init = function(...)
    local g = {...}
    local b = true
    at = 0
    while at < cnt do
      at = at + 1
      g = {chain[at](unpack(g))}
      if at < cnt then 
        b = mon(at, unpack(g))
        if b == false then break end 
      end      
    end
  
    return at, cnt
  end

  -- chain closure ------------------------------------------------------------
  return setmetatable({
    _type = 'interface:chain',

    dispose  = function(...) return self.iface.itry( _dispose, 'dispose',       ...) end,
    initiate = function(...) return self.iface.itry( _init,    'initiate',      ...) end,

    },_facemt)

end


-------------------------------------------------------------------------------
-- deque ----------------------------------------------------------------------

-- double ended queue, configurable as FIFO,LIFO, or double ended
-- unlimited or fixed size (circular queue)

-- file arg patterns ----------------------------------------------------------
local _dequepattern =
  { name = 'deque',
    num = 2,
    req = 0,
    [1] = {lo=1, hi=1, rep = false, p='s',     [1]={'deque','fifo','lifo'}},  
    [2] = {lo=2, hi=2, rep = false, p='sn',    [1]={'deque','fifo','lifo','circular'}},  
  }

 -- deque object --------------------------------------------------------------
local _deque = function(...)
  local a = self.iface.argval(_dequepattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end 
  
  local typ     = 'deque'
  local cap     = -1
  if a._cnt > 0  then typ     = a._argz[1] end
  if a._cnt == 2 then cap     = a._argz[2] end
  
  -- todo implement alternative closures for deque, fifo, lifo, circular
  
  -- todo implement capacity limits
  
  -- todo reindex when tail becomes too small or head too large
  
  local siz = 0
  local head = nil
  local tail = nil
  local q    = {}
  
  -- clone method -------------------------------------------------------------
  local _clone = function()
    local ret = nil
    if cap > 0 then
      ret = self.iface.deque(typ,cap)
    else
      ret = self.iface.deque(typ)
    end
    if siz > 0  then
      for i = 0, siz - 1 do
        ret.push(q[tail+i])
      end
    end
    return ret  
  end
  
  -- popback method -----------------------------------------------------------
  local _popback = function()
    if siz == 0 then return nil end
    local ret = q[tail]
    q[tail] = nil
    tail = tail + 1
    siz  = siz  - 1
    return ret
  end
  
  -- popfront method ----------------------------------------------------------
  local _popfront = function()
    if siz == 0 then return nil end
    local ret = q[head]
    q[head] = nil
    head = head - 1
    siz  = siz  - 1
    return ret
  end
  
  -- pushback method ----------------------------------------------------------
  local _pushback = function(...)
    local a = {...}
    local c = select('#',...)
    if c > 0 then
      if siz == 0 then head = 1 tail = 2 end
      for i = 1,c do
        tail    = tail - 1
        siz     = siz  + 1
        q[tail] = a[i]
      end
    end
    return true
  end
  
  -- pushfront method ---------------------------------------------------------
  local _pushfront = function(...)
    local a = {...}
    local c = select('#',...)
    if c > 0 then
      if siz == 0 then head = 0 tail = 1 end
      for i = 1,c do
        head    = head + 1
        siz     = siz  + 1
        q[head] = a[i]
      end
    end
    return true
  end
  
  -- peekat method ------------------------------------------------------------
  local _peekat = function(n)
    if siz == 0 then return nil end
    if n == nil or type(n) ~= 'number' then n = 0 end
    if n >= siz then return nil end
    return q[head-n]
  end
  
  -- peekback method ----------------------------------------------------------
  local _peekback = function()
    if siz == 0 then return nil end
    return q[tail]
  end
  
  -- peekfront method ---------------------------------------------------------
  local _peekfront = function()
    if siz == 0 then return nil end
    return q[head]
  end
  
  -- size method --------------------------------------------------------------
  local _size = function()
    return siz
  end
  
  -- capacity method ----------------------------------------------------------
  local _capacity = function()
    return cap
  end
  
  -- deque closure ------------------------------------------------------------
  return setmetatable({
    _type = 'interface:deque',

    back      = function(...) return self.iface.itry( _peekback,  'back',      ...) end,
    capacity  = function(...) return self.iface.itry( _capacity,  'capacity',  ...) end,    
    clone     = function(...) return self.iface.itry( _clone,     'clone',     ...) end,
    front     = function(...) return self.iface.itry( _peekfront, 'front',     ...) end,
    peek      = function(...) return self.iface.itry( _peekfront, 'peek',      ...) end,
    peekat    = function(...) return self.iface.itry( _peekat,    'peekat',    ...) end,
    peekback  = function(...) return self.iface.itry( _peekback,  'peekback',  ...) end,
    peekfront = function(...) return self.iface.itry( _peekfront, 'peekfront', ...) end,
    pop       = function(...) return self.iface.itry( _popfront,  'pop',       ...) end,
    popback   = function(...) return self.iface.itry( _popback,   'popback',   ...) end,
    popfront  = function(...) return self.iface.itry( _popfront,  'popfront',  ...) end,
    push      = function(...) return self.iface.itry( _pushfront, 'push',      ...) end,
    pushback  = function(...) return self.iface.itry( _pushback,  'pushback',  ...) end,
    pushfront = function(...) return self.iface.itry( _pushfront, 'pushfront', ...) end,
    size      = function(...) return self.iface.itry( _size,      'size',      ...) end,
    },_facemt)
end

-------------------------------------------------------------------------------
-- file -----------------------------------------------------------------------

-- file arg patterns ----------------------------------------------------------
local _filepattern =
  { name = 'file',
    num = 1,
    req = 2,
    [1] = {lo=2, hi=2, rep = false, p='ss',    [1]={}, [2]={'read','write'}},  
  }

-- file object ----------------------------------------------------------------
local _file    = function(...)
  local a = self.iface.argval(_filepattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end 

  local filen    = a._argz[1]
  local typ      = a._argz[2] 
  local isopen   = false
  local isstruct = false
  local flags    = 'rb'
  if typ == 'write' then flags = 'wb' end
  
  local err, f, msg
  
  err, f , msg = pcall(openfile,filen,flags)
  if err == true and f ~= nil then isopen = true else
    local e = __mkex('SL usage error: ',
                   'unable to open file named '..filen..' in file()',
                   self.iface.probe())
    if e._probe._caller >= 0 then 
      e._errmsg = e._errmsg .. '\013\010at line ' ..
      tostring(e._probe[e._probe._maxlvl].currentline) ..
      ' in ' .. e._probe[e._probe._maxlvl].short_src
    else
      e._errmsg = e._errmsg .. ' in ' .. self.name 
    end
    if msg ~= nil then e._errmsg = e._errmsg .. '. Reported error: '..tostring(msg) end
    e._errmsg = e._errmsg..'\013\010'
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref)
  end
 
  --dbprint(tostring(filen))
  --dbprint(tostring(flags))  
  --dbprint(tostring(f))
  local cursor = 0
  local size   = 0
  if typ == 'write' then
    f:setvbuf('full')
  else
    size = f:seek('end')
    f:seek('set')
  end
  
  -- writenil -----------------------------------------------------------------
  local __writenil = function()
    local out = '^n   ~\013\010'
    return out
  end  
  
  -- writebool ----------------------------------------------------------------
  local __writebool = function(b)
    local out = '^b'..string.sub(tostring(b),1,1)..'  ~\013\010'
    return out
  end
 
  -- writenum -----------------------------------------------------------------
  local __writenum = function(n)
    local out = '^i'..tostring(n)
    dbprint(tostring(n))
    local n = (#out + 3) % 8
    if n ~= 0 then out = out .. string.rep(' ', 8 - n) end
    out = out ..'~\013\010'
    return out
  end
  
  -- writestr -----------------------------------------------------------------  
  local __writestr = function(s)
    local out = '^s'
    s = self.iface.str.tohex(s)
    out = out .. s 
    local n =(#out + 3) % 8
    if n ~= 0 then out = out .. string.rep(' ', 8 - n) end
    out = out .. '~\013\010'
    return out
  end
  
  -- writetable ---------------------------------------------------------------
  local __writetable = function(t)
    local out = '^t'
    local s = self.iface.str.tohex(self.iface.tabletolua(t))
    out = out .. s
    local n = (#out + 3) % 8
    if n ~= 0 then out = out .. string.rep(' ', 8 - n) end
    out = out .. '~\013\010'
    return out
  end
  
  -- write method -------------------------------------------------------------
  local _write = function(...)
    local a = {...}
    local c = select('#',...)
    if f == nil or isopen == false or typ == 'read' then return false end
    if c == 0 then return true end
    if size > 0 and isstruct == false then
      print('error attempting to write structured data to a raw file.')
      return false
    end
    isstruct = true
    for i = 1,c do
      local  t = type(a[i])
      if     t == 'nil' or a[i] == null then f:write(__writenil())
      elseif t == 'boolean'             then f:write(__writebool(a[i]))
      elseif t == 'number'              then f:write(__writenum(a[i]))
      elseif t == 'string'              then f:write(__writestr(a[i]))
      elseif t == 'table'               then f:write(__writetable(a[i]))
      else
        --ignore functions, userdata, threads
      end
    end 
    f:flush()
    cursor = f:seek()
    size = cursor    
    return true    
  end
  
  -- writeraw method ----------------------------------------------------------
  local _writeraw = function(...)
    local a = {...}
    local c = select('#',...)
    if f == nil or isopen == false or typ == 'read' then return false end
    if size > 0 and isstruct == true then return false end
    isstruct = false
    for i = 1,c do
      local t = type(a[i])
      if t == 'string' then f:write(a[i]) end
      -- ignore all other types      
    end
    f:flush()
    cursor = f:seek()
    size = cursor
    return true  
  end
  
  -- finalize method ----------------------------------------------------------
  local _finalize = function(...)
    if isopen == true and f ~= nil then
      if typ == 'write' then
        if isstruct == true then f:write('^*   ~\013\010') end
        f:flush() 
      end
      f:close()
      f        = nil
      isopen   = false
      isstruct = false
      cursor   = 0
    end
  end
  
  -- readnum method -----------------------------------------------------------
  local __readnum = function()
    local out = nil
    local buff = f:read(6)
    if buff == nil then return nil end
    --dbprint(buff)
    local a = string.sub(buff,4,6)
    if a ~= '~\013\010' then
      buff = buff .. f:read(8)
      a = string.sub(buff,12,14)
      --dbprint(buff)
      if a ~= '~\013\010' then
        buff = buff .. f:read(8)
        a = string.sub(buff,20,22)
        --dbprint(buff)
        if a ~= '~\013\010' then return nil end
      end
    end

    buff = string.sub(buff,1,string.find(buff,' ',1,true) - 1)
    dbprint(buff)
    out = tonumber(buff)
    cursor = f:seek()
    return out
  end
  
  -- readstr method -----------------------------------------------------------
  local __readstr = function()
    local out = nil
    local buff = f:read(6)
    local cont = true
    local at = 4
    local a = string.sub(buff,at,at+2)
    local b = ''
    if a == '~\013\010' then cont = false end
    while cont == true do
      b = f:read(8)
      if b == nil then break end
      buff = buff..b
      at = at + 8
      a = string.sub(buff,at,at+2)
      if a == '~\013\010' then cont = false end
    end
    out = self.iface.str.fromhex(buff)
    cursor = f:seek()
    return out
  end
  
  -- readtable method ---------------------------------------------------------
  local __readtable = function()
    local out = {}
    local buff = __readstr()
    if buff == nil then return nil end
    out = dostring('return '..buff)
    return out
  end
  
  -- read (next) method -------------------------------------------------------
  local _read = function(...)
    if f == nil or isopen == false or typ == 'write' then return nil end
    local buff 
    -- is there anything else left to read?
    cursor = f:seek()
    if size - cursor < 7 then return nil end
    buff = f:read(2)
    if buff == nil then return nil end
    local a,b = string.sub(buff,1,1), string.sub(buff,2,2)
    dbprint(a,b)
    if a ~= '^' then dbprint('alignment error'..a..b) return nil end
    if     b == 'n' then f:seek('cur',6) return null
    elseif b == 'b' then local c = f:read(1) f:seek('cur',5) if c == 't' then return true else return false end
    elseif b == 'i' then return __readnum()
    elseif b == 's' then return __readstr()
    elseif b == 't' then return __readtable()
    elseif b == '*' then return EOF
    else
      return nil
    end
  end
  
  -- readall method -----------------------------------------------------------
  local _readall = function(...)
    if f == nil or isopen == false or typ == 'write' then return nil end
    local out = {}
    local b = true
    while b ~= nil and b ~= EOF do
      b = _read()
      if b == EOF then return out end
      if b ~= nil then table.insert(out, b) else table.insert(out,'ERROR') end
    end
    return out
  end
  
  -- reopen method ------------------------------------------------------------
  local _reopen = function()
    _finalize()
    err, f , msg = pcall(openfile,filen,flags)
    if err == true and f ~= nil then isopen = true else
      local e = __mkex('SL usage error: ',
                     'unable to open file named '..filen..' in file()',
                     self.iface.probe())
      if e._probe._caller >= 0 then 
        e._errmsg = e._errmsg .. '\013\010at line ' ..
        tostring(e._probe[e._probe._maxlvl].currentline) ..
        ' in ' .. e._probe[e._probe._maxlvl].short_src
      else
        e._errmsg = e._errmsg .. ' in ' .. self.name 
      end
      if msg ~= nil then e._errmsg = e._errmsg .. '. Reported error: '..tostring(msg) end
      e._errmsg = e._errmsg..'\013\010'
      local eref = self.iface.reporterr(e)
      -- inline, callback, or reraise according to redirection flags
      return __redir(eref)
    end
    if typ == 'write' then
      f:setvbuf('full')
    else
      size = f:seek('end')
      f:seek('set')
    end
    return true
  end
  
  -- skip (structured seek) method --------------------------------------------
  local _skip = function(n)
    if f == nil or isopen == false or typ == 'write' or type(n) ~= 'number' then return nil end
    if n == 0 then return true end
    local buff 
    local z, dir = 0, n/math.abs(n)
    
    -- is there anything else left to read?
    cursor = f:seek()
    if dir > 0 and size - cursor < 7 then return EOF end
    if dir < 0 and cursor < 8 then return EOF end

    buff = f:read(2)
    if buff == nil then return nil end
    local a,b = string.sub(buff,1,1), string.sub(buff,2,2)
    cursor = f:seek()
    dbprint(a,b)
    if a ~= '^' then dbprint('alignment error'..a..b) return nil end
    if b == '*' and dir > 0 then f:seek('cur', -2) return EOF end
    
    a = ''
    while a ~= '^' and cursor > 0 and cursor < size and z ~=n do
      if dir < 0 then f:seek('cur',-10) else f:seek('cur',6) end
      buff = f:read(2)
      a = string.sub(buff,1,1)
      cursor = f:seek()
      if buff == nil then return nil end
      if a == '^' then
        a = ''
        z = z + dir
        if z == n then
          if dir > 0 and size - cursor < 7 then f:seek('cur',-2) return EOF end
          if dir < 0 and cursor < 8        then f:seek('cur',-2) return EOF end
        end
      end
    end
    
    f:seek('cur',-2)    
    return n
  end
  
  -- copy method --------------------------------------------------------------
  local _copy = function(filename)
    if f == nil then dbprint('file handle to be copied is nil') return false end
    if filename == nil or type(filename) ~= 'string' or filename == '' then return false end
    
    local isgopen = false
    local err, g, msg = pcall(openfile,filename,'wb')
    if err == true and g ~= nil then isgopen = true else
      local e = __mkex('SL usage error: ',
                   'unable to open file named '..filename..' in copy() method',
                   self.iface.probe())
      if e._probe._caller >= 0 then 
        e._errmsg = e._errmsg .. '\013\010at line ' ..
        tostring(e._probe[e._probe._maxlvl].currentline) ..
        ' in ' .. e._probe[e._probe._maxlvl].short_src
      else
        e._errmsg = e._errmsg .. ' in ' .. self.name 
      end
      if msg ~= nil then e._errmsg = e._errmsg .. '. Reported error: '..tostring(msg) end
      e._errmsg = e._errmsg..'\013\010'
      local eref = self.iface.reporterr(e)
      -- inline, callback, or reraise according to redirection flags
      return __redir(eref)
    end
    
    if isgopen == false then return false end
    
    local cur = f:seek()
    f:seek('set')
    local xfer = f:read('*a')
    g:write(xfer)
    xfer = nil
    g:flush()
    g:close()
    collectgarbage('collect')
    f:seek('set',cur)
    cursor = cur
    return true
  end
  
  -- stream method ------------------------------------------------------------
  local _stream = function(...)
    local out = nil
    if f == nil then dbprint('file handle is nil') return nil end
    local cur = f:seek()
    out = f:read('*a')
    f:seek('set', cur)
    cursor = cur
    return out    
  end
 
  -- write closure ------------------------------------------------------------
  if typ == 'write' then
    return setmetatable({
      _type = 'interface:filewriter',
      
      finalize  = function(...) return self.iface.itry( _finalize,  'finalize',  ...) end,
      reopen    = function(...) return self.iface.itry( _reopen,    'reopen',    ...) end,
      tofile    = function(...) return self.iface.itry( _write,     'tofile',    ...) end,
      streamout = function(...) return self.iface.itry( _writeraw,  'streamout', ...) end,
      },_facemt)
  end 
  
  -- read closure -------------------------------------------------------------
  return setmetatable({
    _type = 'interface:filereader',
    
    copy     = function(...) return self.iface.itry( _copy,    'copy',      ...) end,
    finalize = function(...) return self.iface.itry( _finalize, 'finalize', ...) end,
    readnext = function(...) return self.iface.itry( _read,    'readnext',  ...) end,
    readall  = function(...) return self.iface.itry( _readall, 'readall',   ...) end,
    reopen   = function(...) return self.iface.itry( _reopen,   'reopen',   ...) end,
    skip     = function(...) return self.iface.itry( _skip,    'skip',      ...) end,
    stream   = function(...) return self.iface.itry( _stream,  'stream',    ...) end,
    },_facemt)
end


-------------------------------------------------------------------------------
-- iterator -------------------------------------------------------------------

-- iterator arg patterns ------------------------------------------------------
local _iteratorpattern =
  { name = 'iterator',
    num = 4,
    req = 2,
    [1] = {lo=2, hi=2, rep = false, p='tf',    [1]={}, [2]={}},  
    [2] = {lo=2, hi=5, rep = true,  p='tfrar', [1]={}, [2]={}, [3]={}, [4]={}, [5]={}},
    [3] = {lo=2, hi=2, rep = false, p='tt',    [1]={}, [2]={}},    
    [4] = {lo=2, hi=5, rep = true,  p='ttrar', [1]={}, [2]={}, [3]={}, [4]={}, [5]={}},
  }
  
local _runpattern =
  { name = 'iterator.run',
    num = 1,
    req = 0,
    [1] = {lo=1, hi=3, rep = true, p='rar',   [1]={}, [2]={}, [3]={}}
  }
  
-- iterator object ------------------------------------------------------------
local _iterator   = function(...)
  local a = self.iface.argval(_iteratorpattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end
  
  -- state info ---------------------------------------------------------------
  local _table = a._argz[1]
  local _function = a._argz[2]
  local _initargs = {unpack(a._argz,3,a._cnt)}
  
  -- if primary table is indexed numerically
  -- and w/o gaps, if so will iterate in order
  local _tnumeric = true
  local _tmin, _tmax = 0,0
  local _tordered = false
  if type(_table) == 'table' then
    local hi,lo, cnt = -1,2,0
    for k,v in pairs(_table) do
      if type(k) ~= 'number' then _tnumeric = false break end
      if k > hi then hi = k end
      if k < lo then lo = k end
      cnt = cnt + 1
    end
    if _tnumeric == true and (hi - lo + 1) == cnt then
      dbprint('Ordered Table')
      _tordered = true
      _tmin     = lo
      _tmax     = hi
    end
  end
  
  -- if a table of functions is passed, see if indexed numerically
  -- and w/o gaps, if so will iterate in order
  local _fnumeric = true
  local _fmin, _fmax = 0,0
  local _fordered = false
  if type(_function) == 'table' then
    local hi,lo, cnt = -1,2,0
    for k,v in pairs(_function) do
      if type(k) ~= 'number' then _fnumeric = false break end
      if k > hi then hi = k end
      if k < lo then lo = k end
      cnt = cnt + 1
    end
    if _fnumeric == true and (hi - lo + 1) == cnt then
      dbprint('Ordered Table of Functions')
      _fordered = true
      _fmin     = lo
      _fmax     = hi
    end
  end

  
  -- run method ---------------------------------------------------------------
  local _run = function(...)
    local a = self.iface.argval(_runpattern,...)
    if a._status == ERR then
      return __redir(a._eref)
    end
    local largz = {}
    if #_initargs > 0 then
      for l = 1,#_initargs do
        table.insert(largz, _initargs[l])
      end
    end
    if a._cnt > 0 then
      for l = 1, a._cnt do
        table.insert(largz, a._argz[l])
      end
    end

    local retval = {}
    local current = nil
    
    if type(_function) == 'function' then
      if _tordered then
        for i = _tmin,_tmax do
          current = _function(i,_table[i],unpack(largz))
          if current == null then return retval end
          table.insert(retval, current)
        end
        return retval
      else
        for k,v in pairs(_table) do
          current = _function(k,v,unpack(largz))
          -- if function returns magic value (null) then break iteration
          if current == null then return retval end
          table.insert(retval, current)
        end
        return retval
      end
    elseif type(_function) == 'table' then
      if _tordered ~= true and _fordered ~= true then
      
        for k,v in pairs(_table) do
          for l,w in pairs(_function) do
            if type(w) == 'function' then
              current = w(k, v, unpack(largz))
              -- if function returns magic value (null) then break iteration
              if current == null then return retval end
              table.insert(retval, current)
            else
              local e = __mkex('SL logic error: ',
                       'non-function encountered in internal table of iterator:run',
                       self.iface.probe())
              if e._probe._caller >= 0 then 
                e._errmsg = e._errmsg .. ' at line ' ..
                tostring(e._probe[e._probe._caller+2].currentline) ..
                ' in ' .. self.name
              else
                e._errmsg = e._errmsg .. ' in ' .. self.name 
              end
  
              local eref = self.iface.reporterr(e)
              -- inline, callback, or reraise according to redirection flags
              return __redir(eref)
            end
          end
        end
        return retval
      
      elseif _tordered == true and _fordered == true then
      
        for i = _tmin, _tmax do
          for j = _fmin, _fmax do
            if type(_function[j]) == 'function' then
              current = _function[j](i, _table[i], unpack(largz))
              -- if function returns magic value (null) then break iteration
              if current == null then return retval end
              table.insert(retval, current)
            else
              local e = __mkex('SL logic error: ',
                       'non-function encountered in internal table of iterator:run',
                       self.iface.probe())
              if e._probe._caller >= 0 then 
                e._errmsg = e._errmsg .. ' at line ' ..
                tostring(e._probe[e._probe._caller+2].currentline) ..
                ' in ' .. self.name
              else
                e._errmsg = e._errmsg .. ' in ' .. self.name 
              end
  
              local eref = self.iface.reporterr(e)
              -- inline, callback, or reraise according to redirection flags
              return __redir(eref)
            end
          end
        end
        return retval
      
      elseif _tordered ~= true and _fordered == true then
      
        for k,v in pairs(_table) do
          for j = _fmin,_fmax do
            if type(_function[j]) == 'function' then
              current = _function[j](k, v, unpack(largz))
              -- if function returns magic value (null) then break iteration
              if current == null then return retval end
              table.insert(retval, current)
            else
              local e = __mkex('SL logic error: ',
                       'non-function encountered in internal table of iterator:run',
                       self.iface.probe())
              if e._probe._caller >= 0 then 
                e._errmsg = e._errmsg .. ' at line ' ..
                tostring(e._probe[e._probe._caller+2].currentline) ..
                ' in ' .. self.name
              else
                e._errmsg = e._errmsg .. ' in ' .. self.name 
              end
  
              local eref = self.iface.reporterr(e)
              -- inline, callback, or reraise according to redirection flags
              return __redir(eref)
            end
          end
        end
        return retval
      
      elseif _tordered == true and _fordered ~= true then
      
        for i = _tmin,_tmax do
          for l,w in pairs(_function) do
            if type(w) == 'function' then
              current = w(i, _table[i], unpack(largz))
              -- if function returns magic value (null) then break iteration
              if current == null then return retval end
              table.insert(retval, current)
            else
              local e = __mkex('SL logic error: ',
                       'non-function encountered in internal table of iterator:run',
                       self.iface.probe())
              if e._probe._caller >= 0 then 
                e._errmsg = e._errmsg .. ' at line ' ..
                tostring(e._probe[e._probe._caller+2].currentline) ..
                ' in ' .. self.name
              else
                e._errmsg = e._errmsg .. ' in ' .. self.name 
              end
  
              local eref = self.iface.reporterr(e)
              -- inline, callback, or reraise according to redirection flags
              return __redir(eref)
            end
          end
        end
        return retval
        
      end -- all the ordered cases
      
    else
      -- report exception
      local e = __mkex('SL logic error: ',
                     'unexpected type encountered in iterator:run',
                     self.iface.probe())
      if e._probe._caller >= 0 then 
        e._errmsg = e._errmsg .. ' at line ' ..
        tostring(e._probe[e._probe._caller+2].currentline) ..
        ' in ' .. self.name
      else
        e._errmsg = e._errmsg .. ' in ' .. self.name 
      end
  
      local eref = self.iface.reporterr(e)
      -- inline, callback, or reraise according to redirection flags
      return __redir(eref) 
    end
  end
  
  -- iterator closure ---------------------------------------------------------
  return setmetatable({
  _type = 'interface:iterator',
  
  run = function(...) return self.iface.itry(_run,    'run',     ...) end,
  },_facemt)
end


-------------------------------------------------------------------------------
-- journal --------------------------------------------------------------------

-- adapted from kal in ex's journal routines
-- http://www.easyuo.com/forum/viewtopic.php?t=43488&start=0

-- journal arg patterns -------------------------------------------------------

-- journal object -------------------------------------------------------------
local _journal = function()
  
  local lself = {}
  --[[ structure
  ref   - scanjournal reference
  lines - table of lines with {line,color} entries
  last  - last line returned by nextln
  count - highest line index of lines
  hndlr - table of handlers set by ontext  
  --]]
  
  -- local function clear -----------------------------------------------------
  local _clear = function()
    local i,j
    lself.ref,i = UO.ScanJournal(0)
    j = i
    lself.lines = {}
    lself.last  = 0
    lself.count = 0
    if i > 0 then
      --dbprint('ci '..i)
      while i > 0 do
        local line,color = UO.GetJournal(i-1)
        table.insert(lself.lines,{line,color})
        lself.count = lself.count + 1
        --dbprint('lself.count '..lself.count)
        i = i - 1
      end
    end
    return j, lself.count, lself.count - lself.last 
  end
  
  -- local function refresh ---------------------------------------------------
  local _refresh = function()
    local i, j
    lself.ref,i = UO.ScanJournal(lself.ref)
    j = i
    if i > 0 then
      --dbprint('ri '..i)
      while i > 0 do
        local line,color = UO.GetJournal(i-1)
        table.insert(lself.lines,{line,color})
        lself.count = lself.count + 1
        i = i - 1
      end
    end
    return j, lself.count, lself.count - lself.last 
  end
  
  -- local function count -----------------------------------------------------
  local _count = function()
    --_refresh()
    return lself.count, lself.count - lself.last
  end
  
  -- local function line ------------------------------------------------------
  local _line = function(npos,bsplit)
    --_refresh()
    if npos == nil or type(npos) ~= 'number' then
      return nil, 0, nil
    end
    
    local line = lself.lines[npos]
    if line == nil then return nil, 0, nil end  
    
    if bsplit == nil then bsplit = false end
    if bsplit == true then
      local n = string.find(line[1],': ',1,true)
      local name,msg = '',''
      if n ~= nil then
        name = string.sub(line[1],     1, n - 1)
        msg  = string.sub(line[1], n + 2,#line[1])
      else
        msg  = line[1]
      end
      return msg, line[2], name
    else
      return line[1], line[2]
    end
  end
  
  -- local function mark ------------------------------------------------------
  local _mark = function(at,bfromcurrent)
    if type(at) ~= 'number' then at = 0 end
    if bfromcurrent == nil then bfromcurrent = false end
    if bfromcurrent ~= false then at = at + lself.last end
    local skipped, remaining
    if at < 1 then at = 0 end
    if at > lself.count then at = lself.count end
    dbprint(at)
    remaining = lself.count - at
    skipped = at - lself.last  
    lself.last = at
    return skipped, remaining
  end
  
  -- local function nextln ----------------------------------------------------
  local _nextln = function(bsplit)
    _refresh()
    if lself.last >= lself.count then
      return nil, 0, nil
    end
    
    
    local line = lself.lines[lself.last + 1]
    if line == nil then return nil, 0, nil end
    lself.last = lself.last + 1
    
    if bsplit == nil then bsplit = false end
    if bsplit == true then
      local n = string.find(line[1],': ',1,true)
      local name,msg = '',''
      if n ~= nil then
        name = string.sub(line[1],1, n -1)
        msg  = string.sub(line[1],n+2,#line[1])
      else
        msg  = line[1]
      end
      return msg, line[2], name
    else
      return line[1], line[2]
    end
  end
  
  -- local function _find ------------------------------------------------------
  local _find = function(p, pattern, init, plain)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      local r = {string.find(lself.lines[u0][1],pattern,init or 1,plain)}
      if r ~= nil and next(r) ~= nil then
        cnt = cnt + 1
        table.insert(linenums,u0)
        table.insert(ret,r)
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _findcolor ------------------------------------------------------
  local _findcolor = function(p, color, pattern, init, plain)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local r = {string.find(lself.lines[u0][1],pattern,init or 1,plain)}
        if r ~= nil and next(r) ~= nil then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _gmatch ----------------------------------------------------
  local _gmatch = function(p, pattern)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    local caps = self.iface.str.cnt(pattern,'(')
    for u0 = p,lself.count do
      local r = {}
      if caps < 2 then
        for w in string.gmatch(lself.lines[u0][1],pattern) do
          table.insert(r,w)
        end
      elseif caps == 2 then
        for w,v in string.gmatch(lself.lines[u0][1],pattern) do
          table.insert(r,{w,v})
        end
      elseif caps == 3 then
        for w,v,x in string.gmatch(lself.lines[u0][1],pattern) do
          table.insert(r,{w,v,x})
        end
      elseif caps > 3 then
        for w,v,x,y,z in string.gmatch(lself.lines[u0][1],pattern) do
          table.insert(r,{w,v,x,y,z})
        end
      end
      if r ~= nil and next(r) ~= nil then
        cnt = cnt + 1
        table.insert(linenums,u0)
        table.insert(ret,r)
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _gmatchcolor -----------------------------------------------
  local _gmatchcolor = function(p, color, pattern)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    local caps = self.iface.str.cnt(pattern,'(')
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local r = {}
        if caps < 2 then
          for w in string.gmatch(lself.lines[u0][1],pattern) do
            table.insert(r,w)
          end
        elseif caps == 2 then
          for w,v in string.gmatch(lself.lines[u0][1],pattern) do
            table.insert(r,{w,v})
          end
        elseif caps == 3 then
          for w,v,x in string.gmatch(lself.lines[u0][1],pattern) do
            table.insert(r,{w,v,x})
          end
        elseif caps > 3 then
          for w,v,x,y,z in string.gmatch(lself.lines[u0][1],pattern) do
            table.insert(r,{w,v,x,y,z})
          end
        end
        if r ~= nil and next(r) ~= nil then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _gsub -----------------------------------------------------
  local _gsub = function(p, pattern, repl , n)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      local r = string.gsub(lself.lines[u0][1],pattern,repl,n)
      if r ~= nil and r ~= '' then
        cnt = cnt + 1
        table.insert(linenums,u0)
        table.insert(ret,r)
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _gsubcolor ------------------------------------------------
  local _gsubcolor = function(p, color, pattern, repl , n)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local r = string.gsub(lself.lines[u0][1],pattern,repl,n)
        if r ~= nil and r ~= '' then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _match ----------------------------------------------------
  local _match = function(p, pattern , init)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    local caps = self.iface.str.cnt(pattern,'(')
    for u0 = p,lself.count do
      --if lself.lines[u0][2] == color then
        local u,v,w,x,y,z = nil, nil, nil, nil, nil, nil
        local r = {}
        if caps < 2 then
            u = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u}
        elseif caps == 2 then
            u,v = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v}
        elseif caps == 3 then
            u,v,w = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v,w}
        elseif caps > 3 then
            u,v,w,x,y,z = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v,w,x,y,z}
        end
        if r ~= nil and r ~= '' then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      --end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _matchcolor -----------------------------------------------
  local _matchcolor = function(p, pattern , init)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    local caps = self.iface.str.cnt(pattern,'(')
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local u,v,w,x,y,z = nil, nil, nil, nil, nil, nil
        local r = {}
        if caps < 2 then
            u = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u}
        elseif caps == 2 then
            u,v = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v}
        elseif caps == 3 then
            u,v,w = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v,w}
        elseif caps > 3 then
            u,v,w,x,y,z = string.match(lself.lines[u0][1],pattern, init or 1)
            r = {u,v,w,x,y,z}
        end
        if r ~= nil and next(r) ~= nil then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _sub ------------------------------------------------------
  local _sub = function(p, i , j)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local r = string.sub(lself.lines[u0][1], i, j)
        if r ~= nil and r ~= '' then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end
  
  -- local function _subcolor--------------------------------------------------
  local _subcolor = function(p, i , j)
    if type(p) ~= 'number' or p > lself.count then p = lself.count end
    local ret = {}
    local cnt = 0
    local linenums = {}
    for u0 = p,lself.count do
      if lself.lines[u0][2] == color then
        local r = string.sub(lself.lines[u0][1], i, j)
        if r ~= nil and r ~= '' then
          cnt = cnt + 1
          table.insert(linenums,u0)
          table.insert(ret,r)
        end
      end
    end
    ret.count = cnt
    ret.linenums = linenums
    return ret
  end

  
  -- initialize ---------------------------------------------------------------
  _clear()
  
  -- journal closure ----------------------------------------------------------
  return setmetatable({
    _type = 'interface:journal',
    clear               = function(...) return _clear(...)         end,
    count               = function(...) return _count(...)         end,
    line                = function(...) return _line(...)          end,
    mark                = function(...) return _mark(...)          end,
    nextln              = function(...) return _nextln(...)        end,
    nextline            = function(...) return _nextln(...)        end,
    refresh             = function(...) return _refresh(...)       end,
    
    find                = function(...) return _find(...)          end,
    findcolor           = function(...) return _findcolor(...)     end,
    gmatch              = function(...) return _gmatch(...)        end,
    gmatchcolor         = function(...) return _gmatchcolor(...)   end,
    gsub                = function(...) return _gsub(...)          end,
    gsubcolor           = function(...) return _gsubcolor(...)     end,
    match               = function(...) return _match(...)         end,
    matchcolor          = function(...) return _matchcolor(...)    end,
    sub                 = function(...) return _sub(...)           end,
    subcolor            = function(...) return _subcolor(...)      end,

    },_facemt)
end

-- sLine,nCol   = GetJournal(nIndex)
-- nNewRef,nCnt = ScanJournal(nOldRef)


-------------------------------------------------------------------------------
-- keymon ---------------------------------------------------------------------

-- key combo monitor state machine

-- keymon arg patterns --------------------------------------------------------
local _keymonpattern =
  { name = 'keymon',
    num = 1,
    req = 1,
    [1] = {lo=1, hi=1, rep = false, p='t',    [1]={}},  
  }

-- keymon object --------------------------------------------------------------
local _keymon = function(...)
  local a = self.iface.argval(_keymonpattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end

  -- build state info --------------------------------------------------------- 
  local raw = a._argz[1]
  local mon = nil
  --if raw.monitor ~= nil then mon = raw.monitor raw.monitor = nil end
  
  local keys = {'ALT','SHIFT','CTRL'}
  local posi = {}
  local laststate = {}
  local getstate = {}
  local lasttime = getticks()
  
  local temp = {}
  
  -- build out keys table
  local n = 0
  for k,v in pairs(raw) do
    local s = self.iface.str.sep(' ',string.upper(k))
    local r = {}
    for t,u in pairs(s) do
      local a = nil
      for i = 1,#keys do
        if u == keys[i] then a = i break end
      end 
      if a == nil then
        table.insert(keys,u)
        a = #keys
      end
      table.insert(r,a)      
    end
    n = n + 1
    posi[n] = {n,k,r,v}
  end
  
  -- build getkeys clause
  local getkeys = 'local gk = {'
  for i = 1,#keys do
    getkeys = getkeys..'getkey("'..keys[i]..'"),'
  end
  getkeys = getkeys..'};\013\010'
  dbprint(getkeys)
    
  -- build elseif clause
  local clause = ''
  for i = 1,n do
    for k = 1,#keys do
      local kk = false
      for j = 1,#posi[i][3] do
        if posi[i][3][j] == k then kk = true break end
      end
      if k == 1 then clause = clause..'if ' end
      clause = clause..' gk['..tostring(k)..'] == '..tostring(kk)..' '
      if k < #keys then clause = clause..'and' end
      if k == #keys then clause = clause..'then return '..tostring(i)..' \013\010' end
    end
    if i < n then clause = clause..'else' end
    if i == n then clause = clause..'end;' end
  end
  dbprint(clause)
  
  local __usr_getkey = loadstring(getkeys..clause)

  -- refresh method -----------------------------------------------------------
  local _refresh = function()
  
    laststate = getstate
    getstate = __usr_getkey()
    --if mon ~= nil then getstate = mon(getstate) end
    
    if getstate ~= nil then
      if posi[getstate] ~= nil then
        if posi[getstate][4] ~= nil then
          posi[getstate][4]()
        end
      end
    end
  end
  
  -- keymon closure -----------------------------------------------------------
  return setmetatable({
    _type = 'interface:keymon',
    
    refresh               = function(...) return _refresh()         end,
    },_facemt)
end


-------------------------------------------------------------------------------
-- linklist -------------------------------------------------------------------

-- linklist arg patterns ------------------------------------------------------


-- linklist object ------------------------------------------------------------
local _linklist = function()

  -- state --------------------------------------------------------------------
  local h   = 0
  local t   = 0
  local c   = 0
  local l   = 0
  local maxe = 0
  local s = {}
  local e = {}
  
  -----------------------------------------------------------------------------
  local __clear = function(i)
    e[i]      = true
    s[i].val  = nil
    s[i].prev = 0
    s[i].next = 0
  end
  -----------------------------------------------------------------------------
  local __new = function(val)
  -- recycle or create new cell
    local j = 0
    for k,v in pairs(e) do
      if v == true then j = k break end
    end
    if j == 0 then
    -- make a new entry in s
      maxe = maxe + 1
      j = maxe
      s[j] = {prev = 0, nex=0}
    end
    s[j].val = val
    e[j] = nil
    return j
  end
  -----------------------------------------------------------------------------
  local _head  = function()
    if l == 0 then return 0 end
    return h
  end
  -----------------------------------------------------------------------------
  local _tail  = function()
    if l == 0 then return 0 end
    return t
  end
  -----------------------------------------------------------------------------
  local _prev  = function(i)
    if l == 0 then return 0 end
    if i > l or i < 1 then return 0 end
    if e[i] ~= nil then return 0 end
    return s[i].prev
  end
  -----------------------------------------------------------------------------
  local _nex   = function(i)
    if l == 0 then return 0 end
    if i > l or i < 1 then return 0 end
    if e[i] ~= nil then return 0 end
    return s[i].nex
  end
  -----------------------------------------------------------------------------
  local _val   = function(i)
    if l == 0 then return nil end
    if i > l or i < 1 then return nil end
    if e[i] ~= nil then return nil end 
    return s[i].val
  end
  -----------------------------------------------------------------------------
  local _len   = function()
    if l == 0 then return 0 end
    return l
  end
  -----------------------------------------------------------------------------
  local _nth   = function(i,b)
    if l == 0 then return 0 end
    if b == nil then b = true end
    if e[i] ~= nil then return 0 end
    
    if b == true then
      if i == h then return 1 end
      if i == t then return l end
    else
      if i == h then return l end
      if i == t then return 1 end
    end
    local cursor = h
    local at = 1
    if b == false then cursor = t end
    for temp = 1,l-1 do
      if cursor == i then break end
      if b == true then
        cursor = s[cursor].nex
      else
        cursor = s[cursor].prev
      end
      at = at + 1
      if cursor == 0 then break end  
    end
    return at
  end
  
  -----------------------------------------------------------------------------
  local __ins   = function(i,v,b)
    if b == nil then b = true end
    if l == 0 then
    -- initial cell
      i = __new(v)
      h = i
      t = i
      l = 1      
    else
    -- another cell
      if i > l or i < 1 then return 0 end 
      if e[i] ~= nil then return 0 end
      local prev, nex = s[i].prev, s[i].nex
      local j = __new(v)
      if b == true then
      -- insert before
        if prev == 0 then
        -- insert at head
          h         = j
          s[j].nex  = i
          s[i].prev = j  
        else
          s[prev].nex = j
          s[j].prev   = prev
          s[j].nex    = i
          s[i].prev   = j
        end
      else
      -- insert after
        if nex == 0 then
        -- insert at tail
          t         = j
          s[j].prev = i
          s[i].nex  = j           
        else
          s[nex].prev = j
          s[j].nex    = nex
          s[j].prev   = i
          s[i].nex    = j    
        end      
      end
      i = j
      l = l + 1
      e[i] = nil
    end
    return i
  end
  
  local _insb = function(i,v)
    return __ins(i,v,true)
  end
  
  local _insa = function(i,v)
    return __ins(i,v,false)
  end
  
  -----------------------------------------------------------------------------
  local _rem   = function(i)
    if l == 0 then return 0 end
    if i > l or i < 1 then return 0 end
    if e[i] ~= nil then return 0 end
    if l == 1 then
       h   = 0
       t   = 0
       l   = 0
       maxe = 0
       s   = {}
       e   = {}
       collectgarbage('collect')
    else
      if i == h then
        h                = s[i].nex
        s[s[i].nex].prev = 0  
      elseif i == t then
        t                = s[i].prev
        s[s[i].prev].nex = 0
      else
        s[s[i].nex].prev = s[i].prev
        s[s[i].prev].nex = s[i].nex
      end
      __clear(i)
      l = l - 1
    end
    return i
  end
  -----------------------------------------------------------------------------
  local _setv  = function(i,val)
    if l == 0 then return 0 end
    if i > l or i < 1 then return 0 end
    if e[i] ~= nil then return 0 end
    s[i].val = val
    return i
  end
  -----------------------------------------------------------------------------
  local _swap  = function(i,j)
    if l == 0 then return 0 end
    if i > l or i < 1 then return 0 end
    if j > l or j < 1 then return 0 end
    if e[i] ~= nil or e[j] ~= nil then return 0,0 end
    local temp = s[i].val
    s[i].val = s[j].val
    s[j].val = temp
    return j,i
  end
  -----------------------------------------------------------------------------  
  local _gettable = function(b)
    if l == 0 then return {} end
    if b == nil then b = true end
    local out = {}
    local cursor = t
    if b == true then cursor = h end
    for temp = 1,l do
      table.insert(out,s[cursor].val)
      if b == true then
        cursor = s[cursor].nex
      else
        cursor = s[cursor].prev
      end
      if cursor == 0 then break end  
    end
    return out
  end

  return setmetatable({
  
  _type = 'interface:linklist',
  
  head         = _head,
  tail         = _tail,
  prev         = _prev,
  prevlink     = _prev,
  nex          = _nex,
  nextlink     = _nex,
  val          = _val,
  value        = _val,
  len          = _len,
  length       = _len,
  nth          = _nth,
  getposition  = _nth,
  --ins        = _ins,
  insb         = _insb,
  insertbefore = _insb,
  insa         = _insa,
  insertafter  = _insa,
  rem          = _rem,
  removelink   = _rem,
  setv         = _setv,
  setvalue     = _setv,
  swap         = _swap,
  returntable  = _gettable,
    
  },_facemt)
end


-------------------------------------------------------------------------------
-- luo ------------------------------------------------------------------------

-- luo table function parameters aren't validated by _argval ------------------

-- luo -- live uo endofunctor table -------------------------------------------
local _luo = setmetatable(
{
  _type      = 'interface:luo',
  
 AR          = function() return UO.AR          end,
 BackpackID  = function() return UO.BackpackID  end,
 Char        = function() return {
   CursKind  = UO.CursKind,
   Dir       = UO.CharDir,
   ID        = UO.CharID,
   Name      = UO.CharName,
   PosX      = UO.CharPosX,
   PosY      = UO.CharPosY,
   PosZ      = UO.CharPosZ,
   Sex       = UO.Sex,
   Status    = UO.CharStatus,
   Type      = UO.CharType,
                                 }              end,
 CharDir     = function() return UO.CharDir     end,
 CharID      = function() return UO.CharID      end,
 CharName    = function() return UO.CharName    end,
 CharPosX    = function() return UO.CharPosX    end,
 CharPosY    = function() return UO.CharPosY    end,
 CharPosZ    = function() return UO.CharPosZ    end,
 CharStatus  = function() return UO.CharStatus  end,
 CharType    = function() return UO.CharType    end,
 Cli         = function() return {
   Cnt       = UO.CliCnt,
   Lang      = UO.CliLang,
   Left      = UO.CliLeft,
   Logged    = UO.CliLogged,
   Nr        = UO.CliNr,
   Top       = UO.CliTop,
   Ver       = UO.CliVer,
   XRes      = UO.CliXRes,
   YRes      = UO.CliYRes,
                                 }              end,
 CliCnt      = function() return UO.CliCnt      end,
 CliLang     = function() return UO.CliLang     end,
 CliLeft     = function() return UO.CliLeft     end,
 CliLogged   = function() return UO.CliLogged   end,
 CliNr       = function() return UO.CliNr       end,
 CliTop      = function() return UO.CliTop      end,
 CliVer      = function() return UO.CliVer      end,
 CliXRes     = function() return UO.CliXRes     end,
 CliYRes     = function() return UO.CliYRes     end,
 Cont        = function() return {
   ID        = UO.ContID,
   Kind      = UO.ContKind,                                       
   Name      = UO.ContName,
   PosX      = UO.ContPosX,
   PosY      = UO.ContPosY,
   SizeX     = UO.ContSizeX,
   SizeY     = UO.ContSizeY,
   Type      = UO.ContType,
                                 }              end,
 ContID      = function() return UO.ContID      end,
 ContKind    = function() return UO.ContKind    end,
 ContName    = function() return UO.ContName    end,
 ContPosX    = function() return UO.ContPosX    end,
 ContPosY    = function() return UO.ContPosY    end,
 ContSizeX   = function() return UO.ContSizeX   end,
 ContSizeY   = function() return UO.ContSizeY   end,
 ContType    = function() return UO.ContType    end,
 CR          = function() return UO.CR          end,
 Cur         = function() return {
   Dex       = UO.Dex,
   Fol       = UO.Followers,
   Hits      = UO.Hits,
   Int       = UO.Int,
   Mana      = UO.Mana,
   Stam      = UO.Stamina,
   Str       = UO.Str,
   TP        = UO.TP,
   Weight    = UO.Weight,
                                 }              end,
 CursKind    = function() return UO.CursKind    end,
 CursorX     = function() return UO.CursorX     end,
 CursorY     = function() return UO.CursorY     end,
 Dex         = function() return UO.Dex         end,
 EnemyHits   = function() return UO.EnemyHits   end,
 EnemyID     = function() return UO.EnemyID     end,
 ER          = function() return UO.ER          end,
 Followers   = function() return UO.Followers   end,
 FR          = function() return UO.FR          end,
 Gold        = function() return UO.Gold        end,
 Hits        = function() return UO.Hits        end,
 Int         = function() return UO.Int         end,
 LHandID     = function() return UO.LHandID     end,
 LLifted     = function() return {
   ID        = UO.LLiftedID,
   Kind      = UO.LLiftedKind,
   Type      = UO.LLiftedType,
                                 }              end,
 LLiftedID   = function() return UO.LLiftedID   end,
 LLiftedKind = function() return UO.LLiftedKind end,
 LLiftedType = function() return UO.LLiftedType end,
 LObjectID   = function() return UO.LObjectID   end,
 LObjectType = function() return UO.LObjectType end,
 LShard      = function() return UO.LShard      end,
 LSkill      = function() return UO.LSkill      end,
 LSpell      = function() return UO.LSpell      end,
 LTarget     = function() return {
   ID        = UO.LTargetID,
   Kind      = UO.LTargetKind,
   Tile      = UO.LTargetTile,
   X         = UO.LTargetX,
   Y         = UO.LTargetY,
   Z         = UO.LTargetZ,
                                 }              end,
 LTargetID   = function() return UO.LTargetID   end,
 LTargetKind = function() return UO.LTargetKind end,
 LTargetTile = function() return UO.LTargetTile end,
 LTargetX    = function() return UO.LTargetX    end,
 LTargetY    = function() return UO.LTargetY    end,
 LTargetZ    = function() return UO.LTargetZ    end,
 Luck        = function() return UO.Luck        end,
 Mana        = function() return UO.Mana        end,
 Max         = function() return {
   Dmg       = UO.MaxDmg,
   Fol       = UO.MaxFol,
   Hits      = UO.MaxHits,
   Mana      = UO.MaxMana,
   Min       = UO.MinDmg,
   Stam      = UO.MaxStam,
   Stats     = UO.MaxStats,
   Weight    = UO.MaxWeight,
                                 }              end,
 MaxDmg      = function() return UO.MaxDmg      end,
 MaxFol      = function() return UO.MaxFol      end,
 MaxHits     = function() return UO.MaxHits     end,
 MaxMana     = function() return UO.MaxMana     end,
 MaxStam     = function() return UO.MaxStam     end,
 MaxStats    = function() return UO.MaxStats    end,
 MaxWeight   = function() return UO.MaxWeight   end,
 MinDmg      = function() return UO.MinDmg      end,
 NextCPosX   = function() return UO.NextCPosX   end,
 NextCPosY   = function() return UO.NextCPosY   end,
 PR          = function() return UO.PR          end,
 R           = function() return {
   A         = UO.AR,
   C         = UO.CR,
   E         = UO.ER,
   F         = UO.FR,
   P         = UO.PR,   
                                 }              end,
 RHandID     = function() return UO.RHandID     end,
 Sex         = function() return UO.Sex         end,
 Shard       = function() return UO.Shard       end,
 Stamina     = function() return UO.Stamina     end,
 Str         = function() return UO.Str         end,
 SysMsg      = function() return UO.SysMsg      end,
 TargCurs    = function() return UO.TargCurs    end,
 TP          = function() return UO.TP          end,
 Weight      = function() return UO.Weight      end,
}, _facemt)


-------------------------------------------------------------------------------
-- machine --------------------------------------------------------------------

-- a generic state machine
-- interrupted (a)cyclic graph travesal
-- nodes are functions, chains, or machines

-- todo

local _machine = function(states,shared)

  shared = shared or {}

  if type(states) ~= 'table' or type(shared) ~= 'table' then
    local e = __mkex('SL usage error: ',
                   'unexpected argument pattern encountered in machine()',
                   self.iface.probe())
    if e._probe._caller >= 0 then 
      e._errmsg = e._errmsg .. '\013\010at line ' ..
      tostring(e._probe[e._probe._maxlvl].currentline) ..
      ' in ' .. e._probe[e._probe._maxlvl].short_src
    else
      e._errmsg = e._errmsg .. ' in ' .. self.name 
    end
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref) 
  end

  local mon = false
  if states.initiate       == nil        or
     type(states.initiate) ~= 'function' or
     states.exit           == nil        or
     type(states.exit)     ~= 'function' then
    local e = __mkex('SL usage error: ',
                   'state table passed to machine missing initiate and/or exit key(s), or the associated values are not functions',
                   self.iface.probe())
    if e._probe._caller >= 0 then 
      e._errmsg = e._errmsg .. '\013\010at line ' ..
      tostring(e._probe[e._probe._maxlvl].currentline) ..
      ' in ' .. e._probe[e._probe._maxlvl].short_src
    else
      e._errmsg = e._errmsg .. ' in ' .. self.name 
    end
    local eref = self.iface.reporterr(e)
    -- inline, callback, or reraise according to redirection flags
    return __redir(eref) 
  end
  
  if states.monitor ~= nil then mon = true end
  local s = states
  local h = shared
  
  -- local init w/ monitor ----------------------------------------------------
  local _initmon = function(...)
    local n,n0 = 'initiate',''
    local g = s[n](h, ...)
    n0 = n
    n = g
    while n ~= 'exit' do
      if s[n] == nil then
        local e = __mkex('SL usage error: ',
                   'non-existent state "'..tostring(n)..'" requested during state machine execution',
                   self.iface.probe())
        if e._probe._caller >= 0 then 
          e._errmsg = e._errmsg .. '\013\010 from state "'..n0..'" at line ' ..
          tostring(e._probe[e._probe._maxlvl].currentline) ..
          ' in ' .. e._probe[e._probe._maxlvl].short_src
        else
          e._errmsg = e._errmsg .. ' in ' .. self.name 
        end
        local eref = self.iface.reporterr(e)
        -- inline, callback, or reraise according to redirection flags
        return __redir(eref) 
      end
      g = s[n](h)
      g = s.monitor(s,h,n,g)
      n0 = n      
      n = g
    end
    return s.exit(h)
  end
  
  -- local init ---------------------------------------------------------------
  local _init = function(...)
    local n, n0 = 'initiate',''
    local g = s[n](h, ...)
    n0 = n
    n = g
    while n ~= 'exit' do
      if s[n] == nil then
        local e = __mkex('SL usage error: ',
                   'non-existent state "'..tostring(n)..'" requested during state machine execution',
                   self.iface.probe())
        if e._probe._caller >= 0 then 
          e._errmsg = e._errmsg .. '\013\010 from state "'..n0..'" at line ' ..
          tostring(e._probe[e._probe._maxlvl].currentline) ..
          ' in ' .. e._probe[e._probe._maxlvl].short_src
        else
          e._errmsg = e._errmsg .. ' in ' .. self.name 
        end
        local eref = self.iface.reporterr(e)
        -- inline, callback, or reraise according to redirection flags
        return __redir(eref) 
      end
      g = s[n](h)
      n0 = n      
      n = g
    end
    return s.exit(h)
  end

  if mon == true then
    return setmetatable(
    {
      _type = 'interface:machine',
      
      initiate      = function(...) return self.iface.itry(_initmon, 'initiate', ...) end,
    }, _facemt)
  end
  
  return setmetatable(
  {
    _type = 'interface:machine',
    
    initiate        = function(...) return self.iface.itry(_init,    'initiate', ...) end,
  }, _facemt)
end




-------------------------------------------------------------------------------
-- macro ----------------------------------------------------------------------

-- courtesy WarLocke
-- macro table function parameters aren't validated by _argval

-- macro table -- metatable ---------------------------------------------------

local _searchmacroindex = function(t,k)

   local kl = string.lower(k)
   for i,j in pairs(t) do
     local i = string.lower(i)
     if string.find(i,kl,1,true) ~= nil then return j end
   end

   local a = self.iface.probe()
   local s = '".'
   if a ~= nil and a ~= ET and a._maxlvl >= 0 then
     s = '" at line '..tostring(a[a._maxlvl].currentline)..'.\013\010'
   end
   local e = __mkex('SL usage error: ',
                    'macro table blocked requested access to unmatched '..
                    'event macro\013\010specified as "'..tostring(k)..s,
                    a)
   local eref = self.iface.reporterr(e)
   
   return nil
end

local _macromt = {
  __index     = _searchmacroindex,
  __newindex  = _onnew,
  __metatable = 'SL warning    : simplelib macro metatable is sealed.'
  } 

-- macro table ---------------------------------------------------------------- 
local _macro = setmetatable({
  _type = 'interface.macro',
  
  Say                           = function(txt) UO.Macro( 1,   0, txt or '') end,  
  Emote                         = function(txt) UO.Macro( 2,   0, txt or '') end,  
  Whisper                       = function(txt) UO.Macro( 3,   0, txt or '') end,  
  Yell                          = function(txt) UO.Macro( 4,   4, txt or '') end,  
  Walk                          = function(dir) UO.Macro( 5, dir or 1,   '') end,  
  WalkNorthWest                 = function()    UO.Macro( 5,   0, '')     end,  
  WalkNorth                     = function()    UO.Macro( 5,   1, '')     end,  
  WalkNorthEast                 = function()    UO.Macro( 5,   2, '')     end,  
  WalkEast                      = function()    UO.Macro( 5,   3, '')     end,  
  WalkSouthEast                 = function()    UO.Macro( 5,   4, '')     end,  
  WalkSouth                     = function()    UO.Macro( 5,   5, '')     end,  
  WalkSouthWest                 = function()    UO.Macro( 5,   6, '')     end,  
  WalkWest                      = function()    UO.Macro( 5,   7, '')     end,  
  ToggleWarPeace                = function()    UO.Macro( 6,   0, '')     end,  
  Paste                         = function()    UO.Macro( 7,   0, '')     end,  
  OpenConfiguration             = function()    UO.Macro( 8,   0, '')     end,  
  OpenPaperdoll                 = function()    UO.Macro( 8,   1, '')     end,  
  OpenStatus                    = function()    UO.Macro( 8,   2, '')     end,  
  OpenJournal                   = function()    UO.Macro( 8,   3, '')     end,  
  OpenSkills                    = function()    UO.Macro( 8,   4, '')     end,  
  OpenSpellbook                 = function()    UO.Macro( 8,   5, '')     end,  
  OpenChat                      = function()    UO.Macro( 8,   6, '')     end,  
  OpenBackpack                  = function()    UO.Macro( 8,   7, '')     end,  
  OpenOverview                  = function()    UO.Macro( 8,   8, '')     end,  
  OpenMail                      = function()    UO.Macro( 8,   9, '')     end,  
  OpenPartyManifest             = function()    UO.Macro( 8,  10, '')     end,  
  OpenPartyChat                 = function()    UO.Macro( 8,  11, '')     end,  
  OpenNecroSpellbook            = function()    UO.Macro( 8,  12, '')     end,  
  OpenPaladinSpellbook          = function()    UO.Macro( 8,  13, '')     end,  
  OpenCombatBook                = function()    UO.Macro( 8,  14, '')     end,  
  OpenBushidoSpellbook          = function()    UO.Macro( 8,  15, '')     end,  
  OpenNinjitsuSpellbook         = function()    UO.Macro( 8,  16, '')     end,  
  OpenGuild                     = function()    UO.Macro( 8,  17, '')     end,  
  OpenSpellweavingSpellbook     = function()    UO.Macro( 8,  18, '')     end,  
  OpenQuestLog                  = function()    UO.Macro( 8,  19, '')     end,  
  CloseConfiguration            = function()    UO.Macro( 9,   0, '')     end,  
  ClosePaperdoll                = function()    UO.Macro( 9,   1, '')     end,  
  CloseStatus                   = function()    UO.Macro( 9,   2, '')     end,  
  CloseJournal                  = function()    UO.Macro( 8,   3, '')     end,  
  CloseSkills                   = function()    UO.Macro( 9,   4, '')     end,  
  CloseSpellbook                = function()    UO.Macro( 9,   5, '')     end,  
  CloseChat                     = function()    UO.Macro( 9,   6, '')     end,  
  CloseBackpack                 = function()    UO.Macro( 9,   7, '')     end,  
  CloseOverview                 = function()    UO.Macro( 9,   8, '')     end,  
  CloseMail                     = function()    UO.Macro( 9,   9, '')     end,  
  ClosePartyManifest            = function()    UO.Macro( 9,  10, '')     end,  
  ClosePartyChat                = function()    UO.Macro( 9,  11, '')     end,  
  CloseNecroSpellbook           = function()    UO.Macro( 9,  12, '')     end,  
  ClosePaladinSpellbook         = function()    UO.Macro( 9,  13, '')     end,  
  CloseCombatBook               = function()    UO.Macro( 9,  14, '')     end,  
  CloseBushidoSpellbook         = function()    UO.Macro( 9,  15, '')     end,  
  CloseNinjitsuSpellbook        = function()    UO.Macro( 9,  16, '')     end,  
  CloseGuild                    = function()    UO.Macro( 9,  17, '')     end,  
  CloseSpellweavingSpellbook    = function()    UO.Macro( 9,  18, '')     end,   -- assumed
  CloseQuestLog                 = function()    UO.Macro( 9,  19, '')     end,   -- assumed
  MinimizePaperdoll             = function()    UO.Macro(10,   1, '')     end,  
  MinimizeStatus                = function()    UO.Macro(10,   2, '')     end,  
  MinimizeJournal               = function()    UO.Macro(10,   3, '')     end,  
  MinimizeSkills                = function()    UO.Macro(10,   4, '')     end,  
  MinimizeSpellbook             = function()    UO.Macro(10,   5, '')     end,  
  MinimizeChat                  = function()    UO.Macro(10,   6, '')     end,  
  MinimizeBackpack              = function()    UO.Macro(10,   7, '')     end,  
  MinimizeOverview              = function()    UO.Macro(10,   8, '')     end,  
  MinimizeMail                  = function()    UO.Macro(10,   9, '')     end,  
  MinimizePartyManifest         = function()    UO.Macro(10,  10, '')     end,  
  MinimizePartyChat             = function()    UO.Macro(10,  11, '')     end,  
  MinimizeNecroSpellbook        = function()    UO.Macro(10,  12, '')     end,  
  MinimizePaladinSpellbook      = function()    UO.Macro(10,  13, '')     end,  
  MinimizeCombatBook            = function()    UO.Macro(10,  14, '')     end,  
  MinimizeBushidoSpellbook      = function()    UO.Macro(10,  15, '')     end,  
  MinimizeNinjitsuSpellbook     = function()    UO.Macro(10,  16, '')     end,  
  MinimizeGuild                 = function()    UO.Macro(10,  17, '')     end,  
  MinimizeSpellweavingSpellbook = function()    UO.Macro(10,  18, '')     end,   -- assumed
  MaximizePaperdoll             = function()    UO.Macro(11,   1, '')     end,  
  MaximizeStatus                = function()    UO.Macro(11,   2, '')     end,  
  MaximizeJournal               = function()    UO.Macro(11,   3, '')     end,  
  MaximizeSkills                = function()    UO.Macro(11,   4, '')     end,  
  MaximizeSpellbook             = function()    UO.Macro(11,   5, '')     end,  
  MaximizeChat                  = function()    UO.Macro(11,   6, '')     end,  
  MaximizeBackpack              = function()    UO.Macro(11,   7, '')     end,  
  MaximizeOverview              = function()    UO.Macro(11,   8, '')     end,  
  MaximizeMail                  = function()    UO.Macro(11,   9, '')     end,  
  MaximizePartyManifest         = function()    UO.Macro(11,  10, '')     end,  
  MaximizePartyChat             = function()    UO.Macro(11,  11, '')     end,  
  MaximizeNecroSpellbook        = function()    UO.Macro(11,  12, '')     end,  
  MaximizePaladinSpellbook      = function()    UO.Macro(11,  13, '')     end,  
  MaximizeCombatBook            = function()    UO.Macro(11,  14, '')     end,  
  MaximizeBushidoSpellbook      = function()    UO.Macro(11,  15, '')     end,  
  MaximizeNinjitsuSpellbook     = function()    UO.Macro(11,  16, '')     end,  
  MaximizeGuild                 = function()    UO.Macro(11,  17, '')     end,  
  MaximizeSpellweavingSpellbook = function()    UO.Macro(11,  18, '')     end,   -- assumed
  OpenDoor                      = function()    UO.Macro(12,   0, '')     end,  
  UseAnatomy                    = function()    UO.Macro(13,   1, '')     end,  
  UseAnimalLore                 = function()    UO.Macro(13,   2, '')     end,  
  UseAnimalTaming               = function()    UO.Macro(13,  35, '')     end,  
  UseArmsLore                   = function()    UO.Macro(13,   4, '')     end,  
  UseBegging                    = function()    UO.Macro(13,   6, '')     end,  
  UseCartography                = function()    UO.Macro(13,  12, '')     end,  
  UseDetectingHidden            = function()    UO.Macro(13,  14, '')     end,  
  UseDiscordance                = function()    UO.Macro(13,  15, '')     end,  
  UseEvaluatingIntelligence     = function()    UO.Macro(13,  16, '')     end,  
  UseForensicEvaluation         = function()    UO.Macro(13,  19, '')     end,  
  UseHiding                     = function()    UO.Macro(13,  21, '')     end,  
  UseInscription                = function()    UO.Macro(13,  23, '')     end,  
  UseItemIdentification         = function()    UO.Macro(13,   3, '')     end,  
  UseMeditation                 = function()    UO.Macro(13,  46, '')     end,  
  UsePeacemaking                = function()    UO.Macro(13,   9, '')     end,  
  UsePoisoning                  = function()    UO.Macro(13,  30, '')     end,  
  UseProvocation                = function()    UO.Macro(13,  22, '')     end,  
  UseRemoveTrap                 = function()    UO.Macro(13,  48, '')     end,  
  UseSpiritSpeak                = function()    UO.Macro(13,  32, '')     end,  
  UseStealing                   = function()    UO.Macro(13,  33, '')     end,  
  UseStealth                    = function()    UO.Macro(13,  47, '')     end,  
  UseTasteIdentification        = function()    UO.Macro(13,  36, '')     end,  
  UseTracking                   = function()    UO.Macro(13,  38, '')     end,  
  LastSkill                     = function()    UO.Macro(14,   0, '')     end,  
  CastClumsy                    = function()    UO.Macro(15,   0, '')     end,  
  CastCreateFood                = function()    UO.Macro(15,   1, '')     end,  
  CastFeeblemind                = function()    UO.Macro(15,   2, '')     end,  
  CastHeal                      = function()    UO.Macro(15,   3, '')     end,  
  CastMagicArrow                = function()    UO.Macro(15,   4, '')     end,  
  CastNightSight                = function()    UO.Macro(15,   5, '')     end,  
  CastReactiveArmor             = function()    UO.Macro(15,   6, '')     end,  
  CastWeaken                    = function()    UO.Macro(15,   7, '')     end,  
  CastAgility                   = function()    UO.Macro(15,   8, '')     end,  
  CastCunning                   = function()    UO.Macro(15,   9, '')     end,  
  CastCure                      = function()    UO.Macro(15,  10, '')     end,  
  CastHarm                      = function()    UO.Macro(15,  11, '')     end,  
  CastMagicTrap                 = function()    UO.Macro(15,  12, '')     end,  
  CastMagicUntrap               = function()    UO.Macro(15,  13, '')     end,  
  CastProtection                = function()    UO.Macro(15,  14, '')     end,  
  CastStrength                  = function()    UO.Macro(15,  15, '')     end,  
  CastBless                     = function()    UO.Macro(15,  16, '')     end,  
  CastFireball                  = function()    UO.Macro(15,  17, '')     end,  
  CastMagicLock                 = function()    UO.Macro(15,  18, '')     end,  
  CastPoison                    = function()    UO.Macro(15,  19, '')     end,  
  CastTelekinesis               = function()    UO.Macro(15,  20, '')     end,  
  CastTeleport                  = function()    UO.Macro(15,  21, '')     end,  
  CastUnlock                    = function()    UO.Macro(15,  22, '')     end,  
  CastWallOfStone               = function()    UO.Macro(15,  23, '')     end,  
  CastArchCure                  = function()    UO.Macro(15,  24, '')     end,  
  CastArchProtection            = function()    UO.Macro(15,  25, '')     end,  
  CastCurse                     = function()    UO.Macro(15,  26, '')     end,  
  CastFireField                 = function()    UO.Macro(15,  27, '')     end,  
  CastGreaterHeal               = function()    UO.Macro(15,  28, '')     end,  
  CastLightning                 = function()    UO.Macro(15,  29, '')     end,  
  CastManaDrain                 = function()    UO.Macro(15,  30, '')     end,  
  CastRecall                    = function()    UO.Macro(15,  31, '')     end,  
  CastBladeSpirits              = function()    UO.Macro(15,  32, '')     end,  
  CastDispelField               = function()    UO.Macro(15,  33, '')     end,  
  CastIncognito                 = function()    UO.Macro(15,  34, '')     end,  
  CastMagicReflection           = function()    UO.Macro(15,  35, '')     end,  
  CastMindBlast                 = function()    UO.Macro(15,  36, '')     end,  
  CastParalyze                  = function()    UO.Macro(15,  37, '')     end,  
  CastPoisonField               = function()    UO.Macro(15,  38, '')     end,  
  CastSummonCreature            = function()    UO.Macro(15,  39, '')     end,  
  CastDispel                    = function()    UO.Macro(15,  40, '')     end,  
  CastEnergyBolt                = function()    UO.Macro(15,  41, '')     end,  
  CastExplosion                 = function()    UO.Macro(15,  42, '')     end,  
  CastInvisibility              = function()    UO.Macro(15,  43, '')     end,  
  CastMark                      = function()    UO.Macro(15,  44, '')     end,  
  CastMassCurse                 = function()    UO.Macro(15,  45, '')     end,  
  CastParalyzeField             = function()    UO.Macro(15,  46, '')     end,  
  CastReveal                    = function()    UO.Macro(15,  47, '')     end,  
  CastChainLightning            = function()    UO.Macro(15,  48, '')     end,  
  CastEnergyField               = function()    UO.Macro(15,  49, '')     end,  
  CastFlameStrike               = function()    UO.Macro(15,  50, '')     end,  
  CastGateTravel                = function()    UO.Macro(15,  51, '')     end,  
  CastManaVampire               = function()    UO.Macro(15,  52, '')     end,  
  CastMassDispel                = function()    UO.Macro(15,  53, '')     end,  
  CastMeteorSwarm               = function()    UO.Macro(15,  54, '')     end,  
  CastPolymorph                 = function()    UO.Macro(15,  55, '')     end,  
  CastEarthquake                = function()    UO.Macro(15,  56, '')     end,  
  CastEnergyVortex              = function()    UO.Macro(15,  57, '')     end,  
  CastResurrection              = function()    UO.Macro(15,  58, '')     end,  
  CastAirElemental              = function()    UO.Macro(15,  59, '')     end,  
  CastSummonDaemon              = function()    UO.Macro(15,  60, '')     end,  
  CastEarthElemental            = function()    UO.Macro(15,  61, '')     end,  
  CastFireElemental             = function()    UO.Macro(15,  62, '')     end,  
  CastWaterElemental            = function()    UO.Macro(15,  63, '')     end,  
  CastAnimateDead               = function()    UO.Macro(15, 101, '')     end,    
  CastBloodOath                 = function()    UO.Macro(15, 102, '')     end,    
  CastCorpseSkin                = function()    UO.Macro(15, 103, '')     end,    
  CastCurseWeapon               = function()    UO.Macro(15, 104, '')     end,    
  CastEvilOmen                  = function()    UO.Macro(15, 105, '')     end,    
  CastHorrificBeast             = function()    UO.Macro(15, 106, '')     end,    
  CastLichForm                  = function()    UO.Macro(15, 107, '')     end,    
  CastMindRot                   = function()    UO.Macro(15, 108, '')     end,    
  CastPainSpike                 = function()    UO.Macro(15, 109, '')     end,    
  CastPoisonStrike              = function()    UO.Macro(15, 110, '')     end,    
  CastStrangle                  = function()    UO.Macro(15, 111, '')     end,    
  CastSummonFamiliar            = function()    UO.Macro(15, 112, '')     end,    
  CastVampiricEmbrace           = function()    UO.Macro(15, 113, '')     end,    
  CastVengefulSpirit            = function()    UO.Macro(15, 114, '')     end,    
  CastWither                    = function()    UO.Macro(15, 115, '')     end,    
  CastWraithForm                = function()    UO.Macro(15, 116, '')     end,    
  CastExorcism                  = function()    UO.Macro(15, 117, '')     end,    
  CastHonorableExecution        = function()    UO.Macro(15, 145, '')     end,    
  CastConfidence                = function()    UO.Macro(15, 146, '')     end,    
  CastEvasion                   = function()    UO.Macro(15, 147, '')     end,    
  CastCounterAttack             = function()    UO.Macro(15, 148, '')     end,    
  CastLightningStrike           = function()    UO.Macro(15, 149, '')     end,    
  CastMomentumStrike            = function()    UO.Macro(15, 150, '')     end,    
  CastCleanseByFire             = function()    UO.Macro(15, 201, '')     end,    
  CastCloseWounds               = function()    UO.Macro(15, 202, '')     end,    
  CastConsecrateWeapon          = function()    UO.Macro(15, 203, '')     end,    
  CastDispelEvil                = function()    UO.Macro(15, 204, '')     end,    
  CastDivineFury                = function()    UO.Macro(15, 205, '')     end,    
  CastEnemyOfOne                = function()    UO.Macro(15, 206, '')     end,    
  CastHolyLight                 = function()    UO.Macro(15, 207, '')     end,    
  CastNobleSacrifice            = function()    UO.Macro(15, 208, '')     end,    
  CastRemoveCurse               = function()    UO.Macro(15, 209, '')     end,    
  CastSacredJourney             = function()    UO.Macro(15, 210, '')     end,    
  CastFocusAttack               = function()    UO.Macro(15, 245, '')     end,    
  CastDeathStrike               = function()    UO.Macro(15, 246, '')     end,    
  CastAnimalForm                = function()    UO.Macro(15, 247, '')     end,    
  CastKiAttack                  = function()    UO.Macro(15, 248, '')     end,    
  CastSurpriseAttack            = function()    UO.Macro(15, 249, '')     end,    
  CastBackstab                  = function()    UO.Macro(15, 250, '')     end,    
  CastShadowjump                = function()    UO.Macro(15, 251, '')     end,    
  CastMirrorImage               = function()    UO.Macro(15, 252, '')     end,    
  CastArcaneCircle              = function()    UO.Macro(15, 601, '')     end,    
  CastGiftOfRenewal             = function()    UO.Macro(15, 602, '')     end,    
  CastImmolatingWeapon          = function()    UO.Macro(15, 603, '')     end,    
  CastAttunement                = function()    UO.Macro(15, 604, '')     end,    
  CastThunderstorm              = function()    UO.Macro(15, 605, '')     end,    
  CastNaturesFury               = function()    UO.Macro(15, 606, '')     end,    
  CastSummonFey                 = function()    UO.Macro(15, 607, '')     end,    
  CastSummonFiend               = function()    UO.Macro(15, 608, '')     end,    
  CastReaperForm                = function()    UO.Macro(15, 609, '')     end,    
  CastWildfire                  = function()    UO.Macro(15, 610, '')     end,    
  CastEssenceOfWind             = function()    UO.Macro(15, 611, '')     end,    
  CastDryadAllure               = function()    UO.Macro(15, 612, '')     end,    
  CastEtherealVoyage            = function()    UO.Macro(15, 613, '')     end,    
  CastWordOfDeath               = function()    UO.Macro(15, 614, '')     end,    
  CastGiftOfLife                = function()    UO.Macro(15, 615, '')     end,    
  CastArcaneEmpowerment         = function()    UO.Macro(15, 616, '')     end,    
  LastSpell                     = function()    UO.Macro(16,   0, '')     end,  
  LastObject                    = function()    UO.Macro(17,   0, '')     end,  
  Bow                           = function()    UO.Macro(18,   0, '')     end,  
  Salute                        = function()    UO.Macro(19,   0, '')     end,  
  QuitGame                      = function()    UO.Macro(20,   0, '')     end,  
  AllNames                      = function()    UO.Macro(21,   0, '')     end,  
  LastTarget                    = function()    UO.Macro(22,   0, '')     end,  
  TargetSelf                    = function()    UO.Macro(23,   0, '')     end,  
  ArmDisarmLeft                 = function()    UO.Macro(24,   1, '')     end,  
  ArmDisarmRight                = function()    UO.Macro(24,   2, '')     end,  
  WaitForTarget                 = function()    UO.Macro(25,   0, '')     end,  
  TargetNext                    = function()    UO.Macro(26,   0, '')     end,  
  AttackLast                    = function()    UO.Macro(27,   0, '')     end,  
  Delay                         = function(x)   UO.Macro(28,   0, x or 1) end,  
  CircleTrans                   = function()    UO.Macro(29,   0, '')     end,  
  CloseGumps                    = function()    UO.Macro(31,   0, '')     end,  
  AlwaysRun                     = function()    UO.Macro(32,   0, '')     end,  
  SaveDesktop                   = function()    UO.Macro(33,   0, '')     end,  
  KillGumpOpen                  = function()    UO.Macro(34,   0, '')     end,  
  PrimaryAbility                = function()    UO.Macro(35,   0, '')     end,  
  SecondaryAbility              = function()    UO.Macro(36,   0, '')     end,  
  EquipLastWeapon               = function()    UO.Macro(37,   0, '')     end,  
  SetUpdateRange                = function(x)   UO.Macro(38,   0, x or 1) end,  
  ModifyUpdateRange             = function(x)   UO.Macro(39,   0, x or 1) end,  
  IncreaseUpdateRange           = function()    UO.Macro(40,   0, '')     end,  
  DecreaseUpdateRange           = function()    UO.Macro(41,   0, '')     end,  
  MaximumUpdateRange            = function()    UO.Macro(42,   0, '')     end,  
  MinimumUpdateRange            = function()    UO.Macro(43,   0, '')     end,  
  DefaultUpdateRange            = function()    UO.Macro(44,   0, '')     end,  
  UpdateUpdateRange             = function()    UO.Macro(45,   0, '')     end,  
  EnableUpdateRangeColor        = function()    UO.Macro(46,   0, '')     end,  
  DisableUpdateRangeColor       = function()    UO.Macro(47,   0, '')     end,  
  ToggleUpdateRangeColor        = function()    UO.Macro(48,   0, '')     end,  
  InvokeHonorVirtue             = function()    UO.Macro(49,   1, '')     end,  
  InvokeSacrificeVirtue         = function()    UO.Macro(49,   2, '')     end,  
  InvokeValorVirtue             = function()    UO.Macro(49,   3, '')     end,  
  InvokeCompassionVirtue        = function()    UO.Macro(49,   4, '')     end,  
  InvokeJusticeProtection       = function()    UO.Macro(49,   7, '')     end,  
  SelectNextHostile             = function()    UO.Macro(50,   1, '')     end,  
  SelectNextPartyMember         = function()    UO.Macro(50,   2, '')     end,  
  SelectNextFollower            = function()    UO.Macro(50,   3, '')     end,  
  SelectNextObject              = function()    UO.Macro(50,   4, '')     end,  
  SelectNextMobile              = function()    UO.Macro(50,   5, '')     end,  
  SelectPreviousHostile         = function()    UO.Macro(51,   1, '')     end,  
  SelectPreviousPartyMember     = function()    UO.Macro(51,   2, '')     end,  
  SelectPreviousFollower        = function()    UO.Macro(51,   3, '')     end,  
  SelectPreviousObject          = function()    UO.Macro(51,   4, '')     end,  
  SelectPreviousMobile          = function()    UO.Macro(51,   5, '')     end,  
  SelectNearestHostile          = function()    UO.Macro(52,   1, '')     end,  
  SelectNearestPartyMember      = function()    UO.Macro(52,   2, '')     end,  
  SelectNearestFollower         = function()    UO.Macro(52,   3, '')     end,  
  SelectNearestObject           = function()    UO.Macro(52,   4, '')     end,  
  SelectNearestMobile           = function()    UO.Macro(52,   5, '')     end,  
  AttackSelected                = function()    UO.Macro(53,  '', '')     end,  
  UseSelected                   = function()    UO.Macro(54,  '', '')     end,  
  CurrentTarget                 = function()    UO.Macro(55,  '', '')     end,  
  TargetingSystemOnOff          = function()    UO.Macro(56,  '', '')     end,  
  ToggleBuffWindow              = function()    UO.Macro(57,  '', '')     end,  
  BandageSelf                   = function()    UO.Macro(58,  '', '')     end,  
  BandageTarget                 = function()    UO.Macro(59,  '',' ')     end,
  
  ------------- shortened versions --------------------------------------------
  
  --Say                         = function(txt) UO.Macro( 1,   0, txt or '') end,  
  --Emote                       = function(txt) UO.Macro( 2,   0, txt or '') end,  
  --Whisper                     = function(txt) UO.Macro( 3,   0, txt or '') end,  
  --Yell                        = function(txt) UO.Macro( 4,   4, txt or '') end,  
  W                             = function(dir) UO.Macro( 5, dir or 1,   '') end,  
  WNW                           = function()    UO.Macro( 5,   0, '')     end,  
  WN                            = function()    UO.Macro( 5,   1, '')     end,  
  WNE                           = function()    UO.Macro( 5,   2, '')     end,  
  WE                            = function()    UO.Macro( 5,   3, '')     end,  
  WSE                           = function()    UO.Macro( 5,   4, '')     end,  
  WS                            = function()    UO.Macro( 5,   5, '')     end,  
  WSW                           = function()    UO.Macro( 5,   6, '')     end,  
  WW                            = function()    UO.Macro( 5,   7, '')     end,  
  Toggle                        = function()    UO.Macro( 6,   0, '')     end,  
  --Paste                       = function()    UO.Macro( 7,   0, '')     end,  
  OConfig                       = function()    UO.Macro( 8,   0, '')     end,  
  OPD                           = function()    UO.Macro( 8,   1, '')     end,  
  OStatus                       = function()    UO.Macro( 8,   2, '')     end,  
  OJournal                      = function()    UO.Macro( 8,   3, '')     end,  
  OSkills                       = function()    UO.Macro( 8,   4, '')     end,  
  OSpell                        = function()    UO.Macro( 8,   5, '')     end,  
  OChat                         = function()    UO.Macro( 8,   6, '')     end,  
  OBP                           = function()    UO.Macro( 8,   7, '')     end,  
  ORadar                        = function()    UO.Macro( 8,   8, '')     end,  
  OMail                         = function()    UO.Macro( 8,   9, '')     end,  
  OPartyMan                     = function()    UO.Macro( 8,  10, '')     end,  
  OPartyChat                    = function()    UO.Macro( 8,  11, '')     end,  
  ONecro                        = function()    UO.Macro( 8,  12, '')     end,  
  OPaladin                      = function()    UO.Macro( 8,  13, '')     end,  
  OCombat                       = function()    UO.Macro( 8,  14, '')     end,  
  OBushido                      = function()    UO.Macro( 8,  15, '')     end,  
  ONinjitsu                     = function()    UO.Macro( 8,  16, '')     end,  
  OGuild                        = function()    UO.Macro( 8,  17, '')     end,  
  OSpellweav                    = function()    UO.Macro( 8,  18, '')     end,  
  OQuest                        = function()    UO.Macro( 8,  19, '')     end,  
  CConfig                       = function()    UO.Macro( 9,   0, '')     end,  
  CPD                           = function()    UO.Macro( 9,   1, '')     end,  
  CStatus                       = function()    UO.Macro( 9,   2, '')     end,  
  CJournal                      = function()    UO.Macro( 8,   3, '')     end,  
  CSkills                       = function()    UO.Macro( 9,   4, '')     end,  
  CSpell                        = function()    UO.Macro( 9,   5, '')     end,  
  CChat                         = function()    UO.Macro( 9,   6, '')     end,  
  CBP                           = function()    UO.Macro( 9,   7, '')     end,  
  CRadar                        = function()    UO.Macro( 9,   8, '')     end,  
  CMail                         = function()    UO.Macro( 9,   9, '')     end,  
  CPartyMan                     = function()    UO.Macro( 9,  10, '')     end,  
  CPartyChat                    = function()    UO.Macro( 9,  11, '')     end,  
  CNecro                        = function()    UO.Macro( 9,  12, '')     end,  
  CPaladin                      = function()    UO.Macro( 9,  13, '')     end,  
  CCombat                       = function()    UO.Macro( 9,  14, '')     end,  
  CBushido                      = function()    UO.Macro( 9,  15, '')     end,  
  CNinjitsu                     = function()    UO.Macro( 9,  16, '')     end,  
  CGuild                        = function()    UO.Macro( 9,  17, '')     end,  
  CSpellweav                    = function()    UO.Macro( 9,  18, '')     end,   -- assumed
  CQuest                        = function()    UO.Macro( 9,  19, '')     end,   -- assumed
  MinPD                         = function()    UO.Macro(10,   1, '')     end,  
  MinStatus                     = function()    UO.Macro(10,   2, '')     end,  
  MinJournal                    = function()    UO.Macro(10,   3, '')     end,  
  MinSkills                     = function()    UO.Macro(10,   4, '')     end,  
  MinSpell                      = function()    UO.Macro(10,   5, '')     end,  
  MinChat                       = function()    UO.Macro(10,   6, '')     end,  
  MinBP                         = function()    UO.Macro(10,   7, '')     end,  
  MinRadar                      = function()    UO.Macro(10,   8, '')     end,  
  MinMail                       = function()    UO.Macro(10,   9, '')     end,  
  MinPartyMan                   = function()    UO.Macro(10,  10, '')     end,  
  MinPartyChat                  = function()    UO.Macro(10,  11, '')     end,  
  MinNecro                      = function()    UO.Macro(10,  12, '')     end,  
  MinPaladin                    = function()    UO.Macro(10,  13, '')     end,  
  MinCombat                     = function()    UO.Macro(10,  14, '')     end,  
  MinBushido                    = function()    UO.Macro(10,  15, '')     end,  
  MinNinjitsu                   = function()    UO.Macro(10,  16, '')     end,  
  MinGuild                      = function()    UO.Macro(10,  17, '')     end,  
  MinSpellweav                  = function()    UO.Macro(10,  18, '')     end,   -- assumed
  MaxPD                         = function()    UO.Macro(11,   1, '')     end,  
  MaxStatus                     = function()    UO.Macro(11,   2, '')     end,  
  MaxJournal                    = function()    UO.Macro(11,   3, '')     end,  
  MaxSkills                     = function()    UO.Macro(11,   4, '')     end,  
  MaxSpell                      = function()    UO.Macro(11,   5, '')     end,  
  MaxChat                       = function()    UO.Macro(11,   6, '')     end,  
  MaxBP                         = function()    UO.Macro(11,   7, '')     end,  
  MaxRadar                      = function()    UO.Macro(11,   8, '')     end,  
  MaxMail                       = function()    UO.Macro(11,   9, '')     end,  
  MaxPartyMan                   = function()    UO.Macro(11,  10, '')     end,  
  MaxPartyChat                  = function()    UO.Macro(11,  11, '')     end,  
  MaxNecro                      = function()    UO.Macro(11,  12, '')     end,  
  MaxPaladin                    = function()    UO.Macro(11,  13, '')     end,  
  MaxCombat                     = function()    UO.Macro(11,  14, '')     end,  
  MaxBushido                    = function()    UO.Macro(11,  15, '')     end,  
  MaxNinjitsu                   = function()    UO.Macro(11,  16, '')     end,  
  MaxGuild                      = function()    UO.Macro(11,  17, '')     end,  
  MaxSpellweav                  = function()    UO.Macro(11,  18, '')     end,   -- assumed
  ODoor                         = function()    UO.Macro(12,   0, '')     end,  
  UAnat                         = function()    UO.Macro(13,   1, '')     end,  
  UAnil                         = function()    UO.Macro(13,   2, '')     end,  
  UAnim                         = function()    UO.Macro(13,  35, '')     end,  
  UArms                         = function()    UO.Macro(13,   4, '')     end,  
  UBegg                         = function()    UO.Macro(13,   6, '')     end,  
  UCart                         = function()    UO.Macro(13,  12, '')     end,  
  UDete                         = function()    UO.Macro(13,  14, '')     end,  
  UDisc                         = function()    UO.Macro(13,  15, '')     end,  
  UEval                         = function()    UO.Macro(13,  16, '')     end,  
  UFore                         = function()    UO.Macro(13,  19, '')     end,  
  UHidi                         = function()    UO.Macro(13,  21, '')     end,  
  UInsc                         = function()    UO.Macro(13,  23, '')     end,  
  UItem                         = function()    UO.Macro(13,   3, '')     end,  
  UMedi                         = function()    UO.Macro(13,  46, '')     end,  
  UPeac                         = function()    UO.Macro(13,   9, '')     end,  
  UPois                         = function()    UO.Macro(13,  30, '')     end,  
  UProv                         = function()    UO.Macro(13,  22, '')     end,  
  URemo                         = function()    UO.Macro(13,  48, '')     end,  
  USpir                         = function()    UO.Macro(13,  32, '')     end,  
  UStea                         = function()    UO.Macro(13,  33, '')     end,  
  UStlt                         = function()    UO.Macro(13,  47, '')     end,  
  UTast                         = function()    UO.Macro(13,  36, '')     end,  
  UTrac                         = function()    UO.Macro(13,  38, '')     end,  
  LSkill                        = function()    UO.Macro(14,   0, '')     end,  
  _Clum                         = function()    UO.Macro(15,   0, '')     end,  
  _CreateFood                   = function()    UO.Macro(15,   1, '')     end,  
  _Feeb                         = function()    UO.Macro(15,   2, '')     end,  
  _Heal                         = function()    UO.Macro(15,   3, '')     end,  
  _MagicArro                    = function()    UO.Macro(15,   4, '')     end,  
  _NightSigh                    = function()    UO.Macro(15,   5, '')     end,  
  _ReactiveArmo                 = function()    UO.Macro(15,   6, '')     end,  
  _Weak                         = function()    UO.Macro(15,   7, '')     end,  
  _Agil                         = function()    UO.Macro(15,   8, '')     end,  
  _Cunn                         = function()    UO.Macro(15,   9, '')     end,  
  _Cure                         = function()    UO.Macro(15,  10, '')     end,  
  _Harm                         = function()    UO.Macro(15,  11, '')     end,  
  _MagicTrap                    = function()    UO.Macro(15,  12, '')     end,  
  _MagicUntr                    = function()    UO.Macro(15,  13, '')     end,  
  _Prot                         = function()    UO.Macro(15,  14, '')     end,  
  _Stre                         = function()    UO.Macro(15,  15, '')     end,  
  _Bles                         = function()    UO.Macro(15,  16, '')     end,  
  _Fire                         = function()    UO.Macro(15,  17, '')     end,  
  _MagicLock                    = function()    UO.Macro(15,  18, '')     end,  
  _Pois                         = function()    UO.Macro(15,  19, '')     end,  
  _Telek                        = function()    UO.Macro(15,  20, '')     end,  
  _Telep                        = function()    UO.Macro(15,  21, '')     end,  
  _Unlo                         = function()    UO.Macro(15,  22, '')     end,  
  _WallOfSton                   = function()    UO.Macro(15,  23, '')     end,  
  _ArchCure                     = function()    UO.Macro(15,  24, '')     end,  
  _ArchProt                     = function()    UO.Macro(15,  25, '')     end,  
  _Curs                         = function()    UO.Macro(15,  26, '')     end,  
  _FireFiel                     = function()    UO.Macro(15,  27, '')     end,  
  _GreaterHeal                  = function()    UO.Macro(15,  28, '')     end,  
  _Ligh                         = function()    UO.Macro(15,  29, '')     end,  
  _ManaDrai                     = function()    UO.Macro(15,  30, '')     end,  
  _Reca                         = function()    UO.Macro(15,  31, '')     end,  
  _BladeSpir                    = function()    UO.Macro(15,  32, '')     end,  
  _DispelFiel                   = function()    UO.Macro(15,  33, '')     end,  
  _Inco                         = function()    UO.Macro(15,  34, '')     end,  
  _MagicRefl                    = function()    UO.Macro(15,  35, '')     end,  
  _MindBlas                     = function()    UO.Macro(15,  36, '')     end,  
  _Para                         = function()    UO.Macro(15,  37, '')     end,  
  _PoisonFiel                   = function()    UO.Macro(15,  38, '')     end,  
  _SummonCrea                   = function()    UO.Macro(15,  39, '')     end,  
  _Disp                         = function()    UO.Macro(15,  40, '')     end,  
  _EnergyBolt                   = function()    UO.Macro(15,  41, '')     end,  
  _Expl                         = function()    UO.Macro(15,  42, '')     end,  
  _Invi                         = function()    UO.Macro(15,  43, '')     end,  
  _Mark                         = function()    UO.Macro(15,  44, '')     end,  
  _MassCurse                    = function()    UO.Macro(15,  45, '')     end,  
  _ParalyzeFiel                 = function()    UO.Macro(15,  46, '')     end,  
  _Reve                         = function()    UO.Macro(15,  47, '')     end,  
  _ChainLigh                    = function()    UO.Macro(15,  48, '')     end,  
  _EnergyFiel                   = function()    UO.Macro(15,  49, '')     end,  
  _FlameStri                    = function()    UO.Macro(15,  50, '')     end,  
  _GateTrav                     = function()    UO.Macro(15,  51, '')     end,  
  _ManaVamp                     = function()    UO.Macro(15,  52, '')     end,  
  _MassDisp                     = function()    UO.Macro(15,  53, '')     end,  
  _MeteorSwar                   = function()    UO.Macro(15,  54, '')     end,  
  _Poly                         = function()    UO.Macro(15,  55, '')     end,  
  _Eart                         = function()    UO.Macro(15,  56, '')     end,  
  _EnergyVort                   = function()    UO.Macro(15,  57, '')     end,  
  _Resu                         = function()    UO.Macro(15,  58, '')     end,  
  _AirElem                      = function()    UO.Macro(15,  59, '')     end,  
  _SummonDaem                   = function()    UO.Macro(15,  60, '')     end,  
  _EarthElem                    = function()    UO.Macro(15,  61, '')     end,  
  _FireElem                     = function()    UO.Macro(15,  62, '')     end,  
  _WaterElem                    = function()    UO.Macro(15,  63, '')     end,  
  _AnimateDead                  = function()    UO.Macro(15, 101, '')     end,    
  _BloodOath                    = function()    UO.Macro(15, 102, '')     end,    
  _CorpseSkin                   = function()    UO.Macro(15, 103, '')     end,    
  _CurseWeap                    = function()    UO.Macro(15, 104, '')     end,    
  _EvilOmen                     = function()    UO.Macro(15, 105, '')     end,    
  _HorrificBeas                 = function()    UO.Macro(15, 106, '')     end,    
  _LichForm                     = function()    UO.Macro(15, 107, '')     end,    
  _MindRot                      = function()    UO.Macro(15, 108, '')     end,    
  _PainSpik                     = function()    UO.Macro(15, 109, '')     end,    
  _PoisonStri                   = function()    UO.Macro(15, 110, '')     end,    
  _Stra                         = function()    UO.Macro(15, 111, '')     end,    
  _SummonFami                   = function()    UO.Macro(15, 112, '')     end,    
  _VampiricEmbr                 = function()    UO.Macro(15, 113, '')     end,    
  _VengefulSpir                 = function()    UO.Macro(15, 114, '')     end,    
  _With                         = function()    UO.Macro(15, 115, '')     end,    
  _WraithForm                   = function()    UO.Macro(15, 116, '')     end,    
  _Exor                         = function()    UO.Macro(15, 117, '')     end,    
  _HonorableExec                = function()    UO.Macro(15, 145, '')     end,    
  _Conf                         = function()    UO.Macro(15, 146, '')     end,    
  _Evas                         = function()    UO.Macro(15, 147, '')     end,    
  _CounterAtta                  = function()    UO.Macro(15, 148, '')     end,    
  _LightningStrik               = function()    UO.Macro(15, 149, '')     end,    
  _MomentumStrik                = function()    UO.Macro(15, 150, '')     end,    
  _CleanseByFire                = function()    UO.Macro(15, 201, '')     end,    
  _CloseWoun                    = function()    UO.Macro(15, 202, '')     end,    
  _ConsecrateWeap               = function()    UO.Macro(15, 203, '')     end,    
  _DispelEvil                   = function()    UO.Macro(15, 204, '')     end,    
  _DivineFury                   = function()    UO.Macro(15, 205, '')     end,    
  _EnemyOfOne                   = function()    UO.Macro(15, 206, '')     end,    
  _HolyLigh                     = function()    UO.Macro(15, 207, '')     end,    
  _NobleSacr                    = function()    UO.Macro(15, 208, '')     end,    
  _RemoveCurs                   = function()    UO.Macro(15, 209, '')     end,    
  _SacredJour                   = function()    UO.Macro(15, 210, '')     end,    
  _FocusAtta                    = function()    UO.Macro(15, 245, '')     end,    
  _DeathStri                    = function()    UO.Macro(15, 246, '')     end,    
  _AnimalForm                   = function()    UO.Macro(15, 247, '')     end,    
  _KiAtta                       = function()    UO.Macro(15, 248, '')     end,    
  _SurpriseAtta                 = function()    UO.Macro(15, 249, '')     end,    
  _Back                         = function()    UO.Macro(15, 250, '')     end,    
  _Shad                         = function()    UO.Macro(15, 251, '')     end,    
  _MirrorImag                   = function()    UO.Macro(15, 252, '')     end,    
  _ArcaneCirc                   = function()    UO.Macro(15, 601, '')     end,    
  _GiftOfRene                   = function()    UO.Macro(15, 602, '')     end,    
  _ImmolatingWeap               = function()    UO.Macro(15, 603, '')     end,    
  _Attu                         = function()    UO.Macro(15, 604, '')     end,    
  _Thun                         = function()    UO.Macro(15, 605, '')     end,    
  _NaturesFury                  = function()    UO.Macro(15, 606, '')     end,    
  _SummonFey                    = function()    UO.Macro(15, 607, '')     end,    
  _SummonFien                   = function()    UO.Macro(15, 608, '')     end,    
  _ReaperForm                   = function()    UO.Macro(15, 609, '')     end,    
  _Wild                         = function()    UO.Macro(15, 610, '')     end,    
  _EssenceOfWind                = function()    UO.Macro(15, 611, '')     end,    
  _DryadAllu                    = function()    UO.Macro(15, 612, '')     end,    
  _EtherealVoya                 = function()    UO.Macro(15, 613, '')     end,    
  _WordOfDeat                   = function()    UO.Macro(15, 614, '')     end,    
  _GiftOfLife                   = function()    UO.Macro(15, 615, '')     end,    
  _ArcaneEmpo                   = function()    UO.Macro(15, 616, '')     end,    
  LSpell                        = function()    UO.Macro(16,   0, '')     end,  
  LObject                       = function()    UO.Macro(17,   0, '')     end,  
  --Bow                         = function()    UO.Macro(18,   0, '')     end,  
  --Salute                      = function()    UO.Macro(19,   0, '')     end,  
  --QuitGame                    = function()    UO.Macro(20,   0, '')     end,  
  --AllNames                    = function()    UO.Macro(21,   0, '')     end,  
  LTarget                       = function()    UO.Macro(22,   0, '')     end,  
  TargSelf                      = function()    UO.Macro(23,   0, '')     end,  
  ArmDisL                       = function()    UO.Macro(24,   1, '')     end,  
  ArmDisR                       = function()    UO.Macro(24,   2, '')     end,  
  WaitForTarg                   = function()    UO.Macro(25,   0, '')     end,  
  TargNex                       = function()    UO.Macro(26,   0, '')     end,  
  AttackL                       = function()    UO.Macro(27,   0, '')     end,  
  --Delay                       = function(x)   UO.Macro(28,   0, x or 1) end,  
  --CircleTrans                 = function()    UO.Macro(29,   0, '')     end,  
  CGumps                        = function()    UO.Macro(31,   0, '')     end,  
  --AlwaysRun                   = function()    UO.Macro(32,   0, '')     end,  
  --SaveDesktop                 = function()    UO.Macro(33,   0, '')     end,  
  --KillGumpOpen                = function()    UO.Macro(34,   0, '')     end,  
  Prim                          = function()    UO.Macro(35,   0, '')     end,  
  Seco                          = function()    UO.Macro(36,   0, '')     end,  
  --EquipLastWeapon             = function()    UO.Macro(37,   0, '')     end,  
  --SetUpdateRange              = function(x)   UO.Macro(38,   0, x or 1) end,  
  ModUpdRange                   = function(x)   UO.Macro(39,   0, x or 1) end,  
  IncUpdRange                   = function()    UO.Macro(40,   0, '')     end,  
  DecUpdRange                   = function()    UO.Macro(41,   0, '')     end,  
  MaxUpdRange                   = function()    UO.Macro(42,   0, '')     end,  
  MinUpdRange                   = function()    UO.Macro(43,   0, '')     end,  
  --DefaultUpdateRange          = function()    UO.Macro(44,   0, '')     end,  
  --UpdateUpdateRange           = function()    UO.Macro(45,   0, '')     end,  
  --EnableUpdateRangeColor      = function()    UO.Macro(46,   0, '')     end,  
  --DisableUpdateRangeColor     = function()    UO.Macro(47,   0, '')     end,  
  --ToggleUpdateRangeColor      = function()    UO.Macro(48,   0, '')     end,  
  IHono                         = function()    UO.Macro(49,   1, '')     end,  
  ISacr                         = function()    UO.Macro(49,   2, '')     end,  
  IValor                        = function()    UO.Macro(49,   3, '')     end,  
  IComp                         = function()    UO.Macro(49,   4, '')     end,  
  IJust                         = function()    UO.Macro(49,   7, '')     end,  
  SelNextHos                    = function()    UO.Macro(50,   1, '')     end,  
  SelNextPar                    = function()    UO.Macro(50,   2, '')     end,  
  SelNextFol                    = function()    UO.Macro(50,   3, '')     end,  
  SelNextObj                    = function()    UO.Macro(50,   4, '')     end,  
  SelNextMob                    = function()    UO.Macro(50,   5, '')     end,  
  SelPrevHos                    = function()    UO.Macro(51,   1, '')     end,  
  SelPrevPar                    = function()    UO.Macro(51,   2, '')     end,  
  SelPrevFol                    = function()    UO.Macro(51,   3, '')     end,  
  SelPrevObj                    = function()    UO.Macro(51,   4, '')     end,  
  SelPrevMob                    = function()    UO.Macro(51,   5, '')     end,  
  SelNearHos                    = function()    UO.Macro(52,   1, '')     end,  
  SelNearPar                    = function()    UO.Macro(52,   2, '')     end,  
  SelNearFol                    = function()    UO.Macro(52,   3, '')     end,  
  SelNearObj                    = function()    UO.Macro(52,   4, '')     end,  
  SelNearMob                    = function()    UO.Macro(52,   5, '')     end,  
  AttackSel                     = function()    UO.Macro(53,  '', '')     end,  
  USel                          = function()    UO.Macro(54,  '', '')     end,  
  CurTarg                       = function()    UO.Macro(55,  '', '')     end,  
  TargSysOnOff                  = function()    UO.Macro(56,  '', '')     end,  
  TogBuffWind                   = function()    UO.Macro(57,  '', '')     end,  
  BSelf                         = function()    UO.Macro(58,  '', '')     end,  
  BTarg                         = function()    UO.Macro(59,  '',' ')     end,
  
}, _macromt)


-------------------------------------------------------------------------------
-- scan -----------------------------------------------------------------------

-- an object scanning and manipulation (moving) library
-- TODO, read snicker's fluent object scanning interface first

-- scan arg patterns ----------------------------------------------------------

-- scan object ----------------------------------------------------------------
local _scan    = function(...)

  -- scan closure -------------------------------------------------------------
  return setmetatable({
    _type = 'interface:scan',

    },_facemt)
end

--[[
-- REDO THIS INTERFACE
-- object scanning collections
oscan     = newscan([contid1, contid2, ...])    -- scan all objects in listed containers ( or world if none specified)
          = oscan.count()                       -- number of objects in collection
          = oscan.foreach(ffunction)            -- calls ffunction with ti for each object in the collection
ti        = oscan.next(['reset'])               -- returns each object in collection in turn
ti        = oscan.sortby({opcode=arg1}[, ...])  -- set sorting.  opcodes type, rep, col, ...; arg1 is either 'asc' or 'des'
bres      = oscan.exclude({opcode=arg1}[, ...]) -- remove all object(s) matching any argument from oscan
            oscan.retain({opcode=arg1}[, ...])  -- remove all object(s) not matching at least one argument from oscan
                 .refresh
bool      = oscan.clear()                       -- clear scan, force garbage collection
          = oscan.move(ti|nid, ndestid|nil, namnt[, fcancelcheck] [, ngx, ngy, ngz]) -- see xferid / updates collection
            oscan:moveall(ndestid|nil, namnt[, fcancelcheck] [, ngx, ngy, ngz])

-- quick object scanning
bres[,ncontid|x,y,z]      = idpresent(nid[, ncontid, ...])       -- simple scan to tell if single item is present within
                                                                 -- specific (set of) container(s), or world if none specified
bres[,ncontid|namnt, ...] = typepresent(ntype, ncontid, ...)
bres, ...                 = idspresent(nid1, ... [, '|', ncontids, ...])
bamnt, ...                = typespresent(ntype1, ... [, '|', ncontids, ...])

-- counting objects
nres      = numberofstacks(ntype, sourceid1[, sourceid2, ...])
nres      = numberofstacks(ntype, oscan)
nres      = sumofstacks(ntype, sourceid1[, sourceid2, ...])
nres      = sumofstacks(ntype, oscan)

-- returned object table via oscsan:next
nid         = ti.id
--seuo        = ti.ideuo
ntype       = ti.type
--seuo        = ti.typeeuo
netc        = ti. ... -- dist, col, rep, ...

-- object helper functions

str, ...     = name(numorstr[, ...])          -- get default name(s) of type(s) ... need database
str, ...     = orename(ncol[, ...])           -- get ore name(s) from color(s)
str          = colname(ntype,ncol)            -- names of other things defined by color
sname,sdesc  = prop(nid|titem[,bsanitycheck]) -- get actual name and description for specific id or item table

-- move objects to container or ground
nres      = xferid(nid, ndestid|nil, namnt[, fcancelcheck] [, ngx, ngy, ngz])
nres      = xfertype(nsourceid, ntype, ndestid|nil, namnt[, fcancelcheck] [, ngx, ngy, ngz])
--]]

-------------------------------------------------------------------------------
-- spin -----------------------------------------------------------------------

-- spin arg patterns ----------------------------------------------------------
local _spinpattern =
  { name = 'spin',
    num = 2,
    req = 1,
    [1] = {lo=1, hi=1, rep = false, p='f',      [1]={}},  
    [2] = {lo=1, hi=4, rep = true,  p='frar',   [1]={}, [2]={}, [3]={}, [4]={}},  
  }
  
local _holdpattern =
  { name = 'spin.hold',
    num = 2,
    req = 0,
    [1] = {lo=1, hi=1, rep = false, p='a',      [1]={}},
    [2] = {lo=1, hi=4, rep = true,  p='arar',   [1]={}, [2]={}, [3]={}, [4]={}},
  }
  
local _tillpattern =
  { name = 'spin.till',
    num = 2,
    req = 1,
    [1] = {lo=1, hi=1, rep = false, p='n',      [1]={}},
    [2] = {lo=1, hi=2, rep = true,  p='nrar',   [1]={}, [2]={}, [3]={}, [4]={}},
  }
  
-- spin object ----------------------------------------------------------------
local _spin    = function(...)
  local a = self.iface.argval(_spinpattern,...)
  if a._status == ERR then 
    return __redir(a._eref)
  end
  
  -- build local state --------------------------------------------------------
  local expr  = a._argz[1]
  local funcs = {}
  local fnum  = 0
  local rate  = 100
  if a._cnt > 1 then
    for i = 2,a._cnt do
      local val = a._argz[i]
      if type(val) == 'nil' then val = null end
      table.insert(funcs, val)
      fnum = fnum + 1
    end
  end
 
  -- define local hold function -----------------------------------------------
  local _hold = function(...)
    local a = self.iface.argval(_holdpattern,...)
    if a._status == ERR then 
      return __redir(a._eref)
    end
    
    local elapsed, tbegin = 0,getticks()
    local t = false
    while t == false do
      local argset = {}
      if fnum > 0 then
        for i = 1,fnum do
          local val = nil
          if     type(funcs[i]) == 'function' then
            if a._cnt > 0 then
              val = funcs[i](unpack(a._argz))
            else
              val = funcs[i]()
            end
            if val == nil then val = null end
          elseif funcs[i] ~= nil              then
            val = funcs[i]
          else
            val = null
          end
          -- add first returned val to arglist
          table.insert(argset,val)
        end    -- end for
        if a._cnt > 0 then
          for i = 1,a._cnt do
            table.insert(argset,a._argz[i] or null)
          end
        end
        local v
        if #argset > 0 then
          v = expr(unpack(argset))
        else
          v = expr()
        end
        if v ~= nil then return v, elapsed end
      else
        if a._cnt > 0 then
          for i = 1,a._cnt do
            table.insert(argset,a._argz[i] or null)
          end
        end
        local v
        if a._cnt > 0 then
          v = expr(unpack(argset))
        else
          v = expr()
        end
        if v ~= nil then return v , elapsed end
      end      -- end if fnum > 0
      -- update elapsed time
      elapsed = getticks() - tbegin
      wait(rate)      
    end        -- end while
  end
  
  -- define local till function -----------------------------------------------
  local _till = function(...)
    local a = self.iface.argval(_tillpattern,...)
    if a._status == ERR then 
      return __redir(a._eref)
    end
    
    local elapsed, tbegin = 0,getticks()
    local t = false
    while t == false do
      local argset = {}
      if fnum > 0 then
        for i = 1,fnum do
          local val = nil
          if     type(funcs[i]) == 'function' then
            if a._cnt > 1 then
              val = funcs[i](unpack(a._argz,2))
            else
              val = funcs[i]()
            end
            if val == nil then val = null end
          elseif funcs[i] ~= nil              then
            val = funcs[i]
          else
            val = null
          end
          -- add first returned val to arglist
          table.insert(argset,val)
        end    -- end for
        if a._cnt > 1 then
          for i = 2,a._cnt do
            table.insert(argset,a._argz[i] or null)
          end
        end
        local v
        if #argset > 0 then
          v = expr(unpack(argset))
        else
          v = expr()
        end
        if v ~= nil then return v, elapsed end
      else
        if a._cnt > 1 then
          for i = 2,a._cnt do
            table.insert(argset,a._argz[i] or null)
          end
        end
        local v
        if a._cnt > 1 then
          v = expr(unpack(argset))
        else
          v = expr()
        end
        if v ~= nil then return v , elapsed end
      end      -- end if fnum > 0
      -- update elapsed time
      elapsed = getticks() - tbegin
      if elapsed >= a._argz[1] then return false, elapsed end
      wait(rate)      
    end        -- end while
  end
  
  -- spin closure -------------------------------------------------------------
  return setmetatable({
    _type = 'interface:spin',
    hold = function(...) return _hold(...) end,
    Hold = function(...) return _hold(...) end,
    HOLD = function(...) return _hold(...) end,
    till = function(...) return _till(...) end,
    Till = function(...) return _till(...) end,
    TILL = function(...) return _till(...) end,
    },_facemt)
end


-------------------------------------------------------------------------------
-- str ------------------------------------------------------------------------

-- str function parameters aren't validated by _argval ------------------------

-- str -- string functions table ----------------------------------------------
local _str = setmetatable(
{
  _type = 'interface:str',
  
  --- count number of occurences of s2 in s1 ----------------------------------
  -- optionally return all positions
  cnt = function(s1,s2,bsimple,bpos)
    if s1 == nil or type(s1) ~= 'string' or s2 == '' then return 0 end
    if s2 == nil or type(s2) ~= 'string' or s2 == '' then return 0 end
    local pos = {}
    local l1,l2,c,d,e = #s1,#s2,1,nil,nil
    if bsimple == nil then bsimple = true end
    while c <= l1 do
      d,e = string.find(s1,s2,c,bsimple)
      if d ~= nil then table.insert(pos,d) c = e end
      c = c + 1
    end
    
    if bpos ~= nil then
      return #pos, unpack(pos)
    else
      return #pos
    end    
  end,
  
  --- delete subsection beginning at n, m characters --------------------------
  del = function(s,n,m)
    if s == nil or type(s) ~= 'string' or s == '' then return '' end
    if type(n) ~= 'number' or type(m) ~= 'number' then return '' end
    local r,t
    if n < 2 then
      r = ''
    else
      r = string.sub(s,1,n - 1)
    end
    m = m+n
    t = string.sub(s,m,#s)    
    return r..t
  end,
  
  --- are supplied string arguments all equal at bit level --------------------
  eq = function(...)
    local a = {...}
    local c = select('#',...)
    if c < 2 then return nil end
    for i = 1,c do
      if type(a[i]) ~= 'string' then return nil end
    end
    local bad = false
    local k   = 0
    for i = 2,c do
      if #a[1] ~= #a[i] then bad = true k = i break end
      --for j = 1,#a[i] do
      --  if string.byte(a[1],j) ~=  string.byte(a[i],j) then bad = true k = i break end
      --end
      --if bad == true then break end
      if  a[1] ~=  a[i] then bad = true k = i break end
    end
    if bad == true then return false,k else return true,c end
  end,
  
  --- convert from a hex string to a regular string, --------------------------
  --  ignores intervening non-hex characters 
  fromhex = function(s)
    local out = ''
    local a,b,c,d = nil, nil, nil, nil
    if type(s) ~= 'string' then s = tostring(s) end
    if #s == 0 then return '' end
    s = string.lower(s)
    local f = {['0']=0, ['1']=1, ['2']=2, ['3']=3, ['4']=4, ['5']=5, ['6']=6, ['7']=7, ['8']=8,
               ['9']=9, ['a']=10,['b']=11,['c']=12,['d']=13,['e']=14,['f']=15}
    local i = 1
    --dbprint(#s)
    while i <= #s do
      d = string.sub(s,i,i)
      a = f[d]
      --dbprint(d..' '..tostring(a))
      if a ~= nil then
        if b == nil then
          b = a
        else
          c = a
          out = out .. string.char((b*16)+c)
          b = nil
          c = nil
        end
      end
      i = i + 1
    end
    return out
  end,
  
  --- is substring s2 found in s1 ---------------------------------------------
  --  if so, returns true, in which case 2nd return value is the position
  isin = function(s1,s2)
    if type(s1) ~= 'string' or type(s2) ~= 'string' then return nil end
    local i = string.find(s1,s2,1,true)
    if i == nil then return false, 0 end
    return true, i
  end,
  
  --- insert s2 into s1 at position n and return result -----------------------
  ins  = function(s1,s2,n)
    if type(s1) ~= 'string' or type(s2) ~= 'string' or type(n) ~= 'number' then return '' end
    
    local r,t
    if n < 1 then n = 1 end
    if n > #s1 then n = #s1 + 1 end
    if n < 2 then
      r = ''
    else
      r = string.sub(s1,1,n-1)
    end
    if n == #s1 + 1 then
      t = ''
    else
      t = string.sub(s1,n,#s1)
    end
    return r..s2..t
  end,
  
  --- join the string representation of all arguments into a single string ----
  join = function(...)
    local a = {...}
    local c = select('#',...)
    if c == 0 then return '' end
    if c == 1 then return tostring(a[1]), 1 end
    local out = ''
    for i = 1,c do
      out = out..tostring(a[i])
    end
    return out, c
  end,
  
  --- join with separator specified by the 1st argument, sep ------------------
  joinsep = function(sep,...)
    local a = {...}
    local c = select('#',...)
    sep = tostring(sep)
    if c == 0 then return '', 0 end
    if c == 1 then return tostring(a[1]), 1 end
    local out = ''
    for i = 1,c do
      out = out..tostring(a[i])
      if c < i then out = out..sep end
    end
    return out, c
  end,
  
  --- return left portion of s, of length n -----------------------------------
  left = function(s,n)
    if type(s) ~= 'string' or s == '' or type(n) ~= 'number' then return '' end
    local t = string.sub(s,1,n)
    return t  
  end,
  
  --- return length(s) of arguments (0 for any non-strings) -------------------
  len = function(...)
    local a = {...}
    local c = select('#',...)
    if c == 0 then return nil end
    local lens = {}
    for i = 1,c do
      local l
      if a[i] == nil or a[i] == null or type(a[i]) ~= 'string' then
        l = 0
      else
        l = #a[i]
      end
      table.insert(lens,l)
    end
    return unpack(lens)
  end,
  
  -- return lower case of s ---------------------------------------------------
  lower = function(...)
    local a = {...}
    local c = select('#', ...)
    if c == 0 then return nil end
    local out = {}
    for i = 1,c do
      local t = type(a[i])
      if     t == 'string' then                   out[i] = string.lower(a[i])
      elseif t == 'number' or t == 'boolean' then out[i] = string.lower(tostring(a[i]))
      else                                        out[i] = '' end
    end    
    return unpack(out)
  end,
  
  --- returns m characters of s, starting at position n -----------------------
  mid = function(s,n,m)
    if type(s) ~= 'string' or s == '' or type(n) ~= 'number' or type(m) ~='number' then return '' end
    local t = string.sub(s,n,n+m-1)
    return t 
  end,
  
  --- returns true iff s2 is not found in s1 ----------------------------------
  notin = function(s1,s2)
    if type(s1) ~= 'string' or type(s2) ~= 'string' then return nil end
    local i = string.find(s1,s2,1,true)
    if i == nil then return true end
    return false
  end,
  
  -- redundant with cnt
  --pos = function()
  --end,
  
  --- return the right portion of s, of length n ------------------------------
  right = function(s,n)
    if type(s) ~= 'string' or s == '' or type(n) ~= 'number' then return '' end
    local t = string.sub(s,-n)
    return t 
  end,
  
  --- split string into parts based upon a separator string -------------------
  sep  = function(sep,s,binline)
    if type(sep) ~= 'string' or type(s) ~= 'string' then
      if binline ~= nil then
        return ''
      else
        return {''}
      end
    end
    local out = {}
    local i,b,e = 1,0,0
    if #s <= 1 then
      if binline ~= nil then
        return s
      else
        return {s}
      end
    end
    
    -- boydon way
    while true do
      b,e = string.find(s,sep,i,true)
      if b ~= nil then
        table.insert(out,string.sub(s,i,b-1))
        i = b+#sep
      else
        table.insert(out,string.sub(s,i))
        break
      end
    end
    
    if binline ~= nil then
      return unpack(out)
    else
      return out
    end
  end,
  
  --- split string into parts,based upon given indices ------------------------
  split = function(s,...)
    local a = {...}
    local c = select('#',...)
    if type(s) ~= 'string' or s == '' then return {''} end
    if c == 0 or ( c == 1 and type(a[1]) ~= number) then return {s} end
    local out = {}
    local l = 0
    for i = 1,c do
      if type(a[i]) == 'number' then
        table.insert(out,string.sub(s,l,a[i]-1))
        l = a[i]
      else
        table.insert(out,'')
      end      
    end
      table.insert(out,string.sub(s,l))
    return out
  end,
  
  --- convert string into hexadecimal -----------------------------------------
  tohex = function(s)
    local out = ''
    if type(s) ~= 'string' then s = tostring(s) end
    local c = #s
    if c == 0 then return '' end
    local d,e
    local f = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
    for i = 1,c do
      d = string.byte(s,i)
      e = d % 16
      d = math.floor(d / 16)
      out = out .. f[d+1] .. f[e+1]
    end
    return out
  end,
  
  --- return upper case version of strings ------------------------------------
  upper = function(...)
    local a = {...}
    local c = select('#', ...)
    if c == 0 then return nil end
    local out = {}
    for i = 1,c do
      local t = type(a[i])
      if     t == 'string' then                   out[i] = string.upper(a[i])
      elseif t == 'number' or t == 'boolean' then out[i] = string.upper(tostring(a[i]))
      else                                        out[i] = '' end
    end    
    return unpack(out)
  end,

},_facemt)


-------------------------------------------------------------------------------
-- MISCELLANEOUS LIBRARY METHODS ----------------------------------------------
-------------------------------------------------------------------------------

-- miscellaneous methods at top level of library

-- miscellaneous method parameters mostly aren't validated by _argval ---------

-------------------------------------------------------------------------------
-- deepcopy a data table ------------------------------------------------------

-- recursive, may break with deeply nested or circular tables/metatables
-- obviously doesn't work with closure interface tables
-- http://lua-users.org/wiki/CopyTable

local _deepcopy = function(t)
  local ret,meta = {},{}
  if type(t) ~= 'table' then return t end
  meta = getmetatable(t)
  if meta ~= nil and type(meta) == 'table' then meta = self.iface.deepcopy(meta) end
  for k,v in pairs(t) do
    local typk,typv = type(k),type(v)
    local k0,v0 = {},{}
    if typk == 'table' and k ~= null then k0 = self.iface.deepcopy(k) else k0 = k end
    if typv == 'table' and v ~= null then v0 = self.iface.deepcopy(v) else v0 = v end
    ret[k0] = v0
  end
  if type(meta) ~= nil then return setmetatable(ret,meta) else return ret end
end

-------------------------------------------------------------------------------
-- output a string of table keys ----------------------------------------------
local _keystostring = function(t)
  if t == nil or type(t) ~= 'table' then return 'not a table' end
  local s = 'table keys = {\013\010'
  for k,v in pairs(t) do
    s = s..tostring(k)..',\013\010'
  end
  s = s..'}'
  return s  
end

-------------------------------------------------------------------------------
-- output a string of key value pairs -----------------------------------------
local _keyvalstring = function(t)
  if t == nil or type(t) ~= 'table' then return 'not a table' end
  local s = 'table keys:values = {\013\010'
  for k,v in pairs(t) do
    s = s..tostring(k)..':'..tostring(v)..',\013\010'
  end
  s = s..'}'
  return s  
end

local _exkeyvalstr = function(t)
  if t == nil or type(t) ~= 'table' then return 'not a table' end
  local s = 'table keys:values = {\013\010'
  for k,v in pairs(t) do
    if type(k) == 'table' then k = _keyvalstring(k) end
    if type(v) == 'table' then v = _keyvalstring(v) end
    s = s..tostring(k)..':'..tostring(v)..',\013\010'
  end
  s = s..'}'
  return s  
end

-------------------------------------------------------------------------------
-- output a table of keys -----------------------------------------------------
local _keys = function(t)
  if t == nil or type(t) ~= 'table' then return {} end
  local s = {}
  for k,v in pairs(t) do
    table.insert(s,k)  -- removed tostring wrapper around k in 0.08
  end
  return s  
end

-------------------------------------------------------------------------------
-- nil or null ----------------------------------------------------------------
local _non = function(...)
  local a = {...}
  local c = select('#',...)
  if c == 0 then return nil end
  local out = {}
  local b = false
  for i = 1,c do
    if a[i] == nil or a[i] == null then b = true else b = false end
    table.insert(out,b)
  end
  
  return unpack(out)
end

-------------------------------------------------------------------------------
-- table2lua ------------------------------------------------------------------
-- courtesy scryptor
local _tabletolua = function(t)
  if t == nil or type(t) ~= 'table' then return '' end
  local out = '{'
  for k,v in pairs(t) do
    out = out ..'['
    local  tk = type(k)
    if     tk == 'boolean' then out = out .. tostring(k) 
    elseif tk == 'number'  then out = out .. tostring(k)
    elseif tk == 'string'  then out = out .. string.format('%q',k)
    elseif tk == 'table'   then out = out .. self.iface.tabletolua(k)
    else
      out = out .. '"ERROR"'
    end
    out = out ..'] = '
    local  tv = type(v)
    if     tv == 'boolean' then out = out .. tostring(v) 
    elseif tv == 'number'  then out = out .. tostring(v)
    elseif tv == 'string'  then out = out .. string.format('%q',v)
    elseif tv == 'table'   then out = out .. self.iface.tabletolua(v)
    else
      out = out .. '"ERROR"'
    end  
    out = out .. ','
  end
  out = out .. '}'
  return out
end

-------------------------------------------------------------------------------
--- target --------------------------------------------------------------------

-- like easyuo target command, waits for UO.TargCurs true or times out
-- accepts alternative timeout in milliseconds
-- default timeout is 3 seconds
-- returns state of UO.TargCurs, time spent waiting
local _target = function(ms)
  local timeout
  if ms == nil then
    timeout = 3000
  elseif type(ms) ~= 'number' then
    if type(ms) == 'string' then
      local tn = tonumber(ms)
      if tn == nil then
        timeout = 3000
      else
        timeout = tn
      end
    else
      timeout = 3000
    end
  else
    timeout = ms
  end

  ms = getticks()
  timeout = timeout + ms
  while timeout > getticks() do
    if UO.TargCurs == true then break end
    wait(10)
  end
  
  return UO.TargCurs , getticks() - ms
end

-------------------------------------------------------------------------------
--- chosen --------------------------------------------------------------------

-- waits for transition from UO.TargCurs true to false, outputs
-- state, time, ltargetkind, [ltargetid | ltargettile,x,y,z]
-- times out in three sec unless overridden
local _select = function(ms)
  local timeout
  if ms == nil then
    timeout = 3000
  elseif type(ms) ~= 'number' then
    if type(ms) == 'string' then
      local tn = tonumber(ms)
      if tn == nil then
        timeout = 3000
      else
        timeout = tn
      end
    else
      timeout = 3000
    end
  else
    timeout = ms
  end

  ms = getticks()
  timeout = timeout + ms
  while timeout > getticks() do
    if UO.TargCurs ~= true then break end
    wait(10)
  end
  
  if getticks() >= timeout then
    UO.Key('ESC')
    wait(10)
    return UO.TargCurs, getticks() - ms, 4
  end
  
  if UO.LTargetKind == 1 then
    return UO.TargCurs , getticks() - ms, UO.LTargetKind, UO.LTargetID
  end
  
  return UO.TargCurs , getticks() - ms, UO.LTargetKind, UO.LTargetTile, UO.LTargetX, UO.LTargetY, UO.LTargetZ
end

-------------------------------------------------------------------------------
-- type/id conversion functions (courtesy Boydon) -----------------------------

-- String Explode for internal use --------------------------------------------
local __explode = function(delimiter, str)
   --print("sep: " .. delimiter)
   local tbl, i, j
   tbl={}
   i=0
   if(#str == 1) then return str end
   while true do
      j = string.find(str, delimiter, i+1, true) -- find the next d in the string
      if (j ~= nil) then -- if "not not" found then..
         table.insert(tbl, string.sub(str, i, j-1)) -- Save it in our array.
         i = j+1 -- save just after where we found it for searching next time.
      else
         table.insert(tbl, string.sub(str, i)) -- Save what's left in our array.
         break -- Break at end, as it should be, according to the lua manual.
      end
   end
   return tbl
end

-- From EasyUO to OpenEUO -----------------------------------------------------
local __easy2open = function (easyID)
   easyID = string.upper(easyID)
   local i, j, openID = 1, 0, 0 
   
   for j = 1, #easyID do
      local char = easyID:sub(j,j)
      openID = openID + ( string.byte(char) - string.byte('A') ) * i
      i = i * 26
   end
   openID = Bit.Xor((openID - 7), 69)
   
   return openID
end

-- Fron EasyUO String AAA_BBB_CCC to OpenEuo Table ----------------------------
local __estr2open = function (str)
   local easyIDs = {}
   local openIDs = {}
   
   easyIDs = __explode("_", str)
   for k, easyID in pairs(easyIDs) do
      table.insert(openIDs, __easy2open(easyID))
   end
   return openIDs
end

-- From OpenEUO to EasyUO -----------------------------------------------------
local __toeuo = function(openID)
   local easyID = ""
   local i = (Bit.Xor(openID, 69) + 7)

   while (i > 0) do
      easyID = easyID .. string.char((i % 26) + string.byte('A'))
      i = math.floor(i / 26)
   end
   return easyID
end

-- toeuo ----------------------------------------------------------------------
--local __toeuo = function(any)
--  return __open2easy(any)
-- end

-- fromeuo --------------------------------------------------------------------
local __fromeuo = function(any)
  local loc = string.find(any,'%a%_%a',1)
  if loc ~= nil then
    return __estr2open(any)
  else
    return __easy2open(any)
  end
end

-------------------------------------------------------------------------------
-- convert (autosense) --------------------------------------------------------
local _convert = function(any)
  if any == nil then return nil end
  if     type(any) == 'table' then
    local out = {}
    for k,v in pairs(any) do
      local a = {}
      if     type(v) == 'string'   then
        a = __fromeuo(v)
      elseif type(v) == 'number'   then
        a = __toeuo(v)
      elseif type(v) == 'table'    then
        a = _convert(v)
      elseif type(v) == 'function' then
        a = _convert(v())
      else
        a = nil
      end
      out[k] = a
    end
    return out
  elseif type(any) == 'string'   then
    return __fromeuo(any)
  elseif type(any) == 'number'   then
    return __toeuo(any)
  elseif type(any) == 'function' then
    return _convert(any())
  else
    return nil
  end
end

-------------------------------------------------------------------------------
-- import ---------------------------------------------------------------------

-- import public interface into _G environment --------------------------------
local _import = function(...)
local a = {...}
local cnt = select('#',...)

if cnt > 0 and a[1] ~= nil and type(a[1]) == 'string' then
  a[1] = string.lower(a[1])
  if string.find(a[1],'camel',1,true) then self.imported._camel = true end
  if string.find(a[1],'upper',1,true) then self.imported._upper = true end
  if string.find(a[1],'lower',1,true) then self.imported._lower = true end  
else
   self.imported._lower = true
end

if self.imported._lower == true then
  _G.argval      = self.pface.argval
  _G.case        = self.pface.case
  _G.chain       = self.pface.chain
  _G.clrerrors   = self.pface.clrerrors
  _G.convert     = self.pface.convert
  _G.deepcopy    = self.pface.deepcopy
  _G.deque       = self.pface.deque
  _G.file        = self.pface.file
  _G.geterror    = self.pface.geterror
  _G.slimport    = self.pface.slimport
  _G.iterator    = self.pface.iterator
  _G.journal     = self.pface.journal
  _G.keys        = self.pface.keys
  _G.keystr      = self.pface.keystr
  _G.keyvalstr   = self.pface.keyvalstr
  _G.linklist    = self.pface.linklist
  _G.luo         = self.pface.luo
  _G.machine     = self.pface.machine
  _G.macro       = self.pface.macro
  _G.non         = self.pface.non
  _G.probe       = self.pface.probe
  _G.slredirect  = self.pface.slredirect
  _G.spin        = self.pface.spin
  _G.str         = self.pface.str
  _G.tabletolua   = self.pface.tabletolua
  _G.target      = self.pface.target
  _G.try         = self.pface.try
  _G.slverbosity = self.pface.slverbosity
  _G.slversion   = self.pface.slversion
  _G.EOF         = self.pface.EOF
  _G.ERR         = self.pface.ERR
  _G.null        = self.pface.null
end

if self.imported._upper == true then
  _G.ARGVAL      = self.pface.argval
  _G.CASE        = self.pface.case
  _G.CHAIN       = self.pface.chain
  _G.CLRERRORS   = self.pface.clrerrors
  _G.CONVERT     = self.pface.convert
  _G.DEEPCOPY    = self.pface.deepcopy
  _G.DEQUE       = self.pface.deque
  _G.FILE        = self.pface.file
  _G.GETERROR    = self.pface.geterror
  _G.SLIMPORT    = self.pface.slimport
  _G.ITERATOR    = self.pface.iterator
  _G.JOURNAL     = self.pface.journal
  _G.LINKLIST    = self.pface.linklist
  _G.KEYS        = self.pface.keys
  _G.KEYSTR      = self.pface.keystr
  _G.KEYVALSTR   = self.pface.keyvalstr
  _G.LUO         = self.pface.luo
  _G.MACHINE     = self.pface.machine
  _G.MACRO       = self.pface.macro
  _G.NON         = self.pface.non
  _G.PROBE       = self.pface.probe
  _G.SLREDIRECT  = self.pface.slredirect
  _G.SPIN        = self.pface.spin
  _G.STR         = self.pface.str
  _G.TABLETOLUA   = self.pface.tabletolua
  _G.TARGET      = self.pface.target
  _G.TRY         = self.pface.try
  _G.SLVERBOSITY = self.pface.slverbosity
  _G.SLVERSION   = self.pface.slversion
  _G.EOF         = self.pface.EOF
  _G.ERR         = self.pface.ERR
  _G.null        = self.pface.null
end

if self.imported._camel == true then
  _G.ArgVal      = self.pface.argval
  _G.Case        = self.pface.case
  _G.Chain       = self.pface.chain
  _G.ClrErrors   = self.pface.clrerrors
  _G.Convert     = self.pface.convert
  _G.DeepCopy    = self.pface.deepcopy
  _G.Deque       = self.pface.deque
  _G.File        = self.pface.file
  _G.GetError    = self.pface.geterror
  _G.SLImport    = self.pface.slimport
  _G.Iterator    = self.pface.iterator
  _G.Journal     = self.pface.journal
  _G.Keys        = self.pface.keys
  _G.KeyStr      = self.pface.keystr
  _G.KeyValStr   = self.pface.keyvalstr
  _G.LinkList    = self.pface.linklist
  _G.Luo         = self.pface.luo
  _G.Machine     = self.pface.machine
  _G.Macro       = self.pface.macro
  _G.Non         = self.pface.non
  _G.Probe       = self.pface.probe
  _G.SLRedirect  = self.pface.slredirect
  _G.Spin        = self.pface.spin
  _G.Str         = self.pface.str
  _G.TableToLua   = self.pface.tabletolua
  _G.Target      = self.pface.target
  _G.Try         = self.pface.try
  _G.SLVerbosity = self.pface.slverbosity
  _G.SLVersion   = self.pface.slversion
  _G.EOF         = self.pface.EOF
  _G.ERR         = self.pface.ERR
  _G.null        = self.pface.null
end

self.imported._imported = true

end

-------------------------------------------------------------------------------
--CLOSURE - LIBRARY INTERFACE--------------------------------------------------
-------------------------------------------------------------------------------
  
-- public 'interface' of simplelib --------------------------------------------
-- wrapped with internal try handler  
local _pface = 
  {
  argval      = function(...) return self.iface.itry(_argval,    'argval',     ...) end, --
  case        = function(...) return self.iface.itry(_case,      'case',       ...) end, --
  chain       = function(...) return self.iface.itry(_chain,     'chain',      ...) end, --
  clrerrors   = function(...) return self.iface.itry(_clrerrors, 'clrerrors',  ...) end, --
  convert     = function(...) return self.iface.itry(_convert,   'convert',    ...) end, --
  deepcopy    = function(...) return self.iface.itry(_deepcopy,  'deepcopy',   ...) end, --
  deque       = function(...) return self.iface.itry(_deque,     'deque',      ...) end, --
  exkeyvalstr = _exkeyvalstr,
  file        = function(...) return self.iface.itry(_file,      'file',       ...) end, --
  geterror    = function(...) return self.iface.itry(_geterr,    'geterror',   ...) end, --
  slimport    = function(...) return self.iface.itry(_import,    'import',     ...) end, --
  iterator    = function(...) return self.iface.itry(_iterator,  'iterator',   ...) end, --
  journal     = function(...) return self.iface.itry(_journal,   'journal',    ...) end, --
  keymon      = function(...) return self.iface.itry(_keymon,    'keymon',     ...) end, --
  keys        = _keys,                                                                   --
  keystr      = _keystostring,                                                           --
  keyvalstr   = _keyvalstring,                                                           --
  luo         = _luo,                                                                    --
  linklist    = function(...) return self.iface.itry(_linklist,  'linklist',   ...) end, --
  machine     = function(...) return self.iface.itry(_machine,   'machine',    ...) end, --
  macro       = _macro,                                                                  --
  non         = _non,                                                                    --
  probe       = function(...) return self.iface.itry(_probe,     'probe',      ...) end, --
  chosen      = _select,
  slredirect  = function(...) return self.iface.itry(_redirect,  'redirect',   ...) end, --
  spin        = function(...) return self.iface.itry(_spin,      'spin',       ...) end, --
  str         = _str,                                                                    --
  tabletolua  = function(...) return self.iface.itry(_tabletolua,'tabletolua', ...) end, --
  target      = function(...) return self.iface.itry(_target,    'target',     ...) end, --
  try         = _ptry,                                                                   --
  slverbosity = function(...) return self.iface.itry(_verbosity, 'verbosity',  ...) end, --
  slversion   = function(...) return self.version                                   end, --
  }
  _pface['EOF']  = EOF
  _pface['ERR']  = ERR
  _pface['null'] = null
  
-- private 'interface' of simplelib -------------------------------------------
-- for use only from within the library itself.
local _iface =
  {
  argval       = _argval,       --
  case         = _case,         --
  chain        = _chain,        --
  clrerrors    = _clrerrors,    --
  closestmatch = _closestmatch, --
  convert      = _convert,      --
  deepcopy     = _deepcopy,     --
  deque        = _deque,        --
  exkeyvalstr  = _exkeyvalstr,
  file         = _file,         --
  geterror     = _geterr,       --
  getinfo      = _fgetinfo,     --
  iterator     = _iterator,     --
  itry         = _itry,         --
  journal      = _journal,      --
  keys         = _keys,         --
  keystr       = _keystr,       --
  keyvalstr    = _keyvalstr,    --
  linklist     = _linklist,     --
  logerr       = _logerr,       --
  luo          = _luo,          --
  machine      = _machine,      --
  non          = _non,          --  
  printerr     = _printerr,     --
  probe        = _probe,        --
  reporterr    = _reporterr,    --
  chosen       = _select,       --
  spin         = _spin,         --
  str          = _str,          --
  tabletolua   = _tabletolua,   --
  target       = _target,       --
  }
  
-- set sealed metatables, making the interfaces 'read only' -------------------
  setmetatable(_pface,_facemt)
  setmetatable(_iface,_facemt)
  
-- self can see interfaces, but not vice versa -------------------------------- 
self.pface = _pface
self.iface = _iface  -- mnemonic: i is for 'internal'
  
-------------------------------------------------------------------------------
--FINALIZE INITIALIZATION------------------------------------------------------
-------------------------------------------------------------------------------

-- this is sole name defined in the current/global environment
-- if defined then the library is already initialized
simple_lib_soliton__ = function(...)
  _G.simple_lib_soliton__ = simple_lib_soliton__
  return self.pface
end

-- return closure result as library object
return simple_lib_soliton__()


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--[[ credits:                                                              ]]--
--[[ 

                                   boydon
                                   brelix
                                   cheffe
                                   josephaj
                                   kal in ex
                                   scryptor
                                   snicker7
                                   stuby085
                                   swift74d
                                   warlocke
                                   ximan
                                   
                                   and all who
                                   contributed
                                   to the
                                   orginal
                                   codename
                                   alexandria

                                                                           ]]--
--[[                                                                       ]]--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- EOF
