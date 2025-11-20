# Technical Notes - Pano Align

## Architecture Overview

This project provides two approaches for panoramic image alignment in Blackmagic Fusion:

### 1. PanoAlign.fuse - Fuse Plugin (Complete but Slower)
- **Type**: Custom Fuse node
- **Language**: Lua
- **Processing**: Per-pixel transformation in Lua
- **Performance**: Slow for high-resolution images
- **Features**: Complete standalone solution with visual overlay

### 2. PanoAlignHelper.lua - Script Helper (Fast but Requires Native Nodes)
- **Type**: Lua script
- **Language**: Lua
- **Processing**: Uses Fusion's native nodes (Transform3D or Pano Map)
- **Performance**: Fast, real-time performance
- **Features**: Calculator + node setup automation

## Which One Should You Use?

### Use PanoAlign.fuse when:
- ✅ You want a single, self-contained tool
- ✅ You need visual overlay of reference lines
- ✅ You're working with preview-resolution images
- ✅ You want to save tool presets
- ✅ You need a consistent workflow across projects

### Use PanoAlignHelper.lua when:
- ✅ You're working with high-resolution images (4K+)
- ✅ You need real-time performance
- ✅ You're comfortable working with multiple nodes
- ✅ You want to leverage Fusion's GPU acceleration
- ✅ You need to batch process multiple images

### Use Both:
- ✅ Use Fuse for preview and reference line placement
- ✅ Note the calculated angles
- ✅ Use Helper script with those angles for final render

## Mathematical Foundation

### Coordinate Systems

#### 1. Equirectangular (Latlong) Coordinates
```
2D Image Space:
  x ∈ [0, width]   →  Longitude ∈ [-180°, +180°]
  y ∈ [0, height]  →  Latitude ∈ [+90°, -90°]

Normalization:
  nx = x / width        ∈ [0, 1]
  ny = y / height       ∈ [0, 1]

Spherical:
  lon = (nx - 0.5) × 360°    ∈ [-180°, +180°]
  lat = (0.5 - ny) × 180°    ∈ [+90°, -90°]
```

#### 2. 3D Cartesian (Unit Sphere)
```
From spherical (lon, lat) to Cartesian (x, y, z):
  x = cos(lat) × sin(lon)
  y = sin(lat)
  z = cos(lat) × cos(lon)

Where the sphere has radius = 1
```

### Alignment Calculation

#### Algorithm

Given two reference lines defined by 4 points:
- Horizontal: (hx1, hy1) to (hx2, hy2)
- Vertical: (vx1, vy1) to (vx2, vy2)

**Step 1**: Convert all points to 3D vectors on unit sphere
```lua
v1 = SphericalToVector(lon1, lat1)
v2 = SphericalToVector(lon2, lat2)
```

**Step 2**: Calculate normal to horizontal plane
```lua
normal = normalize(cross(v1, v2))
```

**Step 3**: Extract Euler angles

**Pitch** (rotation around X-axis):
```lua
pitch = arcsin(normal.y)
```

**Roll** (rotation around Z-axis):
```lua
roll = arctan2(latDiff, lonDiff)
where:
  latDiff = lat2 - lat1
  lonDiff = lon2 - lon1
```

**Yaw** (rotation around Y-axis):
```lua
yaw = -avg(lon1, lon2)
```

### Rotation Application

#### Rotation Matrices

**Pitch (X-axis rotation)**:
```
| 1    0         0      |
| 0  cos(p)  -sin(p)    |
| 0  sin(p)   cos(p)    |
```

**Yaw (Y-axis rotation)**:
```
| cos(y)   0   sin(y)   |
|   0      1      0     |
| -sin(y)  0   cos(y)   |
```

**Roll (Z-axis rotation)**:
```
| cos(r)  -sin(r)  0    |
| sin(r)   cos(r)  0    |
|   0        0     1    |
```

#### Combined Rotation

For each pixel at (x, y):
1. Convert to spherical (lon, lat)
2. Convert to 3D vector v
3. Apply rotations: v' = R_yaw × R_pitch × R_roll × v
4. Convert v' back to spherical (lon', lat')
5. Convert to pixel coordinates (x', y')
6. Sample source image at (x', y')

**Important**: Use inverse mapping to avoid gaps:
- For each output pixel, calculate which source pixel it comes from
- This is the reverse of forward mapping

## Performance Analysis

### Fuse Performance

**Time Complexity**: O(width × height)

For a 4K equirectangular (4096 × 2048):
- **Pixels to process**: 8,388,608
- **Operations per pixel**: ~50-100 (trigonometry, matrix multiply, interpolation)
- **Estimated time** (Lua): 30-120 seconds per frame

**Bottlenecks**:
- Lua interpreted execution
- No SIMD/vectorization
- Per-pixel trigonometry
- No GPU acceleration

### Script + Native Nodes Performance

**Time Complexity**: O(1) - GPU accelerated

For the same 4K image:
- **Calculation time**: < 0.1 seconds (angle calculation)
- **Rendering time**: Real-time (GPU)
- **Total time**: < 1 second

**Advantages**:
- GPU-accelerated transformation
- Optimized C++ code
- Hardware interpolation
- Cached operations

## Optimization Strategies

### For Fuse (If You Must Use It)

#### 1. Resolution Downscaling
```lua
-- In Process() function
if img.Width > 2048 then
    img = img:Resize(2048, 1024)
end
```

#### 2. Lazy Calculation
Only recalculate when parameters change:
```lua
local needsRecalc = false
-- Check if any input changed
if autoCalculate and (hx1 ~= lastHX1 or ...) then
    needsRecalc = true
end
```

