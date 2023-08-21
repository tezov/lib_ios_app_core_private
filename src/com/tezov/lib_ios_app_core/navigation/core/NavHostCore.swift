import Foundation
import lib_ios_core

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
    associatedtype Destination : NavHostCore.Destination
    
    var name:String { get }
    
    
    func navigate(
        entries: [NavHostCore.BackStackEntry],
        navOptions: NavHostCore.Option
    )
    
    func popBackStack(
        popUpTo: NavHostCore.BackStackEntry,
        savedState: Bool
    )
    
}

public class _NavHostCore_Controller {
    var graph:NavHostCore.Graph? = nil
    private var _backQueue: [NavHostCore.BackStackEntry]
    private(set) var providers: [TypeIdentity: any NavHostCore.Navigator]
    
    public init(providers: [TypeIdentity: any NavHostCore.Navigator] = [:]) {
        self._backQueue = []
        var _providers: [TypeIdentity: any NavHostCore.Navigator] = [
            TypeIdentity(ComposableTransientNavigator.Core.self): ComposableTransientNavigator.Core(),
            TypeIdentity(ComposableOverlayNavigator.Core.self): ComposableOverlayNavigator.Core()
        ]
        providers.forEach { key, value in
            _providers[key] = value
        }
        self.providers = _providers
    }
    
    var currentBackStack: [NavHostCore.BackStackEntry] { _backQueue }
    
    var currentBackStackEntry: NavHostCore.BackStackEntry? { _backQueue.last }
    
    var previousBackStackEntry: NavHostCore.BackStackEntry? {
        if _backQueue.count <= 1 { return nil }
        return _backQueue[_backQueue.count - 2]
    }
    
    func navigate(route: String, option: NavHostCore.Option? = nil) {
        guard let _graph = graph else { fatalError("graph is nil, you forgot to set it inside NavHost View") }
        
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
        
        
        let destination = NavHostCore.Destination(navigatorName: "", route: route) // graph.findDestination()
        let entry = NavHostCore.BackStackEntry(destination: destination)
        _backQueue.append(entry)
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
    }
    
    func append(destination: NavHostCore.Destination) {
        destinations.append(destination)
    }
    
    func append(child: NavHostCore.Graph) {
        childs.append(child)
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
    let navigatorName:String
    let route: String?
    
    init(navigatorName:String, route: String?) {
        self.navigatorName = navigatorName
        self.route = route
    }
}

public class _NavHostCore_BackStackEntry {
    public let destination: NavHostCore.Destination
    public let arguments: [String: Any]? = nil
    
    public let id: String = UUID().uuidString
    
    init(destination: NavHostCore.Destination) {
        self.destination = destination
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



