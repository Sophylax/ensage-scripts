--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __         
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\ 
 0 1 1 0 1 1 0 0             /_/        /___/             
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0    

				Hotkey Configuration Library v1.2

		Save as: HotkeyConfig.lua into Ensage\Scripts\libs.

		Allows you to create in-game menus.

		All settings done by the user, either the changing of the key or the value is saved and perserved until the script's file name is changed.

		Functions:
			ScriptConfig:AddParam
			ScriptConfig:SetName

		Values:
			ScriptConfig.NameOfTheParameters

		Available parameter types:
			SGC_TYPE_ONKEYDOWN		--		Returns true/false
			SGC_TYPE_TOGGLE			--		Returns true/false
			SGC_TYPE_NUMCYCLE		--		Returns selected number
			SGC_TYPE_CYCLE			--		Returns selected index

		Usage:
			ScriptConfig:SetName("Testing With Parameters")
				This will set the name of the in-game menu as "Testing With Parameters".
				Name is the filename of the script by default.

			ScriptConfig:AddParam("TestP1", "Test Param 1", SCRIPT_PARAM_ONKEYDOWN, true false, 32)
				This will create a parameter called "TestP1", it will be displayed as "Test Param 1". 
				SGC_TYPE_ONKEYDOWN means it will be true when the key is pressed. 
				true means it will always be shown at the upper left corner with it's value.
				false means it's disabled by default.
				32 is the key code.

			ScriptConfig:AddParam("TestP2", "Test Param 2", SGC_TYPE_TOGGLE, false, false, 32)
				This will create a parameter called "TestP2", it will be displayed as "Test Param 2". 
				SGC_TYPE_TOGGLE means you can toggle it on or off with the in-game menu or with a key. 
				false means it will not be shown at the upper left corner.
				false means it's disabled by default.
				32 is the key code.

			ScriptConfig:AddParam("TestP3", "Test Param 3", SGC_TYPE_NUMCYCLE, true, 5, nil, 5, 105, 10)
				This will create a parameter called "TestP3", it will be displayed as "Test Param 3". 
				SGC_TYPE_NUMCYCLE is used for allowing users to iterate through a list of numbers. 
				true means it will always be shown at the upper left corner with it's value.
				If the keycode is nil then it means that this parameter can't be used with a key.
				5 is the default value, 0 is min value, 100 is max value, 10 is step. 
				This example would start at 5, pressing the key would loop through 5-15-25-35-45-55-65-75-85-95-105 then return back to 5.

			ScriptConfig:AddParam("TestP4", "Test Param 4", SGC_TYPE_CYCLE, 5, 84, {"one","two","three","four","five","six","seven","eight","nine","ten"})
				This will create a parameter called "TestP4", it will be displayed as "Test Param 4". 
				SGC_TYPE_CYCLE allows you to create the same behaviour as NUMERICUPDOWN but with any kind of value. 
				84 is key code.
				5 is default index, finally the table of value. This example would start at index 5 and would display "five" to the user. 
				Pressing the key would iterate as "six"-"seven"-"eight"-"nine"-"ten"-"one" etc. 
				The param holds the index of the selected value, so if the user has selected six...ScriptConfig.TestP6 == 6.

		Example Script:
			require("libs.HotkeyConfig")

			function Tick()
				if ScriptConfig.TestP1 then Move(engineClient.mousePosition) end
				if ScriptConfig.TestP2 then print("I turned on TestP3!") end
			end

			ScriptConfig = ConfigGUI:New(script.name)

			ScriptConfig:SetName("Test Script Config")
			ScriptConfig:AddParam("TestP1", "Test Param 1", SGC_TYPE_ONKEYDOWN, true, false, 32)
			ScriptConfig:AddParam("TestP2", "Test Param 2", SGC_TYPE_TOGGLE, true, false, string.byte("A"))
			ScriptConfig:AddParam("TestNumSpin", "Test Number Spin", SGC_TYPE_NUMCYCLE, false, 5, nil, 0, 200, 10)
			ScriptConfig:AddParam("TestStrSpin", "Test String Spin", SGC_TYPE_CYCLE, false, 5, 84, {"one","two","three","four","five","six","seven","eight","nine","ten"})

			script:RegisterEvent(EVENT_TICK, Tick)

		Changelog:
			v1.2:
			 - Reworked the GUI obj to have bind itself to events on create
			 - Scripts now have to create their own ScriptConfig objs with "ScriptConfig = ConfigGUI:New(script.name)"
			 - Now the values are correctly aligned to the right side of the box.

			v1.1a:
			 - Fixed a rare bug when it tries to hide a config with no keys bound to a parameter

			v1.1:
			 - Fixed a bug when it tries to save config with no keys bound to a parameter
			 - Added RightClick input for SGC_TYPE_NUMCYCLE and SGC_TYPE_CYCLE parameters which will make them cycle bacwards

			v1.0:
			 - Release
]]

--== SETTINGS ==--

