# PluginLayout

Plugin layout is a `UICollectionViewLayout` designed to have a specific layout configuration for each `UICollectionView`s section.

For each section, the layout asks it's `delegate` for a proper `Plugin` that will create proper `UICollectionViewLayoutAttributes` and contribute determining the final size of contents.

## Plugin

A `Plugin` is an object capable of generating and manipulating specific `UICollectionViewLayoutAttributes` elements inside a section.

## Effect 

An `Effect` is an object capable of manipulating a previously generated `UICollectionViewLayoutAttributes` during collection view scrolling, independently from whatever `Plugin` has originally generated it.

We can think the usual "sticky header / header pinning" of collection views and table views as an effect that is completely independent from *how* and *where* that attribute was originally placed by the plugin: the headers (or footers) with sticky effect will remain pinned to the top/bottom part of the collection regardless of their starting position.

Combining both `Plugin` and `Effect` objects can lead to completely new (and amazing) layouts that have "features" strictly isolated from each other and, more important, reusable in different contexts.

When applying more than one effect to an attribute, **the order of application is important** (TBD)


## Included Layouts

Each layout has to be intended as a single  `Plugin` that can be used with others and a complete `PluginLayout` subclass that's completely configured to work out of the box for all those cases where every single section of the app should have the same layout behavior.

Each layout has a generic `Delegate` property that must implement `UICollectionViewDelegateFlowLayout`. 

### FlowLayout

`FlowLayout` is a complete replacement for original `UICollectionViewFlowLayout`. It mimics the original Apple's behavior for each section, creating headers and footers like the original one.
The `FlowLayoutPlugin` is needed in all those cases where some sections of the collection view should keep the original flow layout behavior, while assigning a different plugin to the others.

The complete `FlowLayout` class may seem pointless, since in the end it's a reverse-engineered copy of the battle-tested `UICollectionViewFlowLayout`; however, it's fully compatible with `Effect`s and it should be used when a scrolling related layout effect is needed.

The `delegate` property of this plugin is the standard `UICollectionViewDelegateFlowLayout`.

### GridLayout

`GridLayoutPlugin` is a subclass of `FlowLayoutPlugin` where elements are placed following a grid.
Each element can take a fraction of available width (for vertical-scrolling layouts) or height (for horizontal-scrolling ones), while the other dimension is calculated according to a specific `aspectRatio` provided by delegate.

The `delegate` property of this plugin must implement two additional methods: 
```swift
func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, lineFractionAt indexPath: IndexPath) -> Int
```
Given a single *line* in the layout and taking into account the *spacing* between its items and section insets, this value is used to divide the total line space available (width on vertical layouts and height on horizontal ones) so that resulting value can be applied to single item's dimension. 

Example: in vertical scrolling layout, returning a value of `2` for every item will result in a two columns layout. A value of `1` will result in a `UITableView` style layout.  


```swift
func collectionView(_ collectionView: UICollectionView, layout: PluginLayout, aspectRatioAt indexPath: IndexPath) -> CGFloat
```

The desired aspect ratio of each item.
In vertical layouts, this value is used to calculate `height` of each item ( `width / ratio`)
In horizontal layouts, this value is used to calculate `width` of each item ( `height * ratio`)

### StaggeredLayout

### MosaicLayout

