-- Made by Vyshnia
-- Workshop ID: 2875394066
-- Mod ID: LuaTimers

local os_time = os.time
local table_insert = table.insert
local table_remove = table.remove
local assert = assert
local type = type
local pairs = pairs

timer = {
	Timers = {},
	SimpleTimers = {}
}

function timer:Simple(delay, func)

	assert(type(delay) == "number", "Delay of timer should be a number type")
	assert(type(func) == "function", "Func of timer should be a function type (lol)")

	table_insert(self.SimpleTimers, {
		EndTime = os_time() + delay,
		Func = func
	})

end

function timer:Create(name, delay, repetitions, func)
	
	assert(type(name) == "string", "ID of timer should be a string type")
	assert(type(delay) == "number", "Delay of timer should be a number type")
	assert(type(repetitions) == "number", "Repetitions of timer should be a number type")
	assert(type(func) == "function", "Func of timer should be a function type (lol)")
	
	self.Timers[name] = {
		Delay = delay,
		StartRepetitions = repetitions,
		Repetitions = repetitions,
		Infinity = repetitions == 0,
		LastFuncTime = os_time(),
		Func = func,
		Paused = false,
	}

end

local function timerUpdate()

	local cur_time = os_time()

	for k,v in pairs(timer.Timers) do

		if not v.Paused then
			
			if cur_time >= v.LastFuncTime + v.Delay then

				v.Func()

				v.LastFuncTime = cur_time

				if not v.Infinity then

					v.Repetitions = v.Repetitions - 1

					if v.Repetitions <= 0 then

						timer.Timers[k] = nil

					end

				end

			end

		end

	end

	local simple_timers = timer.SimpleTimers

	for i = #simple_timers, 1, -1 do

		local t = simple_timers[i]
		
		if t.EndTime <= cur_time then

			t.Func()

			table_remove(simple_timers, i)

		end

	end

end
Events.OnTickEvenPaused.Add(timerUpdate)
	
function timer:Remove(name)

	local t = self.Timers[name]

	if not t then return false end

	self.Timers[name] = nil

	return true

end

function timer:Exists(name)

	return self.Timers[name] and true or false

end

function timer:Start(name)

	local t = self.Timers[name]

	if not t then return false end

	t.Repetitions = t.StartRepetitions
	t.LastFuncTime = os_time()
	t.Paused = false
	t.PausedTime = nil

	return true

end

function timer:Pause(name)

	local t = self.Timers[name]

	if not t then return false end

	if t.Paused then return false end

	t.Paused = true
	t.PausedTime = os_time()

	return true

end

function timer:UnPause(name)

	local t = self.Timers[name]

	if not t then return false end

	if not t.Paused then return false end

	t.Paused = false

	return true

end
timer.Resume = timer.UnPause

function timer:Toggle(name)

	local t = self.Timers[name]

	if not t then return false end

	t.Paused = not t.Paused

	return true

end

function timer:TimeLeft(name)

	local t = self.Timers[name]

	if not t then return end

	if t.Paused then

		return (t.Repetitions - 1) * t.Delay + (t.LastFuncTime + t.Delay - t.PausedTime)

	else

		return (t.Repetitions - 1) * t.Delay + (t.LastFuncTime + t.Delay - os_time())

	end

end

function timer:NextTimeLeft(name)

	local t = self.Timers[name]

	if not t then return end

	if t.Paused then

		return t.LastFuncTime + t.Delay - t.PausedTime

	else

		return t.LastFuncTime + t.Delay - os_time()

	end

end

function timer:RepsLeft(name)

	local t = self.Timers[name]

	return t and t.Repetitions

end