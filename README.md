# PluginLayout

Plugin layout is a `UICollectionViewLayout` designed to have a specific layout configuration for each `UICollectionView`s section.

For each section, the layout asks it's `delegate` for a proper `Plugin` that will create proper `UICollectionViewLayoutAttributes` and contribute determining the final size of contents.


###Design your own `Plugin`


