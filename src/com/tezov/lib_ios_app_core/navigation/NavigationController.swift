import lib_ios_core

// MARK: -
public enum NavigationController {
    public typealias Friend = _NavigationController_Friend
    public typealias Core = _NavigationController
    public typealias Option = _NavigationController_Option
    public typealias Request = _NavigationController_Request
}

public extension NavigationController.Option {
    typealias PopUpTo = _NavigationController_Option_PopUpTo
}

public extension NavigationController.Friend {
    fileprivate typealias Object = _NavigationController_Friend_Object
}
// MARK: -

public protocol _NavigationController_Friend { }

private struct _NavigationController_Friend_Object: NavigationController.Friend { }

open class _NavigationController {
    internal let navHostController: NavHostCore.Controller
    private let navigationNotifier: NavigationNotifier

    private let _routes = NavigationRouteManager.Core()
    private var requestHandlers: ListEntry<Klass, (NavigationController.Request) -> Void> = ListEntry()

    public init(navHostController: NavHostCore.Controller, navigationNotifier: NavigationNotifier) {
        self.navHostController = navHostController
        self.navigationNotifier = navigationNotifier
    }
   
    public func addRequestHandler(
        friend _: NavigationController.Friend,
        type: any CompositionAction.Interface.Type,
        handler: @escaping (NavigationController.Request) -> Void
    ) {
        requestHandlers.add(key: type.klass(), value: handler)
    }

    public func addRequestHandler(
        friend _: NavigationController.Friend,
        handlers: [(type: any CompositionAction.Interface.Type, handler: (NavigationController.Request) -> Void)]
    ) {
        handlers.forEach { type, handler in
            requestHandlers.add(key: type.klass(), value: handler)
        }
    }

    public func setRequestExceptionHandler(
        friend _: NavigationController.Friend,
        handler: @escaping (NavigationController.Request) -> Void
    ) {
        requestHandlers.put(key: Exception.klass(), value: handler)
    }

    public func setRequestFeedbackHandler(
        friend _: NavigationController.Friend,
        handler: @escaping (NavigationController.Request) -> Void
    ) {
        requestHandlers.put(key: NavigationRouteManager.Route.RequestFeedback.klass(), value: handler)
    }

    public func routes(friend _: NavigationController.Friend) -> NavigationRouteManager.Core { _routes }

    public func onBackPressedDispatch() -> Bool { handleOnBackPressed() }

    public func handleOnBackPressed() -> Bool { navigateBack().isTrueOrNull }

    private var currentRequest: NavigationController.Request? {
        didSet {
            if let currentRequest {
                isNavigatingBack = currentRequest.to is NavigationRouteManager.Route.Back
            }
        }
    }

    var isIdle: Bool { currentRequest == nil }

    private(set) var isNavigatingBack = false

    public var isLastRoute: Bool { navHostController.previousBackStackEntry == nil }

    func currentRoute(_ copyArgument: Bool = false) -> NavigationRouteManager.Route? {
        let _entry: NavHostCore.BackStackEntry?
        if isIdle || isNavigatingBack {
            _entry = navHostController.currentBackStackEntry
        }
        else {
            _entry = navHostController.previousBackStackEntry
        }
        if let entry = _entry {
            return resolveRoute(navBackStackEntry: entry, copyArgument: copyArgument)
        }
        return nil
    }

    func finalRoute(_ copyArgument: Bool = false) -> NavigationRouteManager.Route? {
        if let entry = navHostController.currentBackStackEntry {
            return resolveRoute(navBackStackEntry: entry, copyArgument: copyArgument)
        }
        return nil
    }

    private func resolveRoute(navBackStackEntry: NavHostCore.BackStackEntry, copyArgument: Bool = false) -> NavigationRouteManager.Route? {
        var routeCopy: NavigationRouteManager.Route?
        if let route = _routes.find(navBackStackEntry.destination.route) {
            if copyArgument {
                if let arguments = navHostController.currentBackStackEntry?.arguments {
                    routeCopy = route.copy(bundle: arguments)
                }
            }
            if routeCopy == nil { routeCopy = route }
        }
        return routeCopy
    }

    private func lockNavigate(_ request: NavigationController.Request) -> Bool {
        if currentRequest != nil {
            requestFeedback(request: request, exception: Exception(message: "Navigation is busy"))
            return false
        }
        currentRequest = request
        return true
    }

    internal func unlockNavigate() {
        if let it = currentRequest {
            requestFeedback(request: it, exception: nil)
            currentRequest = nil
        }
    }

