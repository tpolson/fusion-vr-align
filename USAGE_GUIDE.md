# Pano Align - Usage Guide

## Step-by-Step Tutorial

### Step 1: Load Your Panorama

1. Add a **Loader** node to your flow
2. Load your 360° equirectangular panorama image
3. Verify it's in latlong/equirectangular format (should look like a stretched world map)

### Step 2: Add Pano Align Tool

1. Right-click in the Flow area
2. Navigate to **Transform > Pano Align**
3. Connect your Loader to the PanoAlign Input

### Step 3: Enable Preview Mode

In the PanoAlign tool properties:

1. Check **"Show Reference Lines"** - This will show your alignment guides
2. Check **"Auto Calculate"** - Automatically compute corrections
3. Check **"Apply Correction"** - Apply the alignment

### Step 4: Define Horizontal Reference

Find something in your panorama that should be perfectly horizontal in the real world:
- Horizon line (best option if visible)
- Table edge
- Floor/ceiling line
- Window sill

Set the horizontal reference:

1. Expand **"Horizontal Reference Line"** section
2. Adjust **Point 1 X** and **Point 1 Y** to place first point on your horizontal reference
3. Adjust **Point 2 X** and **Point 2 Y** to place second point on the same horizontal line

**Tips**:
- Spread points far apart for better accuracy
- Both points should be on the same real-world horizontal line
- The line will appear RED in the overlay

### Step 5: Define Vertical Reference

Find something that should be perfectly vertical:
- Door frame
- Building corner
- Wall edge
- Light pole

Set the vertical reference:

1. Expand **"Vertical Reference Line"** section
2. Adjust **Point 1 X** and **Point 1 Y** to place first point on your vertical reference
3. Adjust **Point 2 X** and **Point 2 Y** to place second point on the same vertical line

**Tips**:
- Use something that goes from floor to ceiling if possible
- Avoid objects with perspective distortion
- The line will appear GREEN in the overlay

### Step 6: Review the Alignment

The tool automatically calculates and applies the correction. Review the output:

1. Check if horizontal lines now appear level
2. Check if vertical lines now appear straight up-and-down
3. Look at the calculated values:
   - **Calculated Pitch**: Up/down tilt
   - **Calculated Yaw**: Left/right pan
   - **Calculated Roll**: Rotation/tilt

### Step 7: Fine-Tune (Optional)

If automatic calculation isn't perfect:

1. Uncheck **"Auto Calculate"**
2. Expand **"Manual Adjustments"**
3. Adjust:
   - **Pitch**: Tilt up/down
   - **Yaw**: Pan left/right
   - **Roll**: Rotate clockwise/counter-clockwise

## Understanding the Coordinate System

### Normalized Coordinates (0 to 1)

The reference points use normalized coordinates:

```
(0, 0) = Top-left corner
(0.5, 0.5) = Center of image
(1, 1) = Bottom-right corner
```

### Equirectangular Mapping

```
X-axis (horizontal):
  0.0 = -180° longitude (leftmost)
  0.5 = 0° longitude (center)
  1.0 = +180° longitude (rightmost, wraps to -180°)

Y-axis (vertical):
  0.0 = +90° latitude (top, north pole)
  0.5 = 0° latitude (equator)
  1.0 = -90° latitude (bottom, south pole)
```

## Practical Examples

### Example 1: Correcting a Tilted Horizon

**Scenario**: Your 360 camera was tilted forward, making the horizon appear curved.

**Solution**:
1. Find the horizon line in your pano
2. Place horizontal reference Point 1 at left side of horizon (e.g., X=0.1, Y=0.45)
3. Place horizontal reference Point 2 at right side of horizon (e.g., X=0.9, Y=0.55)
4. Place vertical reference on any vertical structure
5. The tool calculates the pitch correction to level the horizon

**Expected Result**: Horizon becomes a straight horizontal line at the equator

### Example 2: Straightening Interior Architecture

**Scenario**: Indoor 360 photo with tilted walls and ceiling lines.

**Solution**:
1. Find a ceiling line or floor line
2. Set horizontal reference along this line
3. Find a door frame or wall corner
4. Set vertical reference along this vertical edge
5. Tool calculates pitch, yaw, and roll to square up the room

**Expected Result**: Walls appear vertical, floor/ceiling appear horizontal

