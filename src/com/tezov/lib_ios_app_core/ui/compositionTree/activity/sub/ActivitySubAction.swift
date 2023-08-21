import lib_ios_core

// MARK: -
public enum ActivitySubAction {
    public typealias Interface = _ActivitySubAction_Interface
    public typealias Core = _ActivitySubAction
}
// MARK: -

fileprivate var _metaIdentifier = CompositionAction.Core.klassIdentifierCombine(ActivitySubAction.Core.self)

public protocol _ActivitySubAction_Interface : CompositionAction.Interface
where StateType: ActivitySubState.Core {
    
}

public class _ActivitySubAction<S:ActivitySubState.Core> : CompositionAction.Core<S>, ActivitySubAction.Interface {
    public typealias StateType = S
    
    override open class var klassIdentifiers: [ObjectIdentifier] { _metaIdentifier }
}
