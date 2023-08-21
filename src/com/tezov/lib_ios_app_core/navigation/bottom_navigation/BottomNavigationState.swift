// MARK: -
public enum BottomNavigationState {
    public typealias Interface = _BottomNavigationState_Interface
    public typealias Core = _BottomNavigationState
}
// MARK: -

public protocol _BottomNavigationState_Interface: ActivitySubState.Interface { }

public class _BottomNavigationState : ActivitySubState.Core, BottomNavigationState.Interface { }
