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

public protocol _ComposableNavigator_Protocol: NavHostCore.Navigator where Destination: ComposableNavigator.Content {
    func composePrepare(
        navHost: NavHost,
        entry: NavHostCore.BackStackEntry
    )

    func updateCompletion(
        navHost: NavHost,
        entry: NavHostCore.BackStackEntry
    )

    func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry
}

open class _ComposableNavigator: ComposableNavigator.Interface {
    public typealias Destination = ComposableNavigator.Content

    public var name: String {
        fatalError("ComposableNavigator.Core can't be instatiated or you forgot to override name in subclass")
    }

    open func composePrepare(
        navHost _: NavHost,
        entry _: NavHostCore.BackStackEntry
    ) { }

    open func updateCompletion(
        navHost _: NavHost,
        entry _: NavHostCore.BackStackEntry
    ) { }

    public func completeIfRequested(
        entry _: NavHostCore.BackStackEntry
    ) { }

    public func compose(
        navHost _: NavHost,
        entry _: NavHostCore.BackStackEntry
    ) { }

    open func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry {
        return ComposableNavigator.GraphEntry(entry: entry)
    }

    public func navigate(entries _: [NavHostCore.BackStackEntry], navOptions _: NavHostCore.Option) { }

    public func popBackStack(
        popUpTo _: NavHostCore.BackStackEntry,
        savedState _: Bool
    ) { }
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
}
