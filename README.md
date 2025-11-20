# Pano Align - 360° Panorama Alignment Tool for Blackmagic Fusion

A Fuse tool for aligning 360-degree equirectangular (latlong) panoramic images in Blackmagic Fusion by defining horizontal and vertical reference lines.

## Features

- **Draggable On-Screen Points**: Drag points directly in the Fusion viewer to define vertical reference lines
- **Two Vertical Line Alignment**: Simple, intuitive alignment using two vertical references
- **Automatic Calculation**: Automatically calculates pitch, yaw, and roll corrections
- **Manual Override**: Fine-tune alignment with manual controls
- **Real-time Overlay**: See your reference lines and points overlaid on the image
- **Native Fusion Integration**: Works as a standard Fusion node

## Installation

### Method 1: User Fuses Folder (Recommended)

1. Locate your Fusion Fuses folder:
   - **Windows**: `C:\Users\[USERNAME]\AppData\Roaming\Blackmagic Design\Fusion\Fuses\`
   - **macOS**: `/Users/[USERNAME]/Library/Application Support/Blackmagic Design/Fusion/Fuses/`
   - **Linux**: `/home/[USERNAME]/.fusion/BlackmagicDesign/Fusion/Fuses/`

2. Copy `PanoAlign.fuse` to the Fuses folder

3. Restart Fusion or refresh the tools (Shift+F5)

### Method 2: PathMap

1. Place `PanoAlign.fuse` in any folder
2. In Fusion, go to `File > Preferences > Path Map`
3. Add the folder containing the Fuse to `Fuses:`
4. Restart Fusion

## Usage

### Basic Workflow

1. **Add the Tool**:
   - In Fusion, add the "Pano Align" tool from the Transform category
   - Connect your 360° equirectangular image to the Input

2. **Define Vertical Line 1**:
   - In the Fusion viewer, drag the on-screen crosshair controls
   - Place the top and bottom points along something that should be vertical
   - Example: Door frame, building corner, or wall edge
   - The line appears GREEN with YELLOW control points

3. **Define Vertical Line 2**:
   - Drag the second set of on-screen points
   - Place them on another vertical reference
   - Choose a feature far from the first line for better accuracy
   - The line appears CYAN with MAGENTA control points

4. **View Results**:
   - "Show Reference Lines" is enabled by default to see your guides
   - "Auto Calculate" automatically computes pitch/yaw/roll corrections
   - "Apply Correction" shows the aligned result in real-time

### Controls

#### Vertical Line 1
- **Top Point**: Drag in viewer to place top of first vertical reference
- **Bottom Point**: Drag in viewer to place bottom of first vertical reference
- Line appears GREEN with YELLOW control points

#### Vertical Line 2
- **Top Point**: Drag in viewer to place top of second vertical reference
- **Bottom Point**: Drag in viewer to place bottom of second vertical reference
- Line appears CYAN with MAGENTA control points

#### Manual Adjustments
- **Pitch**: Rotation around horizontal axis (-90° to +90°)
- **Yaw**: Rotation around vertical axis (-180° to +180°)
- **Roll**: Rotation around viewing axis (-180° to +180°)

#### Options
- **Show Reference Lines**: Display overlay lines on output
- **Auto Calculate**: Automatically calculate angles from reference lines
- **Apply Correction**: Apply the calculated correction to the image

### Outputs

- **Output**: The aligned panoramic image
- **Calculated Pitch**: Computed pitch angle
- **Calculated Yaw**: Computed yaw angle
- **Calculated Roll**: Computed roll angle

## Tips & Tricks

### Getting Good Results

1. **Choose Clear Vertical Features**:
   - Pick vertical lines that are clearly visible and unambiguous
   - Architectural elements (door frames, building corners, wall edges) work best
   - Avoid curved or distorted objects

2. **Space Lines Far Apart**:
   - Place the two vertical lines as far apart as possible
   - Lines close together reduce accuracy
   - Use features on opposite sides of the panorama if possible

3. **Use Full Height**:
   - Extend each vertical line from top to bottom of the feature
   - Longer lines give better accuracy than short segments

4. **Choose True Verticals**:
   - Select features that are truly vertical in the real world
   - Avoid slanted or perspective-distorted elements
   - Buildings, poles, and doorframes are ideal

### Workflow Integration

**Typical Node Flow**:
```
Loader (360 Image) → Pano Align → Color Correction → Saver
```

**With Additional Processing**:
```
Loader (360 Image) → Pano Align → Denoise → Sharpen → Color Grade → Saver
```

### Common Use Cases

1. **Camera Mounting Issues**: Fix cameras that weren't perfectly level
2. **Handheld 360 Shots**: Correct tilted handheld panoramas
3. **Drone Panoramas**: Align aerial 360 images
4. **Stitching Errors**: Fix alignment after panoramic stitching

## Technical Details

### How It Works

1. **Coordinate Conversion**:
   - Converts 2D equirectangular coordinates to 3D spherical coordinates
   - Maps reference lines to 3D vectors on a unit sphere

2. **Angle Calculation**:
   - Computes normal vectors from reference lines
   - Calculates pitch, yaw, and roll from normal vectors
   - Uses cross products and dot products for 3D geometry

3. **Image Transformation**:
   - Applies rotation matrices to each pixel
   - Performs inverse mapping to avoid gaps
   - Uses spherical coordinate transformation

### Coordinate System

- **Equirectangular**:
  - X: 0 (left) to 1 (right) → Longitude: -180° to +180°
  - Y: 0 (top) to 1 (bottom) → Latitude: +90° to -90°

- **Rotation Order**: Roll → Pitch → Yaw (for inverse transform)

## Limitations

- **Performance**: Processing is done per-pixel in Lua, which can be slow for high-resolution images
- **Interpolation**: Currently uses nearest-neighbor; bilinear would be smoother
- **Pole Distortion**: Extreme pitch angles near poles may show artifacts

## Future Enhancements

Potential improvements for future versions:

- [ ] GPU acceleration for real-time processing
- [ ] Bilinear/bicubic interpolation
- [ ] Interactive on-viewer point selection
- [ ] Multiple reference line support
- [ ] Automatic horizon detection
- [ ] Save/load presets
- [ ] Batch processing mode

## Troubleshooting

**Tool doesn't appear in Fusion**:
- Check Fuses folder location
- Restart Fusion
- Check Console for Lua errors

**Can't see the on-screen controls**:
- Make sure the Pano Align node is selected
- Check that you're viewing the output in a Viewer
- On-screen controls appear as crosshairs you can drag

**Alignment seems wrong**:
- Verify reference lines are on truly vertical features
- Make sure lines are spaced far apart
- Try manual mode to test values
- Check if image is truly equirectangular format

**Slow performance**:
- Expected for high-res images (Lua pixel processing)
- Consider downscaling for preview
- Turn off "Apply Correction" while adjusting points
- Use PanoAlignHelper.lua script for final high-res render

## License

MIT License - Feel free to modify and use in your projects

## Credits

Created for 360° panoramic image alignment in Blackmagic Fusion.

## Version History

- **1.0** (2025-11-20): Initial release
  - Two-point horizontal and vertical alignment
  - Manual override controls
  - Visual overlay
  - Auto-calculation of pitch/yaw/roll