font = drawManager:CreateFont("11", "Arial", 14, 500)

TOP_MARGIN = 60
SIDE_MARGIN = 10
BUTTON_W = 100
BUTTON_H = 15
FONT_SIZE = 14
BG_COLOR = 0x000000AF
HL_COLOR = 0xFFFFFF3F	
TEXT_COLOR = 0xFFFFFFFF
BORDER_COLOR = 0xFFFFFF10

--==GLOBALS==--
SGC_TYPE_ONKEYDOWN = 1
SGC_TYPE_TOGGLE = 2
SGC_TYPE_NUMCYCLE = 3
SGC_TYPE_CYCLE = 4
CFG_FILE = SCRIPT_PATH.."scripts.cfg"
CURRENT_FILE = "_currentscripts.cfg"
UPDATE_CYCLE = 1000

--==SCRIPT CONFIGURATION GUI CLASS==--
ConfigGUI = {}
dupcheck = false

function ConfigGUI:New(name)

	obj = {}

	obj._settings = {id = name , name = name , showCount = 0 , menuOpen = false, mR = 0, sR = 0, sleep = 0, keyChange = nil, visible = true, visuals = {}, extention = 0}
	obj._cfg = {}

	--Returns the start line and the end line of the script according to the line table
	function obj:FindStartEnd(lines)
		--local lines = ReadLines(CFG_FILE)
		local s,e = nil,nil
		local found = {false,false}

		for i,v in ipairs(lines) do
			if not found[1] and v == "["..self._settings.id.."]" then
				s = i
				found[1] = true
			elseif found[1] and not found[2] and v:sub(1,1) == "[" then
				e = i
				found[2] = true
			end
		end

		if found[1] and not found[2] then
			e = #lines
		end

		if found[1] then
			return s,e
		else
			return nil
		end
	end

	--Returns the row of the Settings button should be from the scripts table
	function obj:FindMainRow(_scripts)
		local _found = false
		local _row = 0

		if not _scripts and self._settings.mR then
			return self._settings.mR
		elseif not _scripts then
			return 0
		end

		for i,v in ipairs(_scripts) do
			local name, count = split(v,":")[1]
			if not _found and name ~= self._settings.id then
				_row = _row + 1
			else
				_found = true
				break
			end
		end

		if not _found and self._settings.visible then
			table.insert(_scripts,self._settings.id..":"..self._settings.showCount)
			WriteLines(CURRENT_FILE,_scripts)
		end

		if self._settings.mR ~= _row then
			self:SyncMainRow(_row - self._settings.mR)
			self._settings.mR = _row
		end
	end

	--Returns the row of the first button that are shown all the time supposed to be from the scripts table
	function obj:FindShowRow(_scripts)
		local _found = false
		local _row = 0

		if not _scripts and self._settings.sR then
			return self._settings.sR
		elseif not _scripts then
			return 0
		end

		for i,v in ipairs(_scripts) do
			local _table = split(v,":")
			local name, count = _table[1],_table[2]
			if not _found and name ~= self._settings.id then
				_row = _row + count
			else
				_found = true
				break
			end
		end

		if not _found and self._settings.visible then
			table.insert(_scripts,self._settings.id..":"..self._settings.showCount)
			WriteLines(CURRENT_FILE,_scripts)
		end

		if self._settings.sR ~= _row then
			self:SyncShowRow(_row - self._settings.sR)
			self._settings.sR = _row
		end
	end

	--Returns the index of a parameter in the _cfg table from the name of the parameter
	function obj:FindParamIndex(_id)
		for i,v in ipairs(self._cfg) do
			if v.id == _id then
				return i
			end
		end
	end

	--Sets the visual name of the settings button
	function obj:SetName(string)
		self._settings.name = string
		self._settings.visuals.main.text:SetText(self._settings.name)
	end

	--Sets the visual name of the settings button
	function obj:SetVisible(bool)
		if bool ~= self._settings.visible then
			self._settings.visible = bool
			self._settings.visuals.main.inside.visible = bool
			self._settings.visuals.main.border.visible = bool
			self._settings.visuals.main.text.visible = bool
			for i,v in ipairs(self._cfg) do
				if self._settings.menuOpen and self._settings.visuals.button[v.id] then
					self._settings.visuals.button[v.id].bg1.visible = bool
					self._settings.visuals.button[v.id].bg2.visible = bool
					self._settings.visuals.button[v.id].bg3.visible = bool
					self._settings.visuals.button[v.id].border.visible = bool
					self._settings.visuals.button[v.id].name.visible = bool
					self._settings.visuals.button[v.id].value.visible = bool
					if self._settings.visuals.button[v.id].key then
						self._settings.visuals.button[v.id].key.visible = bool
					end
				end
				if v.show and self._settings.visuals.permaShow[v.id].name then
					self._settings.visuals.permaShow[v.id].inside.visible = bool
					self._settings.visuals.permaShow[v.id].border.visible = bool
					self._settings.visuals.permaShow[v.id].name.visible = bool
					self._settings.visuals.permaShow[v.id].value.visible = bool
				end
			end
		end
	end

	--Sets the visual name of the settings button
	function obj:SetExtention(number)
		self._settings.extention = number
	end

	--Updates the CURRENT_FILE with the information of self
	function obj:UpdateCurrent()
		local lines = ReadLines(CURRENT_FILE)
		local changed = false
		local found = false

		for i,line in ipairs(lines) do
			local _table = split(line,":")
			local name, count = _table[1],_table[1]
			if name == self._settings.id then
				found = true
				if count.."" ~= self._settings.showCount.."" then
					lines[i] = name..":"..self._settings.showCount
					changed = true
				end
			end
		end

		if not found then
			table.insert(lines,self._settings.id..":"..self._settings.showCount)
			changed = true
		end

		if changed then
			WriteLines(CURRENT_FILE,lines)
		end
	end

	--Key Function of parameters, does things to do when mouse clicked/key pressed
	function obj:ParamKey(index,msg,code)
		local success = false
		if self._cfg[index].type == SGC_TYPE_ONKEYDOWN then
			if tonumber(self._cfg[index].key) == tonumber(code) then
				self[self._cfg[index].id] = (msg == KEY_DOWN)
				success = true
			end
		elseif self._cfg[index].type == SGC_TYPE_TOGGLE then
			if tonumber(self._cfg[index].key) == tonumber(code) then
				if (self._cfg[index].last == KEY_UP or self._cfg[index].last == nil) and (msg == KEY_DOWN or msg == RBUTTON_DOWN) then
					self[self._cfg[index].id] = not self[self._cfg[index].id]
				success = true
					self:SaveCfg()
				end
				self._cfg[index].last = msg
			elseif (msg == LBUTTON_DOWN or msg == RBUTTON_DOWN) then
				self[self._cfg[index].id] = not self[self._cfg[index].id]
				success = true
				self:SaveCfg()
			end
		elseif self._cfg[index].type == SGC_TYPE_CYCLE then
			if tonumber(self._cfg[index].key) == tonumber(code) then
				if (self._cfg[index].last == KEY_UP or self._cfg[index].last == nil) and (msg == KEY_DOWN or msg == RBUTTON_DOWN) then
					if msg == RBUTTON_DOWN then
						self[self._cfg[index].id] = (self[self._cfg[index].id])%#self._cfg[index].table - 1
					else
						self[self._cfg[index].id] = (self[self._cfg[index].id])%#self._cfg[index].table + 1
					end
				success = true
					self:SaveCfg()
				end
				self._cfg[index].last = msg
			elseif (msg == LBUTTON_DOWN or msg == RBUTTON_DOWN) then
				if msg == RBUTTON_DOWN then
					self[self._cfg[index].id] = (self[self._cfg[index].id])%#self._cfg[index].table - 1
				else
					self[self._cfg[index].id] = (self[self._cfg[index].id])%#self._cfg[index].table + 1
				end
				success = true
				self:SaveCfg()
			end
		elseif self._cfg[index].type == SGC_TYPE_NUMCYCLE then
			if tonumber(self._cfg[index].key) == tonumber(code) then
				if (self._cfg[index].last == KEY_UP or self._cfg[index].last == nil) and (msg == KEY_DOWN or msg == RBUTTON_DOWN) then
					local newNum = self[self._cfg[index].id]
					if msg == RBUTTON_DOWN then
						newNum = newNum - self._cfg[index].step
					else
						newNum = newNum + self._cfg[index].step
					end
					if newNum < self._cfg[index].min then
						newNum = self._cfg[index].max
					elseif newNum > self._cfg[index].max then
						newNum = self._cfg[index].min
					end
					self[self._cfg[index].id] = newNum
					success = true
					self:SaveCfg()
				end
				self._cfg[index].last = msg
			elseif (msg == LBUTTON_DOWN or msg == RBUTTON_DOWN) then
				local newNum = self[self._cfg[index].id]
				if msg == RBUTTON_DOWN then
					newNum = newNum - self._cfg[index].step
				else
					newNum = newNum + self._cfg[index].step
				end
				if newNum < self._cfg[index].min then
					newNum = self._cfg[index].max
				elseif newNum > self._cfg[index].max then
					newNum = self._cfg[index].min
				end
				self[self._cfg[index].id] = newNum
				success = true
				self:SaveCfg()
			end
		end
		if success then
			self:UpdateLabel(index)
			return true
		end		
	end

	function obj:UpdateLabel(index)
		local x_change = 0
		if self._settings.menuOpen and self._settings.visuals.button[self._cfg[index].id] then
			if type(self[self._cfg[index].id]) == "boolean" then
				if self[self._cfg[index].id] then
					self._settings.visuals.button[self._cfg[index].id].value.color = 0x009300FF
					if self._settings.visuals.button[self._cfg[index].id].value.text == "OFF" then
						x_change = FONT_SIZE/3
						self._settings.visuals.button[self._cfg[index].id].value:SetPosition(self._settings.visuals.button[self._cfg[index].id].value.x + x_change,self._settings.visuals.button[self._cfg[index].id].value.y)
					end
					self._settings.visuals.button[self._cfg[index].id].value:SetText("ON")
				else
					self._settings.visuals.button[self._cfg[index].id].value.color = 0x930000FF
					if self._settings.visuals.button[self._cfg[index].id].value.text == "ON" then
						x_change = -FONT_SIZE/3
						self._settings.visuals.button[self._cfg[index].id].value:SetPosition(self._settings.visuals.button[self._cfg[index].id].value.x + x_change,self._settings.visuals.button[self._cfg[index].id].value.y)
					end
					self._settings.visuals.button[self._cfg[index].id].value:SetText("OFF")
				end
			elseif self._cfg[index].table then
				x_change = drawManager:GetTextSize(self._settings.visuals.button[self._cfg[index].id].value.text,FONT_SIZE)[1] - drawManager:GetTextSize(self._cfg[index].table[tonumber(self[self._cfg[index].id])],FONT_SIZE)[1]
				self._settings.visuals.button[self._cfg[index].id].value:SetPosition(self._settings.visuals.button[self._cfg[index].id].value.x + x_change,self._settings.visuals.button[self._cfg[index].id].value.y)
				self._settings.visuals.button[self._cfg[index].id].value:SetText(self._cfg[index].table[tonumber(self[self._cfg[index].id])])
			else
				x_change = drawManager:GetTextSize(self._settings.visuals.button[self._cfg[index].id].value.text,FONT_SIZE)[1] - drawManager:GetTextSize(tostring(self[self._cfg[index].id]),FONT_SIZE)[1]
				self._settings.visuals.button[self._cfg[index].id].value:SetPosition(self._settings.visuals.button[self._cfg[index].id].value.x + x_change,self._settings.visuals.button[self._cfg[index].id].value.y)
				self._settings.visuals.button[self._cfg[index].id].value:SetText(tostring(self[self._cfg[index].id]))
			end
			if self._settings.visuals.permaShow[self._cfg[index].id] then
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetText(self._settings.visuals.button[self._cfg[index].id].value.text)
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetPosition(self._settings.visuals.permaShow[self._cfg[index].id].value.x + x_change,self._settings.visuals.permaShow[self._cfg[index].id].value.y)
				self._settings.visuals.permaShow[self._cfg[index].id].value.color = self._settings.visuals.button[self._cfg[index].id].value.color
			end
		elseif self._settings.visuals.permaShow[self._cfg[index].id] then
			if type(self[self._cfg[index].id]) == "boolean" then
				if self[self._cfg[index].id] then
					self._settings.visuals.permaShow[self._cfg[index].id].value.color = 0x009300FF
					if self._settings.visuals.permaShow[self._cfg[index].id].value.text == "OFF" then
						x_change = FONT_SIZE/3
						self._settings.visuals.permaShow[self._cfg[index].id].value:SetPosition(self._settings.visuals.permaShow[self._cfg[index].id].value.x + x_change,self._settings.visuals.permaShow[self._cfg[index].id].value.y)
					end
					self._settings.visuals.permaShow[self._cfg[index].id].value:SetText("ON")
				else
					self._settings.visuals.permaShow[self._cfg[index].id].value.color = 0x930000FF
					if self._settings.visuals.permaShow[self._cfg[index].id].value.text == "ON" then
						x_change = -FONT_SIZE/3
						self._settings.visuals.permaShow[self._cfg[index].id].value:SetPosition(self._settings.visuals.permaShow[self._cfg[index].id].value.x + x_change,self._settings.visuals.permaShow[self._cfg[index].id].value.y)
					end
					self._settings.visuals.permaShow[self._cfg[index].id].value:SetText("OFF")
				end
			elseif self._cfg[index].table then
				x_change = drawManager:GetTextSize(self._settings.visuals.permaShow[self._cfg[index].id].value.text,FONT_SIZE)[1] - drawManager:GetTextSize(self._cfg[index].table[tonumber(self[self._cfg[index].id])],FONT_SIZE)[1]
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetPosition(self._settings.visuals.permaShow[self._cfg[index].id].value.x + x_change,self._settings.visuals.permaShow[self._cfg[index].id].value.y)
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetText(self._cfg[index].table[tonumber(self[self._cfg[index].id])])
			else
				x_change = drawManager:GetTextSize(self._settings.visuals.permaShow[self._cfg[index].id].value.text,FONT_SIZE)[1] - drawManager:GetTextSize(tostring(self[self._cfg[index].id]),FONT_SIZE)[1]
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetPosition(self._settings.visuals.permaShow[self._cfg[index].id].value.x + x_change,self._settings.visuals.permaShow[self._cfg[index].id].value.y)
				self._settings.visuals.permaShow[self._cfg[index].id].value:SetText(tostring(self[self._cfg[index].id]))
			end
		end
	end

	function obj:SyncMainRow(delta)
		self:LowerObject(self._settings.visuals.main.inside,delta*BUTTON_H)
		self:LowerObject(self._settings.visuals.main.border,delta*BUTTON_H)
		self:LowerObject(self._settings.visuals.main.text,delta*BUTTON_H)
		if self._settings.menuOpen then
			for i,v in ipairs(self._cfg) do
				if self._settings.visuals.button[v.id].name then
					self:LowerObject(self._settings.visuals.button[v.id].bg1,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].bg2,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].bg3,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].border,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].name,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].value,delta*BUTTON_H)
					self:LowerObject(self._settings.visuals.button[v.id].key,delta*BUTTON_H)
				end
			end
		end
	end

	function obj:SyncShowRow(delta)
		for i,v in ipairs(self._cfg) do
			if v.show and self._settings.visuals.permaShow[v.id].name then
				self:LowerObject(self._settings.visuals.permaShow[v.id].inside,delta*BUTTON_H)
				self:LowerObject(self._settings.visuals.permaShow[v.id].border,delta*BUTTON_H)
				self:LowerObject(self._settings.visuals.permaShow[v.id].name,delta*BUTTON_H)
				self:LowerObject(self._settings.visuals.permaShow[v.id].value,delta*BUTTON_H)
			end
		end
	end

	function obj:LowerObject(drawObj,_y)
		if drawObj then
			if drawObj.w then
				drawObj:SetPosition(drawObj.x,drawObj.y + _y,drawObj.w,drawObj.h)
			else
				drawObj:SetPosition(drawObj.x,drawObj.y + _y)
			end
		end
	end

	--Overwrite existing configuration in the CFG_FILE with the ones in the memory
	function obj:SaveCfg()
		local lines = ReadLines(CFG_FILE)
		local s,e = self:FindStartEnd(lines)

		if not s or not e then
			table.insert(lines,"["..self._settings.id.."]")
			for i,v in ipairs(self._cfg) do
				if type(self[v.id]) == "boolean" then
					if self[v.id] then
						table.insert(lines,v.id.."=true;key="..tostring(v.key))
					else
						table.insert(lines,v.id.."=false;key="..tostring(v.key))
					end
				else
					table.insert(lines,v.id.."="..self[v.id]..";key="..tostring(v.key))
				end
			end
		else
			local minicfg = {}
			for i,v in ipairs(self._cfg) do
				minicfg[i] = {i = v.id, v = self[v.id], k = v.key}
			end

			for i=s+1,e do
				local id = split(lines[i],"=")[1]
				local _index = self:FindParamIndex(id)
				if _index and self[id] ~= nil and minicfg[_index] then
					if type(self[id]) == "boolean" or self._cfg[_index].type == SGC_TYPE_ONKEYDOWN then
						if minicfg[_index].v and self._cfg[_index].type ~= SGC_TYPE_ONKEYDOWN then
							lines[i] = minicfg[_index].i.."=true;key="..tostring(minicfg[_index].k)
						else
							lines[i] = minicfg[_index].i.."=false;key="..tostring(minicfg[_index].k)
						end
					else
						lines[i] = minicfg[_index].i.."="..self[id]..";key="..tostring(minicfg[_index].k)
					end
					minicfg[_index] = nil
				end
			end

			for k,l in pairs(minicfg) do
				if type(l.v) == "boolean" then
					if l.v then
						table.insert(lines,e,l.i.."=true;key="..tostring(l.k))
					else
						table.insert(lines,e,l.i.."=false;key="..tostring(l.k))
					end
				else
					table.insert(lines,e,l.i.."="..l.v..";key="..tostring(l.k))
				end
			end
		end

		WriteLines(CFG_FILE, lines)
	end

	--Overwrite the configuration in the memory with the ones in the CFG_FILE
	function obj:LoadCfg()
		local lines = ReadLines(CFG_FILE)
		local s,e = self:FindStartEnd(lines)

		if s and e then
			for i=s+1,e do
				local _table = split(lines[i],";")
				local vString, kString = _table[1],_table[2]
				if vString and kString then
					local _t = split(vString,"=")
					local _ta = split(kString,"=")
					local id,value = _t[1],_t[2]
					local __,keyCode = _ta[1],_ta[2]
					local _index = self:FindParamIndex(id)
					if _index then
						if value == "true" then
							self[id] = true
						elseif value == "false" then
							self[id] = false
						else
							self[id] = value
						end
						if keyCode == "nil" then
							self._cfg[_index].key = nil
						else
							self._cfg[_index].key = tonumber(keyCode)
						end
						self:UpdateLabel(_index)
					end
				end
			end
		end
	end

	function obj:OpenMenu(state)
		if not self._settings.menuOpen and state then
			for i,v in ipairs(self._cfg) do
				local mainRow = self._settings.mR
				if not mainRow then
					mainRow = 0
				end
				local visibility = self._settings.visible
				self._settings.visuals.button[v.id] = {}
				self._settings.visuals.button[v.id].bg1 = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + (3+self._settings.extention)*BUTTON_W),TOP_MARGIN + (mainRow+i-1)*BUTTON_H,5*BUTTON_W/6,BUTTON_H,BG_COLOR)
				self._settings.visuals.button[v.id].bg1.visible = visibility
				self._settings.visuals.button[v.id].bg2 = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + (13+self._settings.extention*6)*BUTTON_W/6),TOP_MARGIN + (mainRow+i-1)*BUTTON_H,BUTTON_W/2,BUTTON_H,BG_COLOR)
				self._settings.visuals.button[v.id].bg2.visible = visibility
				self._settings.visuals.button[v.id].bg3 = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + (5+self._settings.extention*3)*BUTTON_W/3),TOP_MARGIN + (mainRow+i-1)*BUTTON_H,(2*BUTTON_W/3)+self._settings.extention*BUTTON_W,BUTTON_H,BG_COLOR)
				self._settings.visuals.button[v.id].bg3.visible = visibility
				self._settings.visuals.button[v.id].border = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + (3+self._settings.extention)*BUTTON_W),TOP_MARGIN + (mainRow+i-1)*BUTTON_H,(2+self._settings.extention)*BUTTON_W,BUTTON_H,BORDER_COLOR,true)
				self._settings.visuals.button[v.id].border.visible = visibility
				self._settings.visuals.button[v.id].name = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + (3+self._settings.extention)*BUTTON_W) + 2,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,v.name..":")
				self._settings.visuals.button[v.id].name.visible = visibility
				--if ScriptConfig._settings.keyChange == i then
				--	self._settings.visuals.button[v.id].key = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + 2*BUTTON_W) - 5,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,"ASSIGN A KEY")
				if v.key then
					self._settings.visuals.button[v.id].key = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + (2+self._settings.extention)*BUTTON_W) - 5,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,KeytoString(v.key))
					self._settings.visuals.button[v.id].key.visible = visibility
				end
				if type(self[v.id]) == "boolean" then
					if self[v.id] then
						self._settings.visuals.button[v.id].value = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W)- 2*FONT_SIZE/3 - 7,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,0x009300FF,"ON")
					else
						self._settings.visuals.button[v.id].value = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W) - FONT_SIZE - 7,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,0x930000FF,"OFF")
					end
				elseif v.table then
					self._settings.visuals.button[v.id].value = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W) - drawManager:GetTextSize(tostring(v.table[tonumber(self[v.id])]),FONT_SIZE)[1] - 2,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,v.table[tonumber(self[v.id])])
				else
					self._settings.visuals.button[v.id].value = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W) - drawManager:GetTextSize(tostring(self[v.id]),FONT_SIZE)[1] - 2,TOP_MARGIN + (mainRow+i-1)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,tostring(self[v.id]))
				end
				self._settings.visuals.button[v.id].value.visible = visibility
			end
		elseif self._settings.menuOpen and not state then
			for i,v in ipairs(self._cfg) do
				self._settings.visuals.button[v.id].bg1:Destroy()
				self._settings.visuals.button[v.id].bg1 = nil
				self._settings.visuals.button[v.id].bg2:Destroy()
				self._settings.visuals.button[v.id].bg2 = nil
				self._settings.visuals.button[v.id].bg3:Destroy()
				self._settings.visuals.button[v.id].bg3 = nil
				self._settings.visuals.button[v.id].border:Destroy()
				self._settings.visuals.button[v.id].border = nil
				self._settings.visuals.button[v.id].name:Destroy()
				self._settings.visuals.button[v.id].name = nil
				if self._settings.visuals.button[v.id].key then
					self._settings.visuals.button[v.id].key:Destroy()
					self._settings.visuals.button[v.id].key = nil
				end
				self._settings.visuals.button[v.id].value:Destroy()
				self._settings.visuals.button[v.id].value = nil
			end
		end
		self._settings.menuOpen = state
	end

	function obj:Highlight(drawObj)
		if drawObj.color == BG_COLOR and IsMouseOnButton(drawObj.x,drawObj.y,drawObj.h,drawObj.w) then
			drawObj.color = HL_COLOR
		elseif drawObj.color == HL_COLOR and not IsMouseOnButton(drawObj.x,drawObj.y,drawObj.h,drawObj.w) then
			drawObj.color = BG_COLOR
		end
	end

	function obj:HighlightTick()
		self:Highlight(self._settings.visuals.main.inside)
		for i,v in ipairs(self._cfg) do
			if self._settings.menuOpen then
				if v.key then
					self:Highlight(self._settings.visuals.button[v.id].bg2)
				end
				if v.type ~= SGC_TYPE_ONKEYDOWN then
					self:Highlight(self._settings.visuals.button[v.id].bg3)
				end
			end
		end
	end

	--Adds a parameter to the settings
	function obj:AddParam(pId,pName,pType,pShow,pValue,pKey,_a,_b,_c)
		assert(type(pId) == "string" and type(pName) == "string" and type(pType) == "number" and type(pShow) == "boolean", "Can't Add Parameter: wrong argument types (<string>, <string>, <pType>, <boolean> expected)")
	    assert(string.find(pId,"[^%a%d]") == nil, "Can't Add Parameter:: Id should contain only char and number")
	    assert(self[pId] == nil, "Can't Add Parameter: Id should be unique, already existing "..pId)
    	local newParam = {id = pId, name = pName, type = pType, key = pKey, show = pShow}

    	if pType == SGC_TYPE_TOGGLE or pType == SGC_TYPE_ONKEYDOWN then
    		assert(type(pValue) == "boolean", "Can't Add Parameter: Wrong default value. <boolean> expected.")
    		if pType == SGC_TYPE_ONKEYDOWN then
    			newParam.last = nil
    		end
    	elseif pType == SGC_TYPE_NUMCYCLE then
	        assert(type(pValue) == "number" and type(_a) == "number" and type(_b) == "number" and type(_c) == "number", "Can't Add Parameter: Wrong argument type(s) for default value, minimum value, maximum value or step. <number> expected.")
	        newParam.min = _a
	        newParam.max = _b
	        newParam.step = _c
        elseif pType == SGC_TYPE_CYCLE then
			assert(type(pValue) == "number", "Can't Add Parameter: Wrong argument type for defualt value. <number> expected.")
			assert(type(_a) == "table", "Can't Add Parameter: Wrong argument type for value table. <table> expected.")
			newParam.table = _a
	    end

		self[pId] = pValue
		table.insert(self._cfg, newParam)

	    if pShow == true then
	    	local showRow = self._settings.showCount
	    	if not showRow then
				showRow = 0
			end
	    	local startRow = self._settings.sR
	    	local visibility = self._settings.visible
	    	self._settings.visuals.permaShow[pId] = {}
	    	self._settings.visuals.permaShow[pId].inside = drawManager:CreateRect(SIDE_MARGIN,TOP_MARGIN + (showRow + startRow)*BUTTON_H,3*BUTTON_W/2+self._settings.extention*BUTTON_W,BUTTON_H,BG_COLOR)
	    	self._settings.visuals.permaShow[pId].inside.visible = visibility
			self._settings.visuals.permaShow[pId].border = drawManager:CreateRect(SIDE_MARGIN,TOP_MARGIN + (showRow + startRow)*BUTTON_H,3*BUTTON_W/2+self._settings.extention*BUTTON_W,BUTTON_H,BORDER_COLOR,true)
			self._settings.visuals.permaShow[pId].border.visible = visibility
			self._settings.visuals.permaShow[pId].name = drawManager:CreateText(SIDE_MARGIN + 2,TOP_MARGIN + (showRow + startRow)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,pName..":")
			self._settings.visuals.permaShow[pId].name.visible = visibility
			if type(self[newParam.id]) == "boolean" then
				if self[newParam.id] then
					self._settings.visuals.permaShow[pId].value = drawManager:CreateText(SIDE_MARGIN + self._settings.extention*BUTTON_W + 3*BUTTON_W/2 - 2*FONT_SIZE/3 - 7,TOP_MARGIN + (showRow + startRow)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,0x009300FF,"ON")
				else
					self._settings.visuals.permaShow[pId].value = drawManager:CreateText(SIDE_MARGIN + self._settings.extention*BUTTON_W + 3*BUTTON_W/2 - FONT_SIZE - 7,TOP_MARGIN + (showRow + startRow)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,0x930000FF,"OFF")
				end
			elseif newParam.table then
				self._settings.visuals.permaShow[pId].value = drawManager:CreateText(SIDE_MARGIN + self._settings.extention*BUTTON_W + 3*BUTTON_W/2 - drawManager:GetTextSize(tostring(newParam.table[tonumber(self[newParam.id])]),FONT_SIZE)[1] - 2,TOP_MARGIN + (showRow + startRow)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,newParam.table[tonumber(self[newParam.id])])
			else
				self._settings.visuals.permaShow[pId].value = drawManager:CreateText(SIDE_MARGIN + self._settings.extention*BUTTON_W + 3*BUTTON_W/2 - drawManager:GetTextSize(tostring(self[newParam.id]),FONT_SIZE)[1] - 2,TOP_MARGIN + (showRow + startRow)*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,tostring(self[newParam.id]))
			end
			self._settings.visuals.permaShow[pId].value.visible = visibility
	    	self._settings.showCount = self._settings.showCount + 1
	    end

		self:LoadCfg()
		self:SaveCfg()
		self:UpdateCurrent()
	end

	function obj:Init()
		local mainRow = self._settings.mR
		if not mainRow then
			mainRow = 0
		end
		local visibility = self._settings.visible
		self._settings.visuals.main = {}
		self._settings.visuals.permaShow = {}
		self._settings.visuals.button = {}
		self._settings.visuals.main.inside = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W),TOP_MARGIN + mainRow*BUTTON_H,BUTTON_W,BUTTON_H,BG_COLOR)
		self._settings.visuals.main.inside.visible = visibility
		self._settings.visuals.main.border = drawManager:CreateRect(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W),TOP_MARGIN + mainRow*BUTTON_H,BUTTON_W,BUTTON_H,BORDER_COLOR,true)
		self._settings.visuals.main.border.visible = visibility
		self._settings.visuals.main.text = drawManager:CreateText(drawManager.screenWidth - (SIDE_MARGIN + BUTTON_W) + 2,TOP_MARGIN + mainRow*BUTTON_H + (BUTTON_H - FONT_SIZE)/2,TEXT_COLOR,self._settings.name,font)
		self._settings.visuals.main.text.visible = visibility
	end

	function obj:Refresh(tick)

		self:HighlightTick()

		if GetTick() > self._settings.sleep then
			local _scripts = ReadLines(CURRENT_FILE)
			local _dirty = false

			if _scripts then
				local found = false
				for i,line in ipairs(_scripts) do
					local _table = split(line,":")
					local name, count = _table[1],_table[2]
					if (name == self._settings.id and found) or not scriptEngine:IsLoaded(name) or (not _G[name:sub(0,-5)].ScriptConfig._settings.visible) then
						_scripts[i] = nil
						_dirty = true
					end
					if name == self._settings.id then
						found = true
					end
				end

				if _dirty then
					WriteLines(CURRENT_FILE, _scripts)
				end
			end

			self:FindMainRow(_scripts)
			self:FindShowRow(_scripts)
			self._settings.sleep = GetTick() + UPDATE_CYCLE
		end
	end

	function obj:Key(msg,code)
		if not self._settings.visible then return end
			dupcheck = not dupcheck
			if dupcheck then return end
			if IsChatOpen() then return end
			if self._settings.keyChange then
				if msg == KEY_DOWN then
					self._cfg[self._settings.keyChange].key = code
					self._settings.visuals.button[self._cfg[self._settings.keyChange].id].key:SetText(KeytoString(code))
					self._settings.keyChange = nil
					self:SaveCfg()
					return
				end
			elseif msg == LBUTTON_DOWN or msg == RBUTTON_DOWN then
				if not self._settings.menuOpen then
					local mainRow = self._settings.mR
					if mainRow and IsMouseOnRect(self._settings.visuals.main.inside) then
						self:OpenMenu(true)
					end
				else
					local mainRow = self._settings.mR
					local match = false
					for i,v in ipairs(self._cfg) do
						if v.key and IsMouseOnRect(self._settings.visuals.button[v.id].bg2) then
							self._settings.keyChange = i
							self._settings.visuals.button[v.id].key:SetText("ASSIGN A KEY")
							match = true
						elseif v.type ~= SGC_TYPE_ONKEYDOWN and IsMouseOnRect(self._settings.visuals.button[v.id].bg3) then
							match = true
							local re = self:ParamKey(i,msg,code)
							return re
						end
					end
					if not match then
						self:OpenMenu(false)
						self._settings.menuOpen = false
					end
				end
			elseif self._settings.keyChange == nil then
				for i,v in ipairs(self._cfg) do
					self:ParamKey(i,msg,code)
				end
			end
		end

	globj = obj
	globj:Init()

	script:RegisterEvent(EVENT_KEY, globj.Key, globj)
	script:RegisterEvent(EVENT_TICK, globj.Refresh, globj)
	return globj