#### 3. LUT-Based Transformation
Pre-calculate transformation map:
```lua
-- Build lookup table once
local lutX = {}
local lutY = {}
-- Fill LUT...
-- Reuse for multiple frames
```

### For Better Performance Overall

**Recommended Pipeline**:
```
1. Load low-res proxy (e.g., 1920×960)
2. Use Fuse for interactive alignment
3. Note calculated angles
4. Switch to full-res source
5. Use Helper script to create Transform3D
6. Render with GPU acceleration
```

## Integration with Fusion's Native Nodes

### Using Transform3D

The Transform3D node can handle 3D rotations:
```lua
transform = comp:AddTool("Transform3D")
transform.Input:ConnectTo(loader)
transform.XRotation[1] = pitch
transform.YRotation[1] = yaw
transform.ZRotation[1] = roll
```

**Pros**:
- GPU accelerated
- Real-time preview
- Keyframeable

**Cons**:
- May not respect equirectangular projection perfectly
- Potential edge wrapping issues

### Using Pano Map

The Pano Map node is designed for panoramic transformations:
```lua
panomap = comp:AddTool("PanoMap")
panomap.Input:ConnectTo(loader)
-- Parameter names may vary by Fusion version
panomap.Pitch[1] = pitch
panomap.Yaw[1] = yaw
panomap.Roll[1] = roll
```

**Pros**:
- Designed for equirectangular
- Handles wrapping correctly
- GPU accelerated

**Cons**:
- Parameter names vary between Fusion versions
- May have different rotation order

### Using Kartographer (If Available)

Some Fusion installations include Kartographer plugins for VR/360:
- Check for KartaVR toolset
- May provide specialized pano alignment tools

## Accuracy Considerations

### Sources of Error

1. **Reference Line Placement**:
   - User accuracy in point selection: ±2-5 pixels
   - Impact: ±0.1° to ±0.5° depending on image resolution

2. **Floating Point Precision**:
   - Lua uses double precision (64-bit)
   - Sufficient for sub-degree accuracy

3. **Interpolation**:
   - Nearest neighbor: Blocky artifacts
   - Bilinear: Slight blur
   - Bicubic: Best quality, slower

4. **Gimbal Lock**:
   - Occurs near ±90° pitch
   - Euler angles become ambiguous
   - Use quaternions for extreme cases (not implemented)

### Improving Accuracy

**Best Practices**:
1. Use reference lines far apart (>50% of image width/height)
2. Choose clear, unambiguous features
3. Verify with multiple reference lines
4. Cross-check horizontal with horizon if visible
5. Use multiple frames if camera was stationary

## Future Enhancements

### Short Term (Fuse Improvements)
- [ ] Bilinear interpolation
- [ ] Cached transformation maps
- [ ] Multi-threaded processing (if possible in Fusion Lua)
- [ ] Interactive on-screen controls

### Medium Term (New Features)
- [ ] Automatic horizon detection (image processing)
- [ ] Machine learning-based alignment
- [ ] Batch processing mode
- [ ] Preset library for common cameras

### Long Term (Major Refactoring)
- [ ] C++ plugin for speed
- [ ] OpenCL/CUDA GPU implementation
- [ ] Real-time interactive overlay in viewer
- [ ] Integration with VR preview

## Known Limitations

### Fuse Version
1. **Performance**: Slow for high-res images (inherent to Lua)
2. **Interpolation**: Basic nearest-neighbor only
3. **Memory**: Loads entire image into memory
4. **Overlay**: Simple line drawing (no anti-aliasing)

### Script Version
1. **No Visual Overlay**: Can't see reference lines
2. **Manual Input**: Must estimate coordinates
3. **Node Dependency**: Requires compatible native nodes
4. **Version Specific**: Pano Map parameters vary by Fusion version

### Mathematical Limitations
1. **Gimbal Lock**: Euler angles fail near ±90° pitch
2. **Pole Artifacts**: Equirectangular distortion at poles
3. **Assumption**: Assumes input is perfect equirectangular
4. **No Lens Correction**: Doesn't handle optical distortion

## Debugging Tips

### Verify Calculations
```lua
-- Add to script
print(string.format("Pitch: %.3f°", pitch))
print(string.format("Yaw: %.3f°", yaw))
print(string.format("Roll: %.3f°", roll))
```

### Check Reference Vectors
```lua
-- Print 3D vectors
print(string.format("Vec1: (%.3f, %.3f, %.3f)", v.x, v.y, v.z))
-- Should be normalized: length ≈ 1.0
```

### Validate Angles
- Pitch should be [-90°, +90°]
- Yaw should be [-180°, +180°]
- Roll should be [-180°, +180°]

### Test Cases
1. **Horizontal horizon** → Pitch ≈ 0°, Roll ≈ 0°
2. **Centered vertical** → Yaw ≈ 0°
3. **45° tilt** → Roll ≈ 45°

## References

### Mathematical Resources
- "Multiple View Geometry in Computer Vision" by Hartley & Zisserman
- "Rotation representations" - Euler angles vs quaternions
- Equirectangular projection: https://en.wikipedia.org/wiki/Equirectangular_projection

### Fusion Documentation
- Fusion Scripting Guide (Lua API)
- Fuse Plugin Developer Guide
- VRWiki: 360 Video Workflows

### Related Tools
- PTGui - Photo stitching with alignment
- Hugin - Panorama stitching software
- KartaVR - Fusion VR toolset

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Areas for improvement:
- Performance optimization
- Better interpolation
- GPU acceleration
- Additional alignment methods
- Automatic feature detection

---

**Version**: 1.0
**Last Updated**: 2025-11-20
**Compatibility**: Fusion 9+, DaVinci Resolve 15+
