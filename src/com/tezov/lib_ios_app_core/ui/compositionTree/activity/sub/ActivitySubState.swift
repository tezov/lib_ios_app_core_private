// MARK: -
public enum ActivitySubState {
    public typealias Interface = _ActivitySubState_Interface
    public typealias Core = _ActivitySubState
}
// MARK: -

public protocol _ActivitySubState_Interface: CompositionState.Interface { }

public class _ActivitySubState : CompositionState.Core, ActivitySubState.Interface { }
