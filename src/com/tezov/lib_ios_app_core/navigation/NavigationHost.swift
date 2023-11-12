import Combine
import lib_ios_core
import lib_ios_ui_core
import SwiftUI

private struct _NavigationController_Friend_Object: NavigationController.Friend { }

public struct NavHost: View {
    @StateFlow private var state: NavHostState

    public init(
        navController: NavigationController.Core,
        route _: NavigationRouteManager.Route? = nil,
        startRoute: NavigationRouteManager.Route,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config(),
        builder: @escaping (NavHostCore.Graph.Builder) -> Void
    ) {
        self._state = StateFlow {
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

    public var body: some View { state.body }
}


public class NavHostState: ObservableFlow {
    var navController: NavigationController.Core
    var animationConfig: NavigationAnimation.Config

    public init(
        navController: NavigationController.Core,
        animationConfig: NavigationAnimation.Config = NavigationAnimation.Config()
    ) {
        self.navController = navController
        self.animationConfig = animationConfig
        super.init()
        publish(navController.navHostController.$currentBackStack)
        publish(navController.navHostController.$visibleEntries)
    }

    private var entries: [NavHostCore.BackStackEntry] = []
    private var lastEntryId: String? = nil
    private var isLastEntryHasChanged: Bool = false

    var isNavigatingBack: Bool { navController.isNavigatingBack }

    func isLastEntry(entry: NavHostCore.BackStackEntry) -> Bool { entry.id == lastEntryId }

    private var indexOfLastEntry: Int { entries.lastIndex { $0.id == lastEntryId } ?? -1 }

    var lastEntry: NavHostCore.BackStackEntry? { entries.last { $0.id == lastEntryId } }

    var lastEntries: [NavHostCore.BackStackEntry]? {
        if entries.count >= 2 {
            if !navController.isIdle && navController.isNavigatingBack {
                return entries[0 ... (indexOfLastEntry + 1)].filter { $0.content.isVisible }
            }
            else {
                return entries[indexOfLastEntry ... entries.count].filter { $0.content.isVisible }
            }
        }
        else {
            return nil
        }
    }

    var priorEntries: [NavHostCore.BackStackEntry]? {
        if entries.count >= 2 {
            if !navController.isIdle && navController.isNavigatingBack {
                return entries[(indexOfLastEntry + 1) ... entries.count].filter { $0.content.isVisible }
            }
            else {
                return entries[0 ... indexOfLastEntry].filter { $0.content.isVisible }
            }
        }
        else {
            return nil
        }
    }

    func nextEntryOf(entry: NavHostCore.BackStackEntry) -> NavHostCore.BackStackEntry? {
        if let index = entries.firstIndex(where: { $0 === entry }), index.isNotNilIndex {
            return entries.getOrNil(at: index + 1)
        }
        return nil
    }

    func previousEntryOf(entry: NavHostCore.BackStackEntry) -> NavHostCore.BackStackEntry? {
        if let index = entries.firstIndex(where: { $0 === entry }), index.isNotNilIndex {
            return entries.getOrNil(at: index - 1)
        }
        return nil
    }

    @ViewBuilder
    public var body: some View {
        let backQueueState = navController.navHostController.currentBackStack
        let visibleEntriesState = navController.navHostController.visibleEntries
        CodeBlock {
            lastEntryId ?! {
                isLastEntryHasChanged = false
                lastEntryId = visibleEntriesState.lastOrNil()?.id
            }
            updateEntries(
                backQueueState: backQueueState,
                visibleEntriesState: visibleEntriesState
            )
            if entries.isEmpty { return }
            for entry in entries {
                entry.navigator.composePrepare(
                    navHost: self,
                    entry: entry
                )
            }
            for entry in entries.reversed() {
                entry.navigator.updateCompletion(
                    navHost: self,
                    entry: entry
                )
            }
            updateTransition()
            
            
            
        }
        
//        for entry in entries {
//            //                key(entry.id) {
//            //                    entry.navigator.apply {
//            //                        completeIfRequested(entry)
//            //                        compose(
//            //                            saveableStateHolder = saveableStateHolder,
//            //                            navHost = this@NavHost,
//            //                            entry = entry,
//            //                        )
//            //                    }
//            //                }
//        }

        Text("Hello")
        
    }

    private func updateEntries(
        backQueueState: [NavHostCore.BackStackEntry],
        visibleEntriesState:  [NavHostCore.BackStackEntry]
    ) {
        let visibleEntriesStateDistinct = visibleEntriesState.distinctBy { $0.id }
        let common = entries.intersection(visibleEntriesStateDistinct)
        common.forEach { commonEntry in
            let content = commonEntry.content
            if(!content.isVisible) { content.isVisible = true }
        }
        let diff = entries.subtract(visibleEntriesStateDistinct)
        diff.forEach { diffEntry in
            if (!backQueueState.contains(diffEntry)) {
                //entries.remove(diffEntry)
            }
        }
        if (!isNavigatingBack) {
            let new = visibleEntriesStateDistinct.subtract(entries)
            new.forEach { newEntry in
                newEntry.content.isVisible = true
                entries.append(newEntry)
            }
        }

        print(entries.count)
        print(backQueueState.count)
        print(visibleEntriesState.count)
    }

    private func updateTransition() { }

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
