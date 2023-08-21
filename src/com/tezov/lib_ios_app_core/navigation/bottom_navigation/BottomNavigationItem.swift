

public struct BottomNavigationItem {
    public let titleResource: String
    public let iconActive: String
    public let iconInactive: String
    public let route: NavigationRouteManager.Route

    public init(titleResource: String, iconActive: String, iconInactive: String, route: NavigationRouteManager.Route) {
        self.titleResource = titleResource
        self.iconActive = iconActive
        self.iconInactive = iconInactive
        self.route = route
    }
}
