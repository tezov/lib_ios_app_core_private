import lib_ios_core
import SwiftUI
import UIKit

public struct BottomNavigation: View, ActivitySub {
    public typealias StateType = BottomNavigationState.Core
    public typealias ActionType = BottomNavigationAction.Core<StateType>

    let items: [BottomNavigationItem]
    @Binding var selected: Int
    let onClick: (NavigationRouteManager.Route) -> Void

    public init(items: [BottomNavigationItem], selected: Binding<Int>, onClick: @escaping (NavigationRouteManager.Route) -> Void) {
        self.items = items
        self._selected = selected
        self.onClick = onClick
    }

    public var body: some View {
        BottomNavigationInternal(
            items: items,
            selected: _selected,
            onClick: onClick
        ).layoutPriority(1)
            .frame(maxWidth: .infinity)
    }
}

public struct BottomNavigationInternal: UIViewRepresentable {
    let items: [BottomNavigationItem]
    @Binding var selected: Int
    let onClick: (NavigationRouteManager.Route) -> Void // todo remove this and propagate the click through action same as kotlin

    @State @Lazy private var tabControllerState = TabBarController()

    internal init(items: [BottomNavigationItem], selected: Binding<Int>, onClick: @escaping (NavigationRouteManager.Route) -> Void) {
        self.items = items
        self._selected = selected
        self.onClick = onClick
    }

    func getTabHeight() -> CGFloat { tabControllerState.getTabHeight() }

    public func makeUIView(context _: Context) -> UIView {
        let tabController = tabControllerState
        tabController.tabBar.backgroundColor = .systemBackground
        tabController.setViewControllers(items.map { _ in UIViewController() }, animated: false)
        for i in 0 ..< items.count {
            let itemData = items[i]
            let tabBar = tabController.tabBar.items![i]
            tabBar.title = itemData.titleResource
            tabBar.image = UIImage(systemName: itemData.iconInactive)
        }
        tabController.onClick = { onClick(items[$0].route) }
        return tabController.view
    }

    public func updateUIView(_: UIView, context _: Context) {
        updateIcon()
        tabControllerState.selectedIndex = selected
    }

    private func updateIcon() {
        let selectedPrevious = tabControllerState.selectedIndex
        if selectedPrevious != selected {
            let itemData = items[selectedPrevious]
            let tabBar = tabControllerState.tabBar.items![selectedPrevious]
            tabBar.image = UIImage(systemName: itemData.iconInactive)
        }
        let itemData = items[selected]
        let tabBar = tabControllerState.tabBar.items![selected]
        tabBar.image = UIImage(systemName: itemData.iconActive)
    }
}

private class TabBarController: UITabBarController, UITabBarControllerDelegate {
    var onClick: ((_ index: Int) -> Void)? = nil

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder: NSCoder) not implemented")
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            onClick?(index)
        }
        return false
    }

    func getTabHeight() -> CGFloat { tabBar.frame.height }
}
