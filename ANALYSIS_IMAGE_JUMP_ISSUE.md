# Image Position Jump Issue - Detailed Analysis
## Fusion VR Align Tool (PanoAlign.fuse)

---

## Problem Statement
An image momentarily appears in the correct position, then jumps to an incorrect position when loading default values.

---

## Code Structure Analysis

### 1. DEFAULT VALUES AND INITIALIZATION

**File**: `/home/user/fusion-vr-align/PanoAlign.fuse` (lines 40-168)

Default Input Values:
```lua
-- Vertical Line 1
INP_DefaultX = 0.3, INP_DefaultY = 0.2  -- Top point
INP_DefaultX = 0.3, INP_DefaultY = 0.8  -- Bottom point

-- Vertical Line 2  
INP_DefaultX = 0.7, INP_DefaultY = 0.2  -- Top point
INP_DefaultX = 0.7, INP_DefaultY = 0.8  -- Bottom point

-- Internal Stored Angles
InApplied:       INP_Default = 0      (False)
InStoredPitch:   INP_Default = 0      (No rotation)
InStoredYaw:     INP_Default = 0      (No rotation)
InStoredRoll:    INP_Default = 0      (No rotation)

-- Manual Offsets
InPitchOffset:   INP_Default = 0.0
InYawOffset:     INP_Default = 0.0
InRollOffset:    INP_Default = 0.0
```

**Key Insight**: On first load, all rotation values are 0, so NO transformation should be applied.

---

### 2. PROCESS FUNCTION FLOW (Lines 310-389)

This is the critical rendering function called every frame:

```lua
function Process(req)
    -- Get applied flag (line 313)
    local applied = InApplied:GetValue(req).Value == 1
    
    -- IF Apply button was just clicked (line 334)
    if applied then
        -- Calculate angles from reference points
        local calcPitch, calcYaw, calcRoll = CalculateAlignmentFromVerticals(...)
        
        -- CRITICAL: Store calculated angles (lines 342-344)
        InStoredPitch:SetSource(Number(calcPitch), req.Time)
        InStoredYaw:SetSource(Number(calcYaw), req.Time)
        InStoredRoll:SetSource(Number(calcRoll), req.Time)
        
        -- CRITICAL: Reset Applied flag (line 356)
        InApplied:SetSource(Number(0), req.Time)
    end
    
    -- Get stored angles (lines 360-362)
    local storedPitch = InStoredPitch:GetValue(req).Value
    local storedYaw = InStoredYaw:GetValue(req).Value
    local storedRoll = InStoredRoll:GetValue(req).Value
    
    -- Get manual offsets (lines 364-366)
    local pitchOffset = InPitchOffset:GetValue(req).Value
    local yawOffset = InYawOffset:GetValue(req).Value
    local rollOffset = InRollOffset:GetValue(req).Value
    
    -- Calculate final values (lines 369-371)
    local finalPitch = storedPitch + pitchOffset
    local finalYaw = storedYaw + yawOffset
    local finalRoll = storedRoll + rollOffset
    
    -- CRITICAL: Apply transformation if ANY angle is non-zero (lines 378-380)
    if storedPitch ~= 0 or storedYaw ~= 0 or storedRoll ~= 0 or 
       pitchOffset ~= 0 or yawOffset ~= 0 or rollOffset ~= 0 then
        result = ApplyPanoCorrection(img, -finalPitch, -finalYaw, -finalRoll, req)
    end
end
```

---

### 3. TRANSFORMATION APPLICATION (ApplyPanoCorrection, lines 392-466)

**Key points**:
- Applies 3D rotation matrices to panoramic image pixels
- Uses **inverse angles** (`-finalPitch, -finalYaw, -finalRoll`)
- Processes equirectangular panoramic images
- Rotation order: **Yaw (Y-axis) → Pitch (X-axis) → Roll (Z-axis)**

The panoramic transformation:
1. Converts each output pixel to spherical coordinates (longitude, latitude)
2. Converts to 3D unit vector on sphere
3. Applies rotation matrices in correct order
4. Converts back to spherical coordinates
5. Samples source image at rotated location

---

### 4. BUTTON CALLBACK (NotifyChanged, lines 201-212)

```lua
function NotifyChanged(inp, param, time)
    if inp == InApplyButton then
        -- Set Applied flag to 1 (triggers calculation next frame)
        InApplied:SetSource(Number(1), time)
    elseif inp == InResetButton then
        -- Reset all offsets to zero
        InPitchOffset:SetSource(Number(0), time)
        InYawOffset:SetSource(Number(0), time)
        InRollOffset:SetSource(Number(0), time)
    end
end
```

---

## ROOT CAUSE ANALYSIS

### Identified Issues:

#### 1. **SetSource Cascading and Race Conditions**
**Lines**: 342-344, 356

**Problem**: `SetSource()` modifies parameters asynchronously in Fusion. Each call may trigger another `Process()` invocation.

