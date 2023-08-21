
public protocol ActivitySub: Composition
    where
    StateType: ActivitySubState.Core,
    ActionType: ActivitySubAction.Core<StateType> { }
