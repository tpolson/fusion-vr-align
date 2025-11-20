# Pano Align - Quick Reference Card

## 🎯 Quick Start

### Fuse Method (Visual, Interactive)
1. Load panorama in Fusion
2. Add **Transform > Pano Align** node
3. **Drag on-screen crosshairs** to place vertical reference lines
4. ✅ Auto Calculate + Apply Correction (enabled by default)

### Script Method (Fast, Manual)
1. Select your Loader node
2. Run **PanoAlignHelper.lua** script
3. Set reference points in dialog
4. Script creates aligned Transform3D node

---

## 📊 On-Screen Controls

### Draggable Crosshairs
- **Drag directly in Fusion viewer** to position points
- No need to manually enter coordinates!
- Place points by clicking and dragging the crosshair controls
- Crosshairs snap to features for easy alignment

### Visual Feedback
- 🟢 **GREEN line** with 🟡 **YELLOW points** = Vertical Line 1
- 🔵 **CYAN line** with 🔴 **MAGENTA points** = Vertical Line 2

### Positioning Tips
- Place top/bottom points along full height of vertical feature
- Space the two vertical lines far apart (opposite sides of pano if possible)
- Use the on-screen overlay to verify line placement

---

## 🎨 Overlay Colors

| Color | Element |
|-------|---------|
| 🟢 **GREEN** | Vertical Line 1 |
| 🟡 **YELLOW** | Vertical Line 1 control points |
| 🔵 **CYAN** | Vertical Line 2 |
| 🔴 **MAGENTA** | Vertical Line 2 control points |

---

## 🔧 Controls Reference

### On-Screen Controls (Drag in Viewer)

| Control | Description |
|---------|-------------|
| **Vertical Line 1 - Top Point** | Drag to place top of first vertical reference |
| **Vertical Line 1 - Bottom Point** | Drag to place bottom of first vertical reference |
| **Vertical Line 2 - Top Point** | Drag to place top of second vertical reference |
| **Vertical Line 2 - Bottom Point** | Drag to place bottom of second vertical reference |

### Manual Adjustments (Inspector Panel)

| Control | Range | Description |
|---------|-------|-------------|
| **Pitch** | -90° to +90° | Up/down tilt (manual mode) |
| **Yaw** | -180° to +180° | Left/right rotation (manual mode) |
| **Roll** | -180° to +180° | Clockwise/CCW tilt (manual mode) |

### Options

- ✅ **Show Reference Lines**: Display overlay (default: ON)
- ✅ **Auto Calculate**: Calculate from reference lines (default: ON)
- ✅ **Apply Correction**: Apply the transformation (default: ON)

---

## 📐 Rotation Angles Explained

### Pitch
```
Positive (+): Camera tilted UP
    ↗ Looking toward sky/ceiling

Negative (-): Camera tilted DOWN
    ↘ Looking toward ground/floor

Range: -90° (straight down) to +90° (straight up)
```

### Yaw
```
Positive (+): Rotated RIGHT
    → Pans to the right

Negative (-): Rotated LEFT
    ← Pans to the left

Range: -180° to +180° (wraps around)
```

### Roll
```
Positive (+): Rotated CLOCKWISE
    ⟳ Like tilting head to right shoulder

Negative (-): Rotated COUNTER-CLOCKWISE
    ⟲ Like tilting head to left shoulder

Range: -180° to +180°
```

---

## ✅ Good Vertical Reference Features

### Best Choices
- ✅ Door frames (full height)
- ✅ Building corners (sharp edges)
- ✅ Straight poles or posts
- ✅ Wall edges
- ✅ Window frames (vertical sides)
- ✅ Columns or pillars
- ✅ Straight trees

### Selection Tips
- Choose features that span significant vertical distance
- Pick features far apart (opposite sides of panorama)
- Select clearly visible, unambiguous edges

---

## ❌ Poor Reference Features

### Avoid These
- ❌ Curved surfaces
- ❌ Slanted or leaning objects
- ❌ Perspective-distorted lines
- ❌ Very short vertical segments
- ❌ Objects near top/bottom poles (extreme distortion)
- ❌ Blurry or unclear edges

---

## 🚀 Performance Tips

### For Preview
1. Use **Fuse** with visual overlay
2. Work at half resolution
3. Disable "Apply Correction" while adjusting

### For Final Render
1. Note angles from Fuse
2. Switch to full resolution
3. Use **Script** to create Transform3D
4. Render with GPU acceleration

### Resolution Guidelines

| Resolution | Fuse Speed | Recommended Method |
|------------|------------|--------------------|
| ≤ 2K | Fast (~1-2s) | ✅ Fuse |
| 4K | Slow (~30-60s) | ⚠️ Script preferred |
| 8K+ | Very slow (>2min) | ❌ Script only |

---

## 🔍 Troubleshooting

### Lines don't look straight after alignment
- ✅ Check reference line placement
- ✅ Ensure features are truly horizontal/vertical
- ✅ Space points farther apart

### Image looks over-rotated
- ✅ Verify source is uncorrected equirectangular
- ✅ Try manual mode to check angles
- ✅ Reselect reference features

### Tool is very slow
- ✅ Reduce resolution for preview
- ✅ Use Script method instead
- ✅ Disable overlay while rendering

### Tool doesn't appear in Fusion
- ✅ Check Fuses folder location
- ✅ Restart Fusion
- ✅ Check Console for errors
- ✅ Verify `.fuse` extension (not `.fuse.txt`)

---

## 📁 File Locations

### Windows
```
%APPDATA%\Blackmagic Design\Fusion\Fuses\
```

### macOS
```
~/Library/Application Support/Blackmagic Design/Fusion/Fuses/
```

### Linux
```
~/.fusion/BlackmagicDesign/Fusion/Fuses/
```

---

## 🎬 Typical Workflows

### Basic Alignment
```
[Loader] → [Pano Align] → [Viewer]
```

### Production Pipeline
```
[Loader] → [Pano Align] → [Color Correct] → [Sharpen] → [Saver]
```

### Comparison View
```
         ┌─→ [Viewer 1] (Original)
[Loader] ┤
         └─→ [Pano Align] → [Viewer 2] (Aligned)
```

### VR Export
```
[Loader] → [Pano Align] → [Pano to Cubemap] → [Saver]
```

---

## 🔑 Keyboard Shortcuts (In Viewer)

| Action | Shortcut |
|--------|----------|
| Zoom In/Out | Mouse wheel |
| Pan image | Middle mouse drag |
| Reset view | `Ctrl+F` |
| Fit to view | `F` |
| Show controls | Select node + `Ctrl+Shift+D` |

---

## 💡 Pro Tips

1. **Use Horizon First**: If visible, align horizon before verticals
2. **Work in Pairs**: Set horizontal, then vertical, then recheck
3. **Save Presets**: Right-click node → Save Default for similar images
4. **Batch Similar**: Note angles, apply manually to series
5. **Verify with Grid**: Overlay a grid to check alignment

---

## 📚 Quick Links

- **Full Manual**: See `README.md`
- **Installation**: See `INSTALL.md`
- **Detailed Guide**: See `USAGE_GUIDE.md`
- **Technical Info**: See `TECHNICAL_NOTES.md`

---

## 🆘 Getting Help

**Issues Checklist**:
1. Is your input equirectangular format?
2. Are reference lines on correct features?
3. Are points far enough apart?
4. Have you restarted Fusion after installing?
5. Any errors in Fusion Console?

**For More Help**:
- Check documentation files
- Verify Fusion version compatibility
- Check community forums

---

**Version 1.0** | For Blackmagic Fusion 9+ | MIT License