**Sequence that causes the jump**:
```
Time T1: User clicks "Apply"
  → NotifyChanged() sets InApplied = 1
  → Triggers next frame render

Time T2: Process() executes with applied = 1
  → Calculates pitch, yaw, roll from points
  → Calls InStoredPitch:SetSource() (doesn't take effect yet)
  → Calls InStoredYaw:SetSource()  (doesn't take effect yet)
  → Calls InStoredRoll:SetSource() (doesn't take effect yet)
  → Calls InApplied:SetSource(0)   (doesn't take effect yet)
  → Reads stored angles: Still ZERO because SetSource is async!
  → Applies transformation with zero angles = NO CHANGE
  → Image appears CORRECT momentarily

Time T3: Fusion updates parameters from SetSource calls
  → Stored angles NOW have calculated values
  → Triggers another Process() call

Time T4: Process() executes with applied = 0
  → Reads stored angles: Now NON-ZERO!
  → Line 378 condition is TRUE
  → Applies transformation with calculated angles
  → IMAGE JUMPS to rotated view
```

#### 2. **Double Transform Application**
**Line**: 378

The condition checks if ANY angle (stored OR offset) is non-zero:
```lua
if storedPitch ~= 0 or storedYaw ~= 0 or storedRoll ~= 0 or
   pitchOffset ~= 0 or yawOffset ~= 0 or rollOffset ~= 0 then
```

After storing calculated angles, this condition becomes TRUE on every subsequent frame, applying the transformation repeatedly (which is correct, but could interact poorly with SetSource timing).

#### 3. **Documentation-Code Mismatch**
**Documentation**: Claims "Auto Calculate" and "Apply Correction" checkboxes (QUICK_REFERENCE.md lines 9, 71-72, USAGE_GUIDE.md lines 22-23)

**Actual Code**: No such inputs exist! 
- Only InApplyButton (manual button)
- No InAutoCalculate checkbox
- No InApplyCorrection checkbox

This means users following the documentation will have different expectations about when transformations occur.

#### 4. **Inverse Transformation**
**Line**: 379

```lua
result = ApplyPanoCorrection(img, -finalPitch, -finalYaw, -finalRoll, req)
```

The negative angles are INTENTIONAL (for panoramic image correction), but if the calculation is wrong, the inversion amplifies the error.

---

### 5. **PANORAMIC/VR MAPPING USED**

**Yes, extensively**:
- **Equirectangular projection** mapping (NormalizedToSpherical, lines 215-219)
- **3D spherical coordinate** transformations (SphericalToVector, lines 222-231)
- **Rotation matrices** for 3D rotations (ApplyPanoCorrection, lines 404-442)
- **Inverse mapping** for texture sampling (lines 449-454)
- **Helper script** (PanoAlignHelper.lua) can use Fusion's native **Pano Map** node (line 198-221)

The entire system is designed for 360-degree panoramic equirectangular images.

---

### 6. **LIFECYCLE/EFFECT HOOKS**

**Fusion Lua Callbacks in this Fuse**:
1. `Create()` - Register inputs/outputs (executed once on tool creation)
2. `NotifyChanged(inp, param, time)` - Called when ANY input changes (lines 201-212)
3. `Process(req)` - Called for each rendered frame (lines 310-389)

**Problem**: No lifecycle safeguards to prevent multiple transformations. `NotifyChanged` uses `SetSource()` which can trigger cascading `Process()` calls.

---

## Git History Insights

Recent commits show this has been addressed multiple times:

```
855ff5d Store calculated angles - only recalculate when Apply clicked
d9f863e Reset Applied flag after use to prevent persistent transformation
a29a85f Remove live updates during point dragging - only calculate/apply
```

These fixes targeted exactly this issue! But the root cause (SetSource async behavior) may still exist.

---

## SUMMARY TABLE

| Aspect | Finding |
|--------|---------|
| **Default Values** | All zeros (0,0,0) - no transform on load ✓ |
| **Transform Application** | Applied via ApplyPanoCorrection() with inverse angles |
| **VR/Panoramic** | Yes - Equirectangular sphere mapping, 3D rotations |
| **Lifecycle Hooks** | Create(), NotifyChanged(), Process() |
| **SetSource Usage** | Lines 342-344, 356 - potential race conditions ✗ |
| **Auto Behavior** | Documented but NOT IMPLEMENTED ✗ |
| **Button vs Auto** | Button-based ("Apply") only, no auto-calculation ✓ |

---

## RECOMMENDED FIXES

1. **Eliminate SetSource Cascade**:
   - Calculate and store angles in a temporary table
   - Apply SetSource ONCE per Apply click, not multiple times
   - Wait for all SetSource calls to complete before next Process

2. **Fix Documentation**:
   - Remove references to "Auto Calculate" and "Apply Correction" checkboxes
   - Clarify that alignment is triggered by "Apply" button only

3. **Add Safeguards**:
   - Track whether angles were actually changed by SetSource
   - Skip re-applying transformation if angles haven't changed
   - Add frame counter to detect double-application

4. **Test Async Behavior**:
   - Log SetSource timing vs Process call timing
   - Verify that angle values are updated before transformation is applied

---

**Analysis Date**: 2025-11-20
**File**: PanoAlign.fuse (19KB Lua script for Blackmagic Fusion)
**Type**: Panoramic Image Alignment Tool
