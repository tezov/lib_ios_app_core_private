import Combine
import lib_ios_core
import lib_ios_ui_core
import SwiftUI

@propertyWrapper public class Mutable<T: Any> {
    private var value: T
    public var wrappedValue: T {
        get { value }
        set { value = newValue }
    }

    public init(wrappedValue: T) {
        value = wrappedValue
    }
}

@propertyWrapper public struct RememberState<T: ObservableObject>: DynamicProperty {
    @State var state: Int = 0
    @Mutable private var cancellable: AnyCancellable? = .none
    @Mutable private var initializer: (() -> T)?
    @Mutable private var value: T? = .none
    public var wrappedValue: T {
        return value ?? {
            guard let initializer else { fatalError("RememberState initializer is nil") }
            let value = initializer()
            self.initializer = .none
            cancellable = value.objectWillChange.sink(
                receiveValue: { [$state] _ in $state.wrappedValue += 1 }
            )
            self.value = value
            return value
        }()
    }

    public init(wrappedValue: @escaping @autoclosure () -> T) {
        self.initializer = wrappedValue
    }

    public init(_ initializer: @escaping () -> T) {
        self.initializer = initializer
    }
}

private struct _NavigationController_Friend_Object: NavigationController.Friend { }

public struct NavHost: View {
    @RememberState private var state: NavHostState

    public init(
        navController: NavigationController.Core,
        route _: NavigationRouteManager.Route? = nil,
        startRoute: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config(),
        builder: @escaping (NavHostCore.Graph.Builder) -> Void
    ) {
        self._state = RememberState {
            let graphBuilder = NavHostCore.Graph.Builder(
                providers: navController.navHostController.providers,
                startDestination: startRoute.path
            )
            builder(graphBuilder)
            navController.navHostController.graph = graphBuilder.build()
            return NavHostState(
                navController: navController,
                animationConfig: animationConfig
            )
        }
    }

    public var body: some View {
        let _ = _state.state
        state.body
    }
}

private class NavHostState: ObservableObject {
    var navController: NavigationController.Core
    var animationConfig: NavigationAnimation.Config
    var ref: AnyCancellable? = nil

    public init(
        navController: NavigationController.Core,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config()
    ) {
        self.navController = navController
        self.animationConfig = animationConfig
        ref = navController.navHostController.$currentBackStack.sink(
            receiveValue: { [weak self] values in
                guard let self else { return }
                values.forEach { entry in
                    print("\(entry.id):\(entry.destination.route ?? "not route")")
                }
                self.objectWillChange.send()
            }
        )
    }

    private var entries: [NavHostCore.BackStackEntry] = []
    private var lastEntryId: String?

    var isNavigatingBack: Bool { navController.isNavigatingBack }

    func isLastEntry(entry: NavHostCore.BackStackEntry) -> Bool { entry.id == lastEntryId }

    private var indexOfLastEntry: Int? { entries.lastIndex { $0.id == lastEntryId } }

    var lastEntry: NavHostCore.BackStackEntry? { entries.last { $0.id == lastEntryId } }

    @ViewBuilder
    public var body: some View {
        let _ = print("**** bottom")
        VStack {
            Text("Hello World \(navController.navHostController.currentBackStack.count)")
                .onTapGesture { [unowned self] in
                    if let currentRoute = navController.currentRoute() {
                        print("current route: \(currentRoute.path)")
                        
                        navController.navigate(
                            friend: _NavigationController_Friend_Object(),
                            request: NavigationController.Request(
                                from: currentRoute,
                                to: currentRoute,
                                askedBy: nil,
                                option: nil
                            )
                        )
                        
                    }
                    
                    
                }
        }
    }
}

internal class _NavHost {
    private let navController: NavigationController.Core
    private let animationConfig: NavigationAnimation.Config

    init(navController: NavigationController.Core, animationConfig: NavigationAnimation.Config) {
        self.navController = navController
        self.animationConfig = animationConfig
    }

    private var entries: [NavHostCore.BackStackEntry] = []
    private var lastEntryId: String?
//    private var isLastEntryHasChanged: Boolean = false

    var isIdle: Bool { navController.isIdle }

