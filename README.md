# Pano Align - 360° Panorama Alignment Tool for Blackmagic Fusion

A Fuse tool for aligning 360-degree equirectangular (latlong) panoramic images in Blackmagic Fusion by defining horizontal and vertical reference lines.

## Features

- **Visual Reference Lines**: Define horizontal and vertical reference lines directly on your panorama
- **Automatic Calculation**: Automatically calculates pitch, yaw, and roll corrections
- **Manual Override**: Fine-tune alignment with manual controls
- **Real-time Overlay**: See your reference lines overlaid on the image
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

2. **Define Horizontal Reference**:
   - Use the "Horizontal Reference Line" controls
   - Set two points that should be perfectly horizontal in the real world
   - Example: Along a horizon line, edge of a table, or floor line

3. **Define Vertical Reference**:
   - Use the "Vertical Reference Line" controls
   - Set two points that should be perfectly vertical in the real world
   - Example: Door frame, building corner, or wall edge

4. **View Results**:
   - Enable "Show Reference Lines" to see your alignment guides
   - Enable "Auto Calculate" to automatically compute corrections
   - Enable "Apply Correction" to see the aligned result

### Controls

#### Alignment Mode
- **Manual**: Use manual Pitch/Yaw/Roll sliders
- **Two Point**: Define alignment using reference lines
- **Preview**: View without applying correction

#### Horizontal Reference Line
- **Point 1 X/Y**: First point of horizontal reference (0-1 normalized coordinates)
- **Point 2 X/Y**: Second point of horizontal reference

#### Vertical Reference Line
- **Point 1 X/Y**: First point of vertical reference
- **Point 2 X/Y**: Second point of vertical reference

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

1. **Choose Clear Reference Lines**:
   - Pick lines that are clearly visible and unambiguous
   - Architectural elements (walls, floors, ceilings) work best
   - Avoid curved or distorted objects

2. **Use Distant References**:
   - Points far apart give better accuracy
   - Avoid points too close together

3. **Check Multiple References**:
   - If possible, verify with multiple horizontal or vertical elements
   - Adjust if references don't match

4. **Horizon Line is Best for Horizontal**:
   - If visible, the horizon is the most reliable horizontal reference
   - Otherwise, use building edges or floor lines

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

**Alignment seems wrong**:
- Verify reference lines are correct
- Try manual mode to test
- Check if image is truly equirectangular format

**Slow performance**:
- Expected for high-res images
- Consider downscaling for preview
- Apply at final render stage

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
