import lib_ios_core
import SwiftUI

// MARK: -

public enum ComposableNavigator {
    public typealias GraphEntry = _ComposableNavigator_GraphEntry
    internal typealias Interface = _ComposableNavigator_Protocol
    internal typealias Core = _ComposableNavigator
    public typealias Content = _ComposableNavigator_Content
}

// MARK: -

public extension NavHostCore.Graph.Builder {
    func navigation(
        route: NavigationRouteManager.Route,
        startRoute: NavigationRouteManager.Route,
        builder: (NavHostCore.Graph.Builder) -> Void
    ) {
        navigation(
            route: route.path,
            startDestination: startRoute.path,
            builder: builder
        )
    }
}

open class _ComposableNavigator_GraphEntry {
    //    var isForeground by Delegates.notNull<Boolean>()
    //    internal set
    //    var isTransitioning by Delegates.notNull<Boolean>()
    //    internal set

    init(entry _: NavHostCore.BackStackEntry) { }
}

internal protocol _ComposableNavigator_Protocol: NavHostCore.Navigator.Interface where Destination: ComposableNavigator.Content {
    func composePrepare(
        navHost: NavHostState,
        entry: NavHostCore.BackStackEntry
    )

    func updateCompletion(
        navHost: NavHostState,
        entry: NavHostCore.BackStackEntry
    )

    func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry
        
}

open class _ComposableNavigator<D:ComposableNavigator.Content>: NavHostCore.Navigator.Core<D>, ComposableNavigator.Interface {

    open func composePrepare(
        navHost _: NavHostState,
        entry _: NavHostCore.BackStackEntry
    ) { }

    open func updateCompletion(
        navHost _: NavHostState,
        entry _: NavHostCore.BackStackEntry
    ) { }

    public func completeIfRequested(
        entry _: NavHostCore.BackStackEntry
    ) { }

    public func compose(
        navHost _: NavHostState,
        entry _: NavHostCore.BackStackEntry
    ) { }

    open func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry {
        return ComposableNavigator.GraphEntry(entry: entry)
    }

    public override func navigate(entries: [NavHostCore.BackStackEntry], option: NavHostCore.Option?) {
        entries.forEach { state.pushWithTransitions($0) }
    }

    public override func popBackStack(
        popUpTo : NavHostCore.BackStackEntry,
        savedState : Bool
    ) { 
        popUpTo.content.clear()
        state.popWithTransition(popUpTo, savedState)
    }
}

open class _ComposableNavigator_Content: NavHostCore.Destination {
    let navigator: any ComposableNavigator.Interface // todo weak
    let animationConfig: NavigationAnimation.Config?
    let content: (ComposableNavigator.GraphEntry) -> any View

    internal init(
        route: String?,
        navigatorName: String,
        navigator: any ComposableNavigator.Interface,
        animationConfig: NavigationAnimation.Config?,
        content: @escaping (ComposableNavigator.GraphEntry) -> any View
    ) {
        self.navigator = navigator
        self.animationConfig = animationConfig
        self.content = content
        super.init(navigatorName: navigatorName, route: route)
    }
    
    var requestComplete: Bool = false
    var isVisible: Bool = false
    
    var backgroundId: String? = nil
    var foregroundId: String? = nil
    
    open func clear() {
        requestComplete = false
        isVisible = false
    }
    
}


extension NavHostCore.BackStackEntry {
    
    var content:ComposableNavigator.Content {
        self.destination as? ComposableNavigator.Content ?? {
           fatalError("destination is not a content")
        }()
    }
    
    var navigator:any ComposableNavigator.Interface {
        self.content.navigator
//        ?? {
//            fatalError("navigator can't be null")
//        }()
    }
    
}