end

--Returns a table of lines in the file
function ReadLines(sPath)
  local file = io.open(sPath, "r")
  if file then
        local tLines = {}
        for line in file:lines() do
			table.insert(tLines, line)
        end
        file.close()
        return tLines
  	else
  		WriteLines(sPath,{})
  		return {}
  	end
end

--Writes to a file line by line according to the table
function WriteLines(sPath, tLines)
  local file = io.open(sPath, "w")
  if file then
  		local text = ""
  		local lastline = nil
        for _, sLine in ipairs(tLines) do
			text = text..sLine.."\n"
        end
        file:write(text)
        file:close()
	end
end

--Returns a table of splitted string
function split(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--Returns true if mouse is on given rectangle
function IsMouseOnButton(x,y,h,w)
	mx = engineClient.mouseScreenPosition[1]
	my = engineClient.mouseScreenPosition[2]
	return mx > x and mx <= x + w and my > y and my <= y + h
end
	
function IsMouseOnRect(drawObj)
	return IsMouseOnButton(drawObj.x,drawObj.y,drawObj.h,drawObj.w)
end
	

--Returns a string of the key
function KeytoString(key)
    return (tonumber(key) > 32 and tonumber(key) < 96 and "  "..string.char(key).." " or "("..tostring(key)..")")
end