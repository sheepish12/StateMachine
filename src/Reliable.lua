--[[
	Reliable is a module that provides safe alternatives to Roblox's flawed wait and spawn functions.
	
	Reliable.spawn(callback: (...), ...args: any)
		Run callback in a new thread so that it does not yield the calling thread when it yields and pass args.
	
	Reliable.wait(n: number) => deltaTime: number // yields
		Yield the calling thread for n seconds and return the true amount of time waited.
	
	Motivation behind Reliable.spawn:
		spawn(f) should not be used because it yields for at least 0.03 seconds before execution of its passed callback,
		but is known to yield an unexpectedly long amount of time under heavy use (and in some cases never gets around to running its passed callback whatsoever).
		coroutines.wrap(f)() should not be used because it removes the stack trace of any errors that may occur prior to a Roblox yield in its passed callback.
		coroutine.resume(coroutine.create(f)) should not be used because it silences any errors that may occur prior to a Roblox yield in its passed callback.
		Reliable.spawn's implementation avoids all of these issues.
	
	Motivation behind Reliable.wait:
		wait(n) should not be used because waits are resumed at a fixed (and slow) rate of 0.03 seconds,
		when, in good condition, machines can reach up to 60Hz with RunService members.
		wait(n) is also known to yield an unexpectedly long amount of time under heavy use (and in some cases never gets around to resuming whatsoever).
		Reliable.wait's implementation avoids all of these issues.
--]]

local RunService = game:GetService("RunService")
local t = require(script.Parent.t)


local Reliable = {}

function Reliable.spawn(callback, ...)
	local bindable = Instance.new("BindableEvent")
	local arguments = table.pack(...)
	bindable.Event:Connect(function()
		callback(table.unpack(arguments, 1, arguments.n))
	end)
	bindable:Fire()
	bindable:Destroy()
end
Reliable.spawn = t.wrap(Reliable.spawn, t.callback)

function Reliable.wait(n)
	local targetT = tick()+n
	repeat
		RunService.Heartbeat:Wait()
	until tick() >= targetT
	return n + (tick()-targetT)
end
Reliable.wait = t.wrap(Reliable.wait, t.number)


return Reliable
