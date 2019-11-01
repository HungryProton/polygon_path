# Polygon Path

![polygon_path](https://user-images.githubusercontent.com/52043844/63334538-ec82e980-c33b-11e9-9fcb-2b465641fb5b.png)

A curve node constrained on a 3D plane with the following features :
- Better visualization compared to the built in Path node
- Holds a 2D polygon representation of the curve. Polygon resolution is exposed
- Check if a 3D point is inside or outside the curve. (3D position is projected to the path plane before the check)

[See it in action here](https://streamable.com/z2jfz)

##  Disclaimer

This addon is still a **work in progress** and is **not** considered production ready

## Installation

- Clone this repository to you addons folder
- Enable the plugin from Godot (Project Settings -> Plugins -> Set gm_path to active)

## How to use

- Add a PolygonPath node to your scene
- When a PolygonPath is selected, new controls will appear on top of the viewport
- 3 modes are available
  + First button is the Select mode, allows you to move the handles
  + Second button is the Add mode, clicking on the plane will add a new point at the end of the path
  + Third button is the Remove mode
- The Close curve button (Not working yet) closes the loop
- The Show polygon button display the internal polygon generated fom the path. The is_inside method relies on this polygon for the calculations.
- The Show Grid button display the plane where the path is constrained to.

## Licence

Unless stated otherwise, the content of this project is available under the MIT
licence. Note that some icons (namely the select, create and delete curve point)
comes from the GodotEngine editor and are distributed under the CC-BY 4.0
licence
