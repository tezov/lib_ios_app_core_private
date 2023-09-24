import Foundation
import lib_ios_core
import SwiftUI

// MARK: -

public enum NavHostCore {
    public typealias Navigator = _NavHostCore_Navigator
    public typealias Controller = _NavHostCore_Controller
    public typealias Graph = _NavHostCore_Graph
    public typealias Destination = _NavHostCore_Destination
    public typealias BackStackEntry = _NavHostCore_BackStackEntry
    public typealias Option = _NavHostCore_Option
}

public extension NavHostCore.Graph {
    typealias Builder = _NavHostCore_Graph_Builder
}

// MARK: -

public protocol _NavHostCore_Navigator {
    associatedtype Destination: NavHostCore.Destination

    var name: String { get }

    func navigate(
        entries: [NavHostCore.BackStackEntry],
        navOptions: NavHostCore.Option
    )

    func popBackStack(
        popUpTo: NavHostCore.BackStackEntry,
        savedState: Bool
    )
}

public class _NavHostCore_Controller: ObservableObject {
    private var currentGraphNode: NavHostCore.Graph!
    var graph: NavHostCore.Graph? = nil {
        willSet {
            precondition(graph == nil, "graph is already setted")
            precondition(newValue != nil, "graph can't be set to nil")
        }
        didSet {
            if let _graph = graph {
                let (graph, destination) = _graph.resolveStartDestination()
                currentGraphNode = graph
                let entry = NavHostCore.BackStackEntry(destination: destination)
                _backQueue.append(entry)
            }
        }
    }

    private var _backQueue: [NavHostCore.BackStackEntry]
    private(set) var providers: [TypeIdentity: any NavHostCore.Navigator]

    var currentBackStack: [NavHostCore.BackStackEntry] { _backQueue }
    private(set) var visibleEntries: [NavHostCore.BackStackEntry] = []

    public init(providers: [TypeIdentity: any NavHostCore.Navigator] = [:]) {
        self._backQueue = []
        var _providers: [TypeIdentity: any NavHostCore.Navigator] = [
            TypeIdentity(ComposableTransientNavigator.Core.self): ComposableTransientNavigator.Core(),
            TypeIdentity(ComposableOverlayNavigator.Core.self): ComposableOverlayNavigator.Core(),
        ]
        providers.forEach { key, value in
            _providers[key] = value
        }
        self.providers = _providers
    }

    var currentBackStackEntry: NavHostCore.BackStackEntry? { _backQueue.last }

    var previousBackStackEntry: NavHostCore.BackStackEntry? {
        if _backQueue.count <= 1 { return nil }
        return _backQueue[_backQueue.count - 2]
    }

    func navigate(route: String, option: NavHostCore.Option? = nil) {
        guard graph != nil else { fatalError("graph is nil, you forgot to set it inside NavHost View") }
        guard let (newNode, destination) = currentGraphNode.resolve(route: route)
        else { fatalError("invalid navigate request from \(currentBackStackEntry?.destination.route ?? "root") to \(route)") }
        if let option {
            if option.clearStack {
                _backQueue.removeAll()
            }
            if option.singleTop {
                _backQueue.removeAll { entry in
                    entry.destination.route == route
                }
            }
            if let popUpToRoute = option.popUpToRoute {
                if var indexOfPopUpToRoute = (_backQueue.lastIndex { entry in
                    entry.destination.route == popUpToRoute
                }) {
                    if !option.popUpInclusive {
                        indexOfPopUpToRoute += 1
                    }
                    _backQueue = Array(_backQueue[0..<indexOfPopUpToRoute])
                }
            }
        }
        currentGraphNode = newNode
        let entry = NavHostCore.BackStackEntry(destination: destination)
        
        _backQueue.append(entry)
        objectWillChange.send()
    }

    func popBackStack() {
        _backQueue.removeLast()
    }
}

public class _NavHostCore_Graph {
    private var parent: NavHostCore.Graph?
    private var childs: [NavHostCore.Graph]
    private var route: String?
    private var startDestination: String
    private var destinations: [NavHostCore.Destination]

    init(
        parent: NavHostCore.Graph? = nil,
        route: String? = nil,
        startDestination: String
    ) {
        self.parent = parent
        self.childs = []
        self.route = route
        self.startDestination = startDestination
        self.destinations = []
    }

