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

### Step 3: Enable Reference Line Display

In the PanoAlign tool properties:

1. Check **"Show Reference Lines"** - This will show your alignment guides as you position them

### Step 4: Position Vertical Reference Lines

The tool uses TWO vertical reference lines to calculate the proper alignment. Find features in your panorama that should be perfectly vertical in the real world:
- Door frames (best option)
- Building corners
- Wall edges
- Light poles
- Straight trees

Position the reference lines by dragging the on-screen crosshairs:

**Vertical Line 1 (GREEN)**:
1. Expand **"Vertical Line 1"** section in inspector
2. **Drag the crosshairs in the viewer** to place top and bottom points along a vertical feature
3. Alternatively, adjust the X/Y values in the inspector

**Vertical Line 2 (CYAN)**:
1. Expand **"Vertical Line 2"** section
2. **Drag the crosshairs** to place top and bottom points along a different vertical feature
3. Place this line far from the first line for better accuracy

**Tips**:
- Drag the crosshairs directly in the viewer for easiest positioning
- Use features that span the full vertical height if possible
- Space the two vertical lines far apart (opposite sides of panorama is ideal)
- Avoid objects with perspective distortion or near image poles (top/bottom)

### Step 5: Apply the Alignment

Once you've positioned both vertical reference lines:

1. Click the **"Apply"** button in the inspector
2. The tool calculates the pitch, yaw, and roll needed to align the image
3. The transformation is immediately applied to the output

Review the output:

1. Check if vertical features now appear straight up-and-down
2. Look at the calculated values displayed in the inspector:
   - **Calculated Yaw**: Left/right pan correction
   - **Calculated Pitch**: Up/down tilt correction
   - **Calculated Roll**: Rotation/tilt correction

### Step 6: Fine-Tune (Optional)

If the automatic calculation isn't perfect, you can add manual adjustments:

1. Expand **"Manual Offsets (Additive)"** section
2. Adjust the offset sliders (these are added to the calculated values):
   - **Pitch Offset**: Additional tilt up/down
   - **Yaw Offset**: Additional pan left/right
   - **Roll Offset**: Additional rotation clockwise/counter-clockwise
3. The final applied values are shown in the "Final Values" label
4. Click **"Reset Offsets"** button to clear all manual adjustments

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

### Example 1: Correcting Tilted Vertical Features

**Scenario**: Your 360 camera was tilted, making vertical structures appear slanted.

**Solution**:
1. Find two vertical features (e.g., door frames, building corners)
2. Drag Vertical Line 1 crosshairs to align with the first vertical feature
3. Drag Vertical Line 2 crosshairs to align with the second vertical feature (far from the first)
4. Click "Apply" button
5. The tool calculates the pitch and roll correction to straighten vertical features

**Expected Result**: Vertical structures now appear straight up-and-down

### Example 2: Straightening Interior Architecture

**Scenario**: Indoor 360 photo with tilted walls.

**Solution**:
1. Find two vertical features (door frame, wall corner)
2. Drag Vertical Line 1 to align with the first feature
3. Drag Vertical Line 2 to align with a second feature on the opposite side
4. Click "Apply"
5. Tool calculates pitch, yaw, and roll to square up the room

**Expected Result**: Walls appear vertical and room appears level

### Example 3: Drone Panorama Alignment

**Scenario**: Aerial 360 panorama with tilted buildings.

**Solution**:
1. Find vertical structures (buildings, towers, trees)
2. Place Vertical Line 1 on one vertical structure
3. Place Vertical Line 2 on another vertical structure far away
4. Click "Apply"
5. Tool corrects the rotation and tilt

**Expected Result**: Aligned aerial view with vertical structures standing straight

## Reference Line Selection Tips

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

- **GREEN line**: Vertical Line 1
- **CYAN line**: Vertical Line 2
- **Crosshairs**: Draggable control points for positioning the lines

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
- Compare before/after: Toggle viewer between input and output nodes

## Common Issues and Solutions

### Issue: Lines don't look straight after alignment

**Possible Causes**:
- Reference lines weren't on truly vertical features
- The two vertical lines were too close together
- Equirectangular distortion near poles

**Solutions**:
- Choose different reference features that are truly vertical
- Space the two vertical lines farther apart (opposite sides of panorama)
- Use manual offset adjustments to fine-tune
- Click "Apply" again after repositioning reference lines

### Issue: Image looks overly rotated

**Possible Causes**:
- Incorrect reference line placement
- Source image already had corrections applied

**Solutions**:
- Double-check your reference line placement
- Verify the features you selected are truly vertical
- Check the calculated angle values to see if they seem reasonable
- Verify source image is raw, uncorrected equirectangular

### Issue: Vertical lines near top/bottom still look curved

**Explanation**: This is normal! Equirectangular projection naturally curves vertical lines near the poles. True vertical alignment is at the horizon level.

**Solution**: This is expected behavior. The tool aligns based on 3D geometry, not 2D appearance.

## Advanced Tips

### Iterative Refinement

For complex corrections:
1. First pass: Set initial vertical lines and click "Apply"
2. Review the result
3. Adjust reference lines if needed and click "Apply" again
4. Use manual offsets for final fine-tuning

### Outputting Correction Values

The tool outputs calculated angles. You can:
- Connect outputs to other nodes
- Use values in expressions elsewhere in Fusion
- Record values for batch processing similar images

### Performance Optimization

For faster workflow:
- Use a lower resolution proxy for initial alignment
- Position both reference lines before clicking "Apply"
- For high-resolution images, note the calculated angles and use the PanoAlignHelper script instead

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
