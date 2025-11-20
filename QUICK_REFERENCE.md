# Pano Align - Quick Reference Card

## 🎯 Quick Start

### Fuse Method (Visual, Slower)
1. Load panorama in Fusion
2. Add **Transform > Pano Align** node
3. Adjust reference points using sliders
4. ✅ Auto Calculate + Apply Correction

### Script Method (Fast, Manual)
1. Select your Loader node
2. Run **PanoAlignHelper.lua** script
3. Set reference points in dialog
4. Script creates aligned Transform3D node

---

## 📊 Reference Point Coordinates

### Normalized Coordinates (0.0 to 1.0)
```
(0.0, 0.0) ───────── (0.5, 0.0) ───────── (1.0, 0.0)
    │                     │                     │
    │         TOP/NORTH POLE (±90° lat)         │
    │                                            │
(0.0, 0.5) ───────── CENTER ─────────── (1.0, 0.5)
    │                EQUATOR (0° lat)            │
    │                                            │
(0.0, 1.0) ───────── (0.5, 1.0) ───────── (1.0, 1.0)
            BOTTOM/SOUTH POLE (-90° lat)
```

### Common Reference Points

**Horizon Line (Horizontal)**:
- Point 1: `(0.1, 0.5)` - Left horizon
- Point 2: `(0.9, 0.5)` - Right horizon

**Vertical Center (Vertical)**:
- Point 1: `(0.5, 0.2)` - Top center
- Point 2: `(0.5, 0.8)` - Bottom center

---

## 🎨 Overlay Colors (Fuse Only)

| Color | Element |
|-------|---------|
| 🔴 **RED** | Horizontal reference line |
| 🟡 **YELLOW** | Horizontal reference points |
| 🟢 **GREEN** | Vertical reference line |
| 🔵 **CYAN** | Vertical reference points |

---

## 🔧 Controls Reference

### Fuse Controls

| Control | Range | Description |
|---------|-------|-------------|
| **Horiz X1/Y1** | 0.0 - 1.0 | First point of horizontal line |
| **Horiz X2/Y2** | 0.0 - 1.0 | Second point of horizontal line |
| **Vert X1/Y1** | 0.0 - 1.0 | First point of vertical line |
| **Vert X2/Y2** | 0.0 - 1.0 | Second point of vertical line |
| **Pitch** | -90° to +90° | Up/down tilt (manual mode) |
| **Yaw** | -180° to +180° | Left/right rotation (manual mode) |
| **Roll** | -180° to +180° | Clockwise/CCW tilt (manual mode) |

### Checkboxes

- ☑️ **Show Reference Lines**: Display overlay
- ☑️ **Auto Calculate**: Calculate from reference lines
- ☑️ **Apply Correction**: Apply the transformation

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

## ✅ Good Reference Features

### Horizontal References
- ✅ Ocean/lake horizon
- ✅ Straight roads
- ✅ Building rooflines
- ✅ Table/counter edges
- ✅ Floor/ceiling lines

### Vertical References
- ✅ Door frames
- ✅ Building corners
- ✅ Straight poles
- ✅ Wall edges
- ✅ Window frames

---

## ❌ Poor Reference Features

### Avoid These
- ❌ Curved surfaces
- ❌ Sloped terrain
- ❌ Perspective-distorted lines
- ❌ Very short lines
- ❌ Objects near top/bottom poles

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
