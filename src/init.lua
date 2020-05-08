--[[
	StateMachine is a module that provides an implementation of the finite-state machine model.
	For more information on finite-state machines and their uses: https://en.wikipedia.org/wiki/Finite-state_machine
	
	StateMachine.create(infoByState: {string: {...}}, initialState: string) => machine: Machine
		Create and return a new state machine based on the arguments passed.
		infoByState should be a dictionary including the following key-value pairs:
			entryAction?=(): (oldState: string, newState: string, ...args: any)
			exitAction?=(): (oldState: string, newState: string, ...args: any)
			stateByInput: {string: string}
	
	Machine.input(input: string, ...args: any) => didChange: boolean
		Transition to the next state if the current state supports a transition with input, and pass args to the transition actions.

	Machine.disable()
		Disconnect all transition event connections, preparing the machine for clean up and disabling its ability to change states.
	
	Machine.currentState: string
	
	Machine.isEnabled: boolean
	
	Machine.isChangingState: boolean
	
	Machine.stateChanged: RBXScriptSignal<oldState: string, newState: string, ...args: any>
--]]

local t = require(script.t)
local Reliable = require(script.Reliable)

local f = function() end


local StateMachine = {}

function StateMachine.create(infoByState, initialState)
	local machine = {}
	local connections = {}
	local newInfoByState = {}
	local stateChangedBindable = Instance.new("BindableEvent")
	local currentState = initialState
	-- register states
	for state, info in pairs(infoByState) do
		local newInfo = {}
		newInfo.entryAction = info.entryAction or f
		newInfo.exitAction = info.exitAction or f
		newInfo.stateByInput = info.stateByInput
		newInfoByState[state] = newInfo
	end
	-- construct methods
	function machine.disable()
		machine.isEnabled = false
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end
	function machine.input(input, ...)
		if machine.isChangingState then
			return false
		end
		local state = currentState
		local currentStateInfo = newInfoByState[state]
		local nextState = currentStateInfo.stateByInput[input]
		if nextState == nil then
			return false
		end
		machine.isChangingState = true
		Reliable.spawn(currentStateInfo.exitAction, state, nextState, ...)
		machine.currentState = nextState
		machine.isChangingState = false
		stateChangedBindable:Fire(state, nextState, ...)
		Reliable.spawn(newInfoByState[nextState].entryAction, state, nextState, ...)
		return true
	end
	machine.input = t.wrap(machine.input, t.tuple(t.string))
	-- assign members
	machine.currentState = currentState
	machine.stateChanged = stateChangedBindable.Event
	machine.isEnabled = true
	machine.isChangingState = false
	return machine
end
StateMachine.create = t.wrap(StateMachine.create, t.tuple(t.map(t.string, t.table), t.string))


return StateMachine
