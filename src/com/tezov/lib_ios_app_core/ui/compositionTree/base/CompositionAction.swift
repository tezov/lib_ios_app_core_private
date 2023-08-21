import lib_ios_core

// MARK: -
public enum CompositionAction {
    public typealias Interface = _CompositionAction_Interface
    public typealias Core = _CompositionAction
}
// MARK: -

fileprivate var _metaIdentifier = [ObjectIdentifier(CompositionAction.self)]

public protocol _CompositionAction_Interface : KlassIdentifiable {
    associatedtype StateType : CompositionState.Core
}

public class _CompositionAction<S:CompositionState.Core> : CompositionAction.Interface {
    public typealias StateType = S

    open class var klassIdentifiers: [ObjectIdentifier] { _metaIdentifier }
}
