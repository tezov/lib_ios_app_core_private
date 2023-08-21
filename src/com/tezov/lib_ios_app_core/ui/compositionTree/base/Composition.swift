
public protocol Composition {
    associatedtype StateType: CompositionState.Core
    associatedtype ActionType: CompositionAction.Core<StateType>
}



