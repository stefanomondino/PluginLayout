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

### FlowLayout


