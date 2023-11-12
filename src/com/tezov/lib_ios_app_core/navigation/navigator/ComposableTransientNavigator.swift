import lib_ios_core
import SwiftUI

// MARK: -

public enum ComposableTransientNavigator {
    typealias Core = _ComposableTransientNavigator
    typealias Content = _ComposableTransientNavigator_Content
}

// MARK: -

public extension NavHostCore.Graph.Builder {
    func composableTransient(
        route: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config? = nil,
        content: @escaping (ComposableNavigator.GraphEntry) -> any View
    ) {
        addDestination(destination:
            ComposableTransientNavigator.Content(
                route: route.path,
                navigator: getProvider(of: ComposableTransientNavigator.Core.self),
                animationConfig: animationConfig,
                content: content
            )
        )
    }
}

fileprivate let NAVIGATOR_NAME = "navigator_composable_transient"

class _ComposableTransientNavigator: ComposableNavigator.Core<ComposableTransientNavigator.Content> {

    public override var name: String { NAVIGATOR_NAME }
    
    override func composePrepare(navHost _: NavHostState, entry _: NavHostCore.BackStackEntry) { }

    override func updateCompletion(navHost _: NavHostState, entry _: NavHostCore.BackStackEntry) { }

    override func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry {
        return ComposableNavigator.GraphEntry(entry: entry)
    }
}

class _ComposableTransientNavigator_Content: ComposableNavigator.Content {
    init(
        route: String?,
        navigator: ComposableTransientNavigator.Core,
        animationConfig: NavigationAnimation.Config?,
        content: @escaping (ComposableNavigator.GraphEntry) -> any View
    ) {
        super.init(
            route: route,
            navigatorName: NAVIGATOR_NAME,
            navigator: navigator,
            animationConfig: animationConfig,
            content: content
        )
    }
}