    var isNavigatingBack: Bool { navController.isNavigatingBack }

    func isLastEntry(entry: NavHostCore.BackStackEntry) -> Bool { entry.id == lastEntryId }

    private var indexOfLastEntry: Int {
//        return entries.indexOfLast { it.id == lastEntryId }
        fatalError("not implemented")
    }

    var lastEntry: NavHostCore.BackStackEntry {
//        return entries.last { it.id == lastEntryId }
        fatalError("not implemented")
    }

    var lastEntries: [NavHostCore.BackStackEntry] {
//        get() = when {
//            entries.size >= 2 -> {
//                when {
//                    !navController.isIdle && navController.isNavigatingBack -> {
//                        entries.subList(0, indexOfLastEntry + 1).filter { it.content.isVisible }
//                    }
//
//                    else -> {
//                        entries.subList(indexOfLastEntry, entries.size)
//                            .filter { it.content.isVisible }
//                    }
//                }
//            }
//            else -> {
//                null
//            }
        fatalError("not implemented")
    }

    var priorEntries: [NavHostCore.BackStackEntry] {
//        entries.size >= 2 -> {
//            when {
//                !navController.isIdle && navController.isNavigatingBack -> {
//                    entries.subList(indexOfLastEntry + 1, entries.size)
//                        .filter { it.content.isVisible }
//                }
//
//                else -> {
//                    entries.subList(0, indexOfLastEntry).filter { it.content.isVisible }
//                }
//            }
//        }
//
//        else -> {
//            null
//        }
        fatalError("not implemented")
    }

//    fun nextEntryOf(entry: NavBackStackEntry) =
//    entries.indexOf(entry).takeIf { it != NULL_INDEX }?.let { index ->
//        entries.getOrNull(index + 1)
//    }
//
//    fun previousEntryOf(entry: NavBackStackEntry) =
//    entries.indexOf(entry).takeIf { it != NULL_INDEX }?.let { index ->
//        entries.getOrNull(index - 1)
//    }

//    @Composable
//    fun compose(
//        backQueue: StateFlow<List<NavBackStackEntry>>,
//        visibleEntries: StateFlow<List<NavBackStackEntry>>,
//    ) {
//        val backQueueState by remember(this) { backQueue }.collectAsState(emptyList())
//        val visibleEntriesState by remember(this) { visibleEntries }.collectAsState(emptyList())
//
//        (lastEntryId ?: let {
//            isLastEntryHasChanged = false
//            lastEntryId = visibleEntriesState.lastOrNull()?.id
//        })
//        updateEntries(
//            backQueueState = backQueueState,
//            visibleEntriesState = visibleEntriesState,
//        )
//        if (entries.isEmpty()) return
//            for (entry in entries) {
//            entry.navigator.composePrepare(
//                navHost = this@NavHost,
//                entry = entry
//            )
//        }
//        for (entry in entries.asReversed()) {
//            entry.navigator.updateCompletion(
//                navHost = this@NavHost,
//                entry = entry
//            )
//        }
//        updateTransition()
//        for (entry in entries) {
//            key(entry.id) {
//                entry.navigator.apply {
//                    completeIfRequested(entry)
//                    compose(
//                        saveableStateHolder = saveableStateHolder,
//                        navHost = this@NavHost,
//                        entry = entry,
//                    )
//                }
//            }
//        }
//    }
//
//    @Composable
//    private fun updateEntries(
//        backQueueState: List<NavBackStackEntry>,
//        visibleEntriesState: List<NavBackStackEntry>,
//    ) {
//        val visibleEntriesStateDistinct = visibleEntriesState.distinctBy { it.id }
//        val common = entries.intersect(visibleEntriesStateDistinct)
//        common.forEach { commonEntry ->
//            commonEntry.content.takeIf { !it.isVisible }?.let { content ->
//                content.isVisible = true
//            }
//        }
//        val diff = entries.subtract(visibleEntriesStateDistinct)
//        diff.forEach { diffEntry ->
//            if (!backQueueState.contains(diffEntry)) {
//                entries.remove(diffEntry)
//            }
//        }
//        if (!isNavigatingBack) {
//            val new = visibleEntriesStateDistinct.subtract(entries)
//            new.forEach { newEntry ->
//                newEntry.content.isVisible = true
//                entries.addLast(newEntry)
//            }
//        }
//        when {
//            !navController.isIdle && navController.isNavigatingBack && entries.size >= 2 -> {
//                entries.subList(0, entries.size - 1).last { it.content.isVisible }
//            }
//
//            else -> {
//                entries.lastOrNull()
//            }
//        }?.let {
//            if (it.id != lastEntryId) {
//                lastEntryId = it.id
//                isLastEntryHasChanged = true
//            }
//        }
//    }

//    private fun ComposableNavigator.Content.updateTransition(
//        transition: AnimationProgress,
//        animationConfig: NavigationAnimation.Config,
//        directionContent: NavigationAnimation.Direction.Content,
//    ) {
//        val type = when (directionContent) {
//            NavigationAnimation.Direction.Content.Enter -> when {
//                isNavigatingBack -> animationConfig.enter.pop
//                else -> animationConfig.enter.push
//                    }
//
//            NavigationAnimation.Direction.Content.Exit -> when {
//                isNavigatingBack -> animationConfig.exit.pop
//                else -> animationConfig.exit.push
//                    }
//        }
//        when (type) {
//            is Type.None -> {
//                modifierAnimation = NavigationAnimation.None()
//            }
//
//            is Type.Fade -> {
//                modifierAnimation = transition.fade(
//                    config = type,
//                    directionContent = directionContent,
//                )
//            }
//
//            is Type.SlideHorizontal -> {
//                modifierAnimation = transition.slideHorizontal(
//                    config = type,
//                    directionNav = when (isNavigatingBack) {
//                        true -> NavigationAnimation.Direction.Nav.Pop
//                        false -> NavigationAnimation.Direction.Nav.Push
//                    },
//                    directionContent = directionContent,
//                )
//            }
//
//            is Type.SlideVertical -> {
//                modifierAnimation = transition.slideVertical(
//                    config = type,
//                    directionNav = when (isNavigatingBack) {
//                        true -> NavigationAnimation.Direction.Nav.Pop
//                        false -> NavigationAnimation.Direction.Nav.Push
//                    },
//                    directionContent = directionContent,
//                )
//            }
//        }
//    }
//
//    @Composable
//    private fun updateTransition() {
//        if (!isLastEntryHasChanged) {
//            navController.unlockNavigate()
//            return
//        }
//        val transition = updateAnimationProgress()
//        val lastEntries = remember { lastEntries } ?: return
//        val priorEntries = remember { priorEntries } ?: run {
//            navController.unlockNavigate()
//            return
//        }
//        val animationConfigResolved = if (isNavigatingBack) {
//            priorEntries.last().content.animation
//        } else {
//            lastEntries.last().content.animation
//        } ?: animationConfig
//        priorEntries.forEach {
//            it.content.updateTransition(
//                transition = transition,
//                animationConfig = animationConfigResolved,
//                directionContent = NavigationAnimation.Direction.Content.Exit,
//            )
//        }
//        lastEntries.forEach {
//            it.content.updateTransition(
//                transition = transition,
//                animationConfig = animationConfigResolved,
//                directionContent = NavigationAnimation.Direction.Content.Enter,
//            )
//        }
//        if (transition.isIdle) {
//            transition.register(object : ObserverValue<Boolean>(this) {
//                override fun onComplete(value: Boolean) {
//                    unsubscribe()
//                    isLastEntryHasChanged = false
//                    priorEntries.forEach { entry ->
//                        entry.updateCompletion()
//                    }
//                    lastEntries.forEach { entry ->
//                        entry.updateCompletion()
//                    }
//                    navController.unlockNavigate()
//                }
//
//                fun NavBackStackEntry.updateCompletion() =
//                this.content.apply {
//                    val navHost = this@NavHost
//                    val entry = this@updateCompletion
//                    modifierAnimation = NavigationAnimation.None()
//                    navigator?.apply {
//                        updateCompletion(
//                            navHost = navHost,
//                            entry = entry
//                        )
//                        completeIfRequested(entry)
//                    }
//                }
//
//            })
//        }
//        transition.start()
//    }
}
