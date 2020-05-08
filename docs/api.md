## StateMachine

### StateMachine.create
```
StateMachine.create(infoByState: {string: {...}}, initialState: string) => machine: Machine
```
Create and return a new state *Machine* based on the arguments passed.
*infoByState* should be a dictionary including the following key-value pairs:
* `entryAction?=(): (oldState: string, newState: string, ...args: any)`
* `exitAction?=(): (oldState: string, newState: string, ...args: any)`
* `stateByInput: {string: string}`

## Machine

### Machine.input
```
Machine.input(input, ...args: any) => didChange: boolean
```
Transition to the next state if the current state supports a transition with *input*, and pass *args* to the transition actions.

### Machine.disable
```
Machine.disable()
```
Disconnect all transition event connections, preparing the Machine for clean up and disabling its ability to change states.

### Machine.currentState
```
Machine.currentState: string
```

!!! note
	This property should be documented in more detail.

### Machine.isEnabled
```
Machine.isEnabled: boolean
```

!!! note
	This property should be documented in more detail.

### Machine.isChangingState
```
Machine.isChangingState: boolean
```

!!! note
	This property should be documented in more detail.

### Machine.stateChanged
```
Machine.stateChanged: RBXScriptSignal<oldState: string, newState: string, ...args: any>
```

!!! note
	This property should be documented in more detail.
