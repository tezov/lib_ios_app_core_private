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
            if graph != nil {
                fatalError("graph is already setted")
            }
        }
        didSet {
            currentGraphNode = graph
        }
    }

    private var _backQueue: [NavHostCore.BackStackEntry]
    private(set) var providers: [TypeIdentity: any NavHostCore.Navigator]

    var currentBackStack: [NavHostCore.BackStackEntry] = []
    var visibleEntries: [NavHostCore.BackStackEntry] = []

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

    func navigate(route: String, option _: NavHostCore.Option? = nil) {
        
        //todo nav at the same route ?
        //todo add to queue
        
        guard let _graph = graph else { fatalError("graph is nil, you forgot to set it inside NavHost View") }
        guard let (newNode, destination) = currentGraphNode.moveTo(route: route)
        else { fatalError("invalid navigate request from \(currentBackStackEntry?.destination.route ?? "root") to \(route)") }

        //        var destination:NavHostCore.Destination? = nil
        //        if let _option = option {
        //            if _option.clearStack.isTrue  {
        //                _backQueue.forEach { entry in
        //
        //
        //                    providers.first { (_, navigator) in
        //                        navigator.name == entry.destination.navigatorName
        //                    }?.value.navigate(entries: <#T##[NavHostCore.BackStackEntry]#>, navOptions: T##NavigationController.Option)
        //
        //
        //
        //                }
        //            }
        //            if let singleTop = _option.singleTop {
        //
        //            }
        //
        //
        //
        //
        //        }

        // let destination = NavHostCore.Destination(navigatorName: "", route: route) // graph.findDestination()
        // let entry = NavHostCore.BackStackEntry(destination: destination)
        // _backQueue.append(entry)
    }

    func popBackStack() {
        _backQueue.removeLast()
    }
}

public class _NavHostCore_Graph {
    private var parent: NavHostCore.Graph?
    private var childs: [NavHostCore.Graph]
    private var route: String?
    private var startDestination: String?
    private var destinations: [NavHostCore.Destination]

    init(
        parent: NavHostCore.Graph? = nil,
        route: String? = nil,
        startDestination: String? = nil
    ) {
        self.parent = parent
        self.childs = []
        self.route = route
        self.startDestination = startDestination
        self.destinations = []
        
        print("navgraph \(route ?? "ROOT") \(startDestination ?? "")")
    }

    func append(destination: NavHostCore.Destination) {
        print("destination \(destination.route ?? "")")
        
        destinations.append(destination)
    }

    func append(child: NavHostCore.Graph) {
        childs.append(child)
    }

    func moveTo(route: String) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        
        print("moveTo \(route) from \(self.route ?? "ROOT") \(self.startDestination ?? "nil")")
        
        var result = resolve(route: route, graph: self)
        if(result == nil){
            result = resolveAscending(route: route, graph: self)
        }
        return result
    }
    
    private func resolve(route: String, graph:NavHostCore.Graph) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        print("resolve")
        
        var outNode:NavHostCore.Graph = graph
        var outDestination:NavHostCore.Destination? = nil
        //look in sibling destination
        print("look in sibling destination")
        for destination in destinations {
            print("**\(destination.route ?? "nil")")
            if(destination.route == route){
                outDestination = destination
                break
            }
        }
        //look in sibling graph
        print("look in sibling graph")
        if(outDestination == nil){
            for graph in childs {
                print("graph \(graph.route ?? "nil") \(graph.startDestination ?? "nil")")
                if(graph.route == route){
                    outDestination = graph.destinations.first { destination in
                        print("**\(destination.route ?? "nil")")
                        return destination.route == graph.startDestination
                    }
                    if(outDestination != nil){
                        outNode = graph
                    }
                    break
                }
            }
        }
        //return
        if let _outDestination = outDestination {
            print("resolve result \(outNode.route ?? "nil") \(_outDestination.route ?? "nil")")
            return (outNode, _outDestination)
        }
        else {
            print("resolve result nil")
            return nil
        }
    }
        
    private func resolveAscending(route: String, graph:NavHostCore.Graph) -> (node: NavHostCore.Graph, destination: NavHostCore.Destination)? {
        print("resolveAscending")
        
        var parent = graph.parent
        while(parent != nil){
            if let result = resolve(route: route, graph:parent!){
                print("resolveAscending result done")
                return result
            }
            parent = parent!.parent
        }
        print("resolveAscending result nil")
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
        startDestination: String? = nil
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
    public let clearStack: Bool?
    public let singleTop: Bool?
    public let popUpToRoute: String?
    public let popUpInclusive: Bool?

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
