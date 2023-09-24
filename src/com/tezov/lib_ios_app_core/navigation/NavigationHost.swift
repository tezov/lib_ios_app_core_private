import lib_ios_core
import SwiftUI

public struct NavHost: View {
    @State @Lazy private var state = NavHostState()
    
    public init(
        navController: NavigationController.Core,
        route: NavigationRouteManager.Route? = nil,
        startRoute: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config(),
        builder: @escaping (NavHostCore.Graph.Builder) -> Void
    ) {
        state.update(
            navController: navController,
            route: route,
            startRoute: startRoute,
            animationConfig: animationConfig,
            builder: builder
        )
    }
    
    public var body: some View {
        state.remember()
    }
}

private class NavHostState {
    private var value: NavHostImpl? = nil
    
    var navController: NavigationController.Core!
    var route: NavigationRouteManager.Route?
    var startRoute: NavigationRouteManager.Route!
    var animationConfig: NavigationAnimation.Config!
    var builder: ((NavHostCore.Graph.Builder) -> Void)!
    
    func update(
        navController: NavigationController.Core,
        route: NavigationRouteManager.Route? = nil,
        startRoute: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config(),
        builder: @escaping (NavHostCore.Graph.Builder) -> Void
    ) {
        if value == nil {
            self.navController = navController
            self.route = route
            self.startRoute = startRoute
            self.animationConfig = animationConfig
            self.builder = builder
        }
    }
    
    func remember() -> NavHostImpl {
        return value ?? {
            let graphBuilder = NavHostCore.Graph.Builder(
                providers: navController.navHostController.providers,
                startDestination: startRoute.path
            )
            builder(graphBuilder)
            navController.navHostController.graph = graphBuilder.build()
            value = NavHostImpl(
                navController: navController,
                animationConfig: animationConfig
            )
            return value!
        }()
    }
    
}

public struct NavHostImpl: View {
    private let navController: NavigationController.Core
    private let animationConfig: NavigationAnimation.Config
    
    init(navController: NavigationController.Core, animationConfig: NavigationAnimation.Config) {
        self.navController = navController
        self.animationConfig = animationConfig
    }
    
    private var entries: [NavHostCore.BackStackEntry] = []
    private var lastEntryId: String?
    
    var isNavigatingBack: Bool { navController.isNavigatingBack }
    
    func isLastEntry(entry: NavHostCore.BackStackEntry) -> Bool { entry.id == lastEntryId }
    
    private var indexOfLastEntry: Int? { entries.lastIndex { $0.id == lastEntryId } }
    
    var lastEntry: NavHostCore.BackStackEntry? { entries.last { $0.id == lastEntryId } }
    
    public var body: some View {
        Text("Hello World ").onTapGesture {
            
            
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