    private func requestFeedback(request: NavigationController.Request, exception: Exception?) {
        let failedRequest = NavigationController.Request(
            from: request.from,
            to: NavigationRouteManager.Route.RequestFeedback(
                target: request.to,
                exception: exception
            ),
            askedBy: request.askedBy
        )
        requestHandlers.getValue(NavigationRouteManager.Route.RequestFeedback.klass())?(failedRequest)
    }

    public func navigate(friend _: NavigationController.Friend, request: NavigationController.Request) {
        if !lockNavigate(request) { return }
        if request.to is NavigationRouteManager.Route.Finish {
            // todo close application ?
        }
        else {
            navigationNotifier.onNavigate(request: request)
            navHostController.navigate(route: request.to.query, option: request.option?.build())
        }
    }

    private func navigateBack() -> Bool? {
        return navigateBack(
            friend: NavigationController.Friend.Object(),
            request: NavigationController.Request(
                from: currentRoute(),
                to: NavigationRouteManager.Route.Back(),
                askedBy: nil
            )
        )
    }

    public func navigateBack(friend _: NavigationController.Friend, request: NavigationController.Request) -> Bool? {
        if !lockNavigate(request) { return nil }
        if !isLastRoute {
            navigationNotifier.onNavigate(request: request)
            navHostController.popBackStack()
            return true
        }
        return false
    }

    //    ***** Public Access

    public func requestNavigate(to: NavigationRouteManager.Route, askedBy: KlassIdentifiable) {
        requestNavigate(
            NavigationController.Request(
                from: currentRoute(),
                to: to,
                askedBy: askedBy
            )
        )
    }

    public func requestNavigate(_ request: NavigationController.Request) {
        let entry = requestHandlers.find { entry in
            if let askedBy = request.askedBy {
                return askedBy.klass().isInstance(of: entry.key) || askedBy.klass().isSubInstance(of: entry.key)
            }
            return false
        }
        if let value = entry?.value {
            value(request)
        }
        else {
            requestHandlers.getValue(Exception.klass())?(request)
        }
    }

    public func requestNavigateBack(askedBy: any CompositionAction.Interface) {
        requestNavigate(to: NavigationRouteManager.Route.Back.original, askedBy: askedBy)
    }
}

public class _NavigationController_Option {
    public let singleTop: Bool?
    public let popUpTo: PopUpTo?
    public let clearStack: Bool?

    public init(singleTop: Bool? = nil, popUpTo: PopUpTo? = nil, clearStack: Bool? = nil) {
        self.singleTop = singleTop
        self.popUpTo = popUpTo
        self.clearStack = clearStack
    }

    public static func clearStack() -> NavigationController.Option { NavigationController.Option(clearStack: true) }

    public static func singleTop(route: NavigationRouteManager.Route) -> NavigationController.Option {
        NavigationController.Option(
            singleTop: true,
            popUpTo: NavigationController.Option.PopUpTo(route: route, inclusive: false)
        )
    }

    public static func popUpTo(route: NavigationRouteManager.Route, singleTop: Bool? = nil, inclusive: Bool = true) -> NavigationController.Option {
        NavigationController.Option(
            singleTop: singleTop,
            popUpTo: NavigationController.Option.PopUpTo(route: route, inclusive: inclusive)
        )
    }
    
    public func build() -> NavHostCore.Option {
        return NavHostCore.Option(
            clearStack: self.clearStack ?? false,
            singleTop: self.singleTop ?? false,
            popUpToRoute: self.popUpTo?.route.path ?? nil,
            popUpInclusive: self.popUpTo?.inclusive ?? false
        )
    }
}

public class _NavigationController_Option_PopUpTo {
    public let route: NavigationRouteManager.Route
    public let inclusive: Bool

    public init(route: NavigationRouteManager.Route, inclusive: Bool) {
        self.route = route
        self.inclusive = inclusive
    }
}

public class _NavigationController_Request {
    public let from: NavigationRouteManager.Route?
    public let to: NavigationRouteManager.Route
    public let askedBy: KlassIdentifiable?
    public var option: NavigationController.Option?

    public init(
        from: NavigationRouteManager.Route? = nil,
        to: NavigationRouteManager.Route,
        askedBy: KlassIdentifiable?,
        option: NavigationController.Option? = nil
    ) {
        self.from = from
        self.to = to
        self.askedBy = askedBy
        self.option = option
    }
}
