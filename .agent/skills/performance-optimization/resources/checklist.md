# Performance Checklist

Use this checklist when reviewing code for performance issues.

## Widget Tree
- [ ] All static widgets use `const` constructors
- [ ] Complex subtrees are extracted into separate `StatelessWidget` classes (not helper methods)
- [ ] `RepaintBoundary` wraps isolated animation areas
- [ ] No expensive operations in `build()` method

## Lists
- [ ] Using `ListView.builder` (not `ListView` with `children`)
- [ ] `itemExtent` specified for fixed-height items
- [ ] Large lists use pagination (load more on scroll)
- [ ] Items use `const` constructors where possible

## State Management
- [ ] `context.select()` used for single-field reads
- [ ] `Consumer` used with `child` parameter for mixed static/dynamic trees
- [ ] `context.read()` used for one-shot actions (not in build)
- [ ] `notifyListeners()` called once per state change (using `finally`)
- [ ] No `context.watch()` in large widget trees

## Images
- [ ] `CachedNetworkImage` used for all remote images
- [ ] Asset images provided in 1x, 2x, 3x resolutions
- [ ] `memCacheHeight`/`memCacheWidth` set for large images
- [ ] SVGs used for icons and simple graphics

## Memory
- [ ] All controllers disposed in `dispose()`
- [ ] Stream subscriptions cancelled in `dispose()`
- [ ] Timers cancelled in `dispose()`
- [ ] No circular references between objects

## Startup
- [ ] Non-critical initialization deferred to `addPostFrameCallback`
- [ ] Heavy services use `late` initialization
- [ ] Splash screen covers async initialization time
