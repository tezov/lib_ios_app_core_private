import lib_ios_core
import SwiftUI

// MARK: -

public enum ComposableOverlayNavigator {
    typealias Core = _ComposableOverlayNavigator
    typealias Content = _ComposableOverlayNavigator_Content
}

// MARK: -

public extension NavHostCore.Graph.Builder {
    func composableOverlay(
        route: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config? = nil,
        content: @escaping (ComposableNavigator.GraphEntry) -> any View
    ) {
        addDestination(destination:
            ComposableOverlayNavigator.Content(
                route: route.path,
                navigator: getProvider(of: ComposableOverlayNavigator.Core.self),
                animationConfig: animationConfig,
                content: content
            )
        )
    }
}

fileprivate let NAVIGATOR_NAME = "navigator_composable_overlay"

class _ComposableOverlayNavigator: ComposableNavigator.Core {
    typealias Destination = ComposableOverlayNavigator.Content

    public override var name: String { NAVIGATOR_NAME }
    
    override func composePrepare(navHost _: NavHost, entry _: NavHostCore.BackStackEntry) { }

    override func updateCompletion(navHost _: NavHost, entry _: NavHostCore.BackStackEntry) { }

    override func createGraphEntry(entry: NavHostCore.BackStackEntry) -> ComposableNavigator.GraphEntry {
        return ComposableNavigator.GraphEntry(entry: entry)
    }
}

class _ComposableOverlayNavigator_Content: ComposableNavigator.Content {
    init(
        route: String?,
        navigator: ComposableOverlayNavigator.Core,
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
