import lib_ios_core
import UIKit

// MARK: -
public enum NavigationRouteManager {
    public typealias Core = _NavigationRouteManager
    public typealias Route = _NavigationRouteManager_Route
    public typealias Routes = _NavigationRouteManager_Routes
}
// MARK: -

public class _NavigationRouteManager {
    var routes: Set<NavigationRouteManager.Route> = [
        NavigationRouteManager.Route.Back.original,
        NavigationRouteManager.Route.Finish.original,
        NavigationRouteManager.Route.RequestFeedback.original,
        NavigationRouteManager.Route.NotImplemented.original,
    ]

    public func add(_ route: NavigationRouteManager.Route) {
        routes.insert(route)
    }

    public func add(_ routes: [NavigationRouteManager.Route]) -> Bool {
        var allInserted = true
        for route in routes {
            allInserted = allInserted && self.routes.insert(route).inserted
        }
        return allInserted
    }

    public func find(_ route: String?) -> NavigationRouteManager.Route? { find(route, routes) }

    func find(_ route: String?, _ routes: Set<NavigationRouteManager.Route>) -> NavigationRouteManager.Route? {
        for routeItem in routes {
            if route == routeItem.path {
                return routeItem
            }
            if let routes = routeItem as? NavigationRouteManager.Routes, let foundRoute = find(route, routes.child) {
                return foundRoute
            }
        }
        return nil
    }
}

open class _NavigationRouteManager_Route: Hashable, Identifiable {
    public let id: String
    var parent: NavigationRouteManager.Route?
    private var parameters: ListEntry<String, String?>?

    public init(_ id: String, parent: NavigationRouteManager.Route? = nil) {
        self.id = id
        self.parent = parent
        self.parameters = nil
    }

    private func obtainParameters() -> ListEntry<String, String?> {
        return parameters ?? {
            parameters = ListEntry()
            return parameters!
        }()
    }

    @discardableResult
    public func setParameter(name: String, value: String?) -> Bool {
        if isReadOnly {
            fatalError("\(type(of: self)) is read only")
        }
        return obtainParameters().set(key: name, value: value)
    }

    @discardableResult
    public func putParameter(name: String, value: String?) -> Bool {
        if isReadOnly {
            fatalError("\(type(of: self)) is read only")
        }
        return obtainParameters().put(key: name, value: value)
    }

    public func getParameter(name: String) -> String? {
        return parameters?.getValue(name).flatten() as? String
    }

    public var path: String {
        if let it = parameters {
            var path = id
            path.append("/{\(NavigationRouteManager.Route.HAS_PARAMETER)}")
            it.forEach { entry in
                path.append("/{\(entry.key)}")
            }
            return path
        }
        else {
            return id
        }
    }

    public var query: String {
        if let it = parameters {
            var path = id
            path.append("/\(NavigationRouteManager.Route.HAS_PARAMETER)")
            it.forEach { entry in
                path.append("/\(entry.value ?? NavigationRouteManager.Route.PARAMETER_NULL)") // todo value?.toStringHex()
            }
            return path
        }
        else {
            return id
        }
    }

    open func createCopy() -> NavigationRouteManager.Route { NavigationRouteManager.Route(id) }

    open var isReadOnly: Bool { false }

    open func copy(bundle: [String: Any]?) -> NavigationRouteManager.Route {
        if bundle != nil && bundle![NavigationRouteManager.Route.HAS_PARAMETER] == nil {
            return self
        }
        let route = createCopy()
        if let it = bundle {
            parameters?.forEach { entry in
                let bundleValue = (it[entry.key] as? String) // todo ?.toStringChar()
                route.putParameter(name: entry.key, value: bundleValue ?? entry.value)
            }
        }
        else {
            parameters?.forEach { entry in
                route.putParameter(name: entry.key, value: entry.value)
            }
        }
        return route
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: NavigationRouteManager.Route, rhs: NavigationRouteManager.Route) -> Bool { lhs.id == rhs.id }
}

open class _NavigationRouteManager_Routes: NavigationRouteManager.Route {
    public let child: Set<NavigationRouteManager.Route>

    public init(_ id: String, child: Set<NavigationRouteManager.Route>) {
        self.child = child
        super.init(id)
        child.forEach { $0.parent = self }
    }
}

public extension NavigationRouteManager.Route {
    internal static let HAS_PARAMETER = "!"
    internal static let PARAMETER_NULL = "?"

    class Back: NavigationRouteManager.Route {
        public static let original = NavigationRouteManager.Route.Back()

        public init() {
            super.init("back")
        }

        override public func createCopy() -> NavigationRouteManager.Route { Back() }

        override public var isReadOnly: Bool { self === Back.original }
    }

    class Finish: NavigationRouteManager.Route {
        public static let original = NavigationRouteManager.Route.Finish()

        public init() {
            super.init("finish")
        }

        override public func createCopy() -> NavigationRouteManager.Route { Finish() }

        override public var isReadOnly: Bool { self === Finish.original }
    }

    class RequestFeedback: NavigationRouteManager.Route, KlassIdentifiable {
        private static var _metaIdentifier = [ObjectIdentifier(RequestFeedback.self)]
        public static let original = NavigationRouteManager.Route.RequestFeedback(target: nil, exception: nil)

        public let target: NavigationRouteManager.Route?
        public let exception: Exception?

        public init(target: NavigationRouteManager.Route?, exception: Exception?) {
            self.target = target
            self.exception = exception
            super.init("request_feedback")
        }

        public class var klassIdentifiers: [ObjectIdentifier] { _metaIdentifier }

        override public func createCopy() -> NavigationRouteManager.Route {
            RequestFeedback(target: target, exception: exception)
        }

        override public var isReadOnly: Bool { self === RequestFeedback.original }
    }

    class NotImplemented: NavigationRouteManager.Route {
        public static let original = NavigationRouteManager.Route.NotImplemented(message: nil)

        public let message: String?

        public init(message: String?) {
            self.message = message
            super.init("not_implemented")
        }

        override public func createCopy() -> NavigationRouteManager.Route { NotImplemented(message: message) }

        override public var isReadOnly: Bool { self === NotImplemented.original }
    }
}