    func append(destination: NavHostCore.Destination) {
        destinations.append(destination)
    }

    func append(child: NavHostCore.Graph) {
        childs.append(child)
    }

    fileprivate func resolveStartDestination() -> (node: NavHostCore.Graph, destination: NavHostCore.Destination) {
        return resolve(route: startDestination) ?? {
            fatalError("start destination not found \(startDestination)")
        }()
    }

    private func firstDestination(route: String, graph: NavHostCore.Graph) -> NavHostCore.Destination? {
        graph.destinations.first { $0.route == route }
    }

    private func firstGraph(route: String, graph: NavHostCore.Graph) -> NavHostCore.Graph? {
        graph.childs.first { $0.route == route || $0.startDestination == route }
    }

    func resolve(route: String) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        var result = resolve(route: route, graph: self)
        if result == nil {
            result = resolveAscending(route: route, graph: self)
        }
        return result
    }

    private func resolve(route: String, graph: NavHostCore.Graph) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        var outGraph = graph
        var outDestination = firstDestination(route: route, graph: outGraph)
        if outDestination == nil {
            if let graph = firstGraph(route: route, graph: outGraph), let _outDestination = firstDestination(route: graph.startDestination, graph: graph) {
                outDestination = _outDestination
                outGraph = graph
            }
        }
        if let outDestination {
            return (outGraph, outDestination)
        }
        else {
            return nil
        }
    }

    private func resolveAscending(route: String, graph: NavHostCore.Graph) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        var parent = graph.parent
        while parent != nil {
            if let result = resolve(route: route, graph: parent!) {
                return result
            }
            parent = parent!.parent
        }
        return nil
    }
}

public class _NavHostCore_Graph_Builder {
    private let navGraph: NavHostCore.Graph
    private var childs: [NavHostCore.Graph.Builder]
    private let providers: [TypeIdentity: any NavHostCore.Navigator]

    init(
        providers: [TypeIdentity: any NavHostCore.Navigator],
        parent: NavHostCore.Graph? = nil,
        route: String? = nil,
        startDestination: String
    ) {
        self.providers = providers
        self.navGraph = NavHostCore.Graph(
            parent: parent,
            route: route,
            startDestination: startDestination
        )
        self.childs = []
    }

    func addDestination(destination: NavHostCore.Destination) {
        navGraph.append(destination: destination)
    }

    func getProvider<N: NavHostCore.Navigator>(of identity: N.Type) -> N {
        return providers[TypeIdentity(identity)] as? N ?? {
            fatalError("navigator \(identity) not provided to NavHostController")
        }()
    }

    func navigation(
        route: String,
        startDestination: String,
        builder: (NavHostCore.Graph.Builder) -> Void
    ) {
        let child = NavHostCore.Graph.Builder(
            providers: providers,
            parent: navGraph,
            route: route,
            startDestination: startDestination
        )
        childs.append(child)
        builder(child)
    }

    func build() -> NavHostCore.Graph {
        childs.forEach { child in
            navGraph.append(child: child.build())
        }
        return navGraph
    }
}

open class _NavHostCore_Destination {
    let navigatorName: String
    let route: String?

    init(navigatorName: String, route: String?) {
        self.navigatorName = navigatorName
        self.route = route
    }
}

public class _NavHostCore_BackStackEntry {
    public let id: String
    fileprivate var isVisible: Bool
    public let destination: NavHostCore.Destination
    public let arguments: [String: Any]?

    init(destination: NavHostCore.Destination) {
        self.id = UUID().uuidString
        self.isVisible = false
        self.destination = destination
        self.arguments = nil
    }
}

public class _NavHostCore_Option {
    public let clearStack: Bool
    public let singleTop: Bool
    public let popUpToRoute: String?
    public let popUpInclusive: Bool

    init(
        clearStack: Bool,
        singleTop: Bool,
        popUpToRoute: String?,
        popUpInclusive: Bool
    ) {
        self.singleTop = singleTop
        self.clearStack = clearStack
        self.popUpToRoute = popUpToRoute
        self.popUpInclusive = popUpInclusive
    }
}