### Example 3: Drone Panorama Alignment

**Scenario**: Aerial 360 panorama with rotated horizon.

**Solution**:
1. Identify the horizon line
2. Set horizontal reference across the horizon
3. Find a vertical structure (building, tower, tree)
4. Set vertical reference on that structure
5. Tool corrects the rotation and tilt

**Expected Result**: Aligned aerial view with level horizon

## Reference Line Selection Tips

### Good Horizontal References:
✅ Ocean/lake horizon
✅ Straight roads extending to horizon
✅ Building rooflines against sky
✅ Table tops or counters
✅ Window sills

### Poor Horizontal References:
❌ Curved surfaces
❌ Sloped terrain
❌ Perspective-distorted lines
❌ Very short lines

### Good Vertical References:
✅ Door frames
✅ Building corners
✅ Light poles or flagpoles
✅ Straight trees
✅ Wall edges

### Poor Vertical References:
❌ Leaning objects
❌ Curved structures
❌ Short lines
❌ Objects near image poles (top/bottom)

## Overlay Colors

When "Show Reference Lines" is enabled:

- **RED line**: Horizontal reference
- **YELLOW crosses**: Horizontal reference points
- **GREEN line**: Vertical reference
- **CYAN crosses**: Vertical reference points

## Workflow Integration

### Basic Flow:
```
[Loader] → [Pano Align] → [Viewer]
```

### Production Flow:
```
[Loader] → [Pano Align] → [Color Corrector] → [Sharpen] → [Saver]
```

### Comparison Flow:
```
             ┌→ [Viewer 1] (Original)
[Loader] ────┤
             └→ [Pano Align] → [Viewer 2] (Aligned)
```

## Keyboard Shortcuts While Adjusting

- Use the viewer's zoom to see details: Mouse wheel or Ctrl+drag
- Pan around the image: Middle mouse button drag
- Reset view: Ctrl+F
- Compare before/after: Disable/enable "Apply Correction"

## Common Issues and Solutions

### Issue: Lines don't look straight after alignment

**Possible Causes**:
- Reference lines weren't on truly horizontal/vertical features
- Points too close together
- Equirectangular distortion near poles

**Solutions**:
- Choose different reference features
- Space points farther apart
- Use manual adjustment to fine-tune

### Issue: Image looks overly rotated

**Possible Causes**:
- Incorrect reference line placement
- Source image already had corrections applied

**Solutions**:
- Double-check your reference points
- Try manual mode to see actual angles
- Verify source image is raw, uncorrected equirectangular

### Issue: Vertical lines near top/bottom still look curved

**Explanation**: This is normal! Equirectangular projection naturally curves vertical lines near the poles. True vertical alignment is at the horizon level.

**Solution**: This is expected behavior. The tool aligns based on 3D geometry, not 2D appearance.

## Advanced Tips

### Using Multiple Passes

For complex corrections:
1. First pass: Correct major roll using horizon
2. Second pass: Fine-tune pitch using vertical references

### Outputting Correction Values

The tool outputs calculated angles. You can:
- Connect outputs to other nodes
- Use values in expressions elsewhere in Fusion
- Record values for batch processing similar images

### Performance Optimization

For faster preview:
- Use a lower resolution proxy
- Disable "Apply Correction" while adjusting reference lines
- Enable correction only for final render

### Integration with Fusion's Pano Tools

The aligned output works perfectly with:
- **Equirectangular to Cubemap** conversion
- **Pano Map** for further transformations
- **Camera 3D** for VR viewing

## Saving Your Work

### Method 1: Bake the Correction
1. Add a **Saver** node after Pano Align
2. Render to create a corrected panorama file
3. Use the corrected file in other projects

### Method 2: Save Composition
1. Save your Fusion comp with Pano Align settings
2. Reference or duplicate for similar images
3. Adjust reference points for each new image

### Method 3: Export Settings
1. Note the calculated Pitch/Yaw/Roll values
2. Use manual mode with these values on similar images
3. Fine-tune as needed

## Questions?

If you encounter issues:
1. Check that your input is equirectangular format
2. Verify reference lines are on appropriate features
3. Try manual mode to understand the corrections being applied
4. Check the Fusion console for any error messages

Happy aligning! 🎬
