import lib_ios_core

// MARK: -
public enum BottomNavigationAction {
    public typealias Interface = _BottomNavigationAction_Interface
    public typealias Core = _BottomNavigationAction
}
// MARK: -

fileprivate var _metaIdentifier = ActivitySubAction.Core.klassIdentifierCombine(BottomNavigationAction.Core.self)

public protocol _BottomNavigationAction_Interface : ActivitySubAction.Interface
where StateType: BottomNavigationState.Core {
    
}

public class _BottomNavigationAction<S:BottomNavigationState.Core> : ActivitySubAction.Core<S>, BottomNavigationAction.Interface {
    
    override open class var klassIdentifiers: [ObjectIdentifier] { _metaIdentifier }
    
}
