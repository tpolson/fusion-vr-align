# Code Location Reference Guide
## Critical Sections in PanoAlign.fuse

---

## SECTION 1: DEFAULT VALUE INITIALIZATION

### Location: Lines 40-75 (Create function)

**Vertical Reference Line 1 (Green line in QUICK_REFERENCE.md)**
```lua
InVert1Point1 = self:AddInput("Top Point", "Vert1Point1", {
    LINKID_DataType = "Point",
    INPID_InputControl = "OffsetControl",
    INPID_PreviewControl = "CrosshairControl",
    INP_DefaultX = 0.3,     // Horizontal center-left
    INP_DefaultY = 0.2,     // Vertical top-upper
})

InVert1Point2 = self:AddInput("Bottom Point", "Vert1Point2", {
    LINKID_DataType = "Point",
    INPID_InputControl = "OffsetControl",
    INPID_PreviewControl = "CrosshairControl",
    INP_DefaultX = 0.3,     // Same horizontal position
    INP_DefaultY = 0.8,     // Vertical bottom-lower
})
```

**Vertical Reference Line 2 (Cyan line in QUICK_REFERENCE.md)**
```lua
InVert2Point1 = self:AddInput("Top Point", "Vert2Point1", {
    LINKID_DataType = "Point",
    INPID_InputControl = "OffsetControl",
    INPID_PreviewControl = "CrosshairControl",
    INP_DefaultX = 0.7,     // Horizontal center-right
    INP_DefaultY = 0.2,     // Vertical top-upper
})

InVert2Point2 = self:AddInput("Bottom Point", "Vert2Point2", {
    LINKID_DataType = "Point",
    INPID_InputControl = "OffsetControl",
    INPID_PreviewControl = "CrosshairControl",
    INP_DefaultX = 0.7,     // Same horizontal position
    INP_DefaultY = 0.8,     // Vertical bottom-lower
})
```

---

## SECTION 2: INTERNAL FLAG AND STORED ANGLES

### Location: Lines 144-168 (Create function, invisible inputs)

```lua
-- Applied flag: Set to 1 when user clicks Apply button
InApplied = self:AddInput("Applied", "Applied", {
    LINKID_DataType = "Number",
    INP_Default = 0,        // FALSE - no automatic calculation
    INP_Integer = true,
    IC_Visible = false,     // Hidden from UI
})

-- Stored Calculated Pitch (after Apply button clicked)
InStoredPitch = self:AddInput("Stored Pitch", "StoredPitch", {
    LINKID_DataType = "Number",
    INP_Default = 0,        // No pitch initially
    IC_Visible = false,
})

-- Stored Calculated Yaw (after Apply button clicked)
InStoredYaw = self:AddInput("Stored Yaw", "StoredYaw", {
    LINKID_DataType = "Number",
    INP_Default = 0,        // No yaw initially
    IC_Visible = false,
})

-- Stored Calculated Roll (after Apply button clicked)
InStoredRoll = self:AddInput("Stored Roll", "StoredRoll", {
    LINKID_DataType = "Number",
    INP_Default = 0,        // No roll initially
    IC_Visible = false,
})
```

---

## SECTION 3: MANUAL OFFSET CONTROLS

### Location: Lines 95-117 (Create function, Manual Offsets section)

These are ADDITIVE to the calculated values:

```lua
-- Pitch: Up/down tilt adjustment
InPitchOffset = self:AddInput("Pitch Offset", "PitchOffset", {
    LINKID_DataType = "Number",
    INPID_InputControl = "SliderControl",
    INP_Default = 0.0,
    INP_MinScale = -45.0,   // Range: -45° to +45°
    INP_MaxScale = 45.0,
})

-- Yaw: Left/right pan adjustment
InYawOffset = self:AddInput("Yaw Offset", "YawOffset", {
    LINKID_DataType = "Number",
    INPID_InputControl = "SliderControl",
    INP_Default = 0.0,
    INP_MinScale = -90.0,   // Range: -90° to +90°
    INP_MaxScale = 90.0,
})

-- Roll: Rotation/tilt adjustment
InRollOffset = self:AddInput("Roll Offset", "RollOffset", {
    LINKID_DataType = "Number",
    INPID_InputControl = "SliderControl",
    INP_Default = 0.0,
    INP_MinScale = -45.0,   // Range: -45° to +45°
    INP_MaxScale = 45.0,
})
```

---

## SECTION 4: BUTTON CALLBACK (NotifyChanged)

### Location: Lines 201-212

**TRIGGERED**: When user clicks Apply or Reset button

```lua
function NotifyChanged(inp, param, time)
    if inp == InApplyButton then
        -- User clicked Apply button
        -- This sets the flag that tells Process() to calculate angles
        InApplied:SetSource(Number(1), time)
        -- *** ISSUE: This SetSource is async! *** (See SECTION 5)
        
    elseif inp == InResetButton then
        -- User clicked Reset Offsets button
        -- This clears manual adjustments
        InPitchOffset:SetSource(Number(0), time)
        InYawOffset:SetSource(Number(0), time)
        InRollOffset:SetSource(Number(0), time)
        -- *** ISSUE: Multiple SetSource calls may trigger cascade *** (See SECTION 5)
    end
end
```

---

## SECTION 5: CRITICAL PROCESS FUNCTION

### Location: Lines 310-389 - THE MAIN RENDERING PIPELINE

#### Step 1: Get Current State (lines 310-323)
```lua
function Process(req)
    local img = InImage:GetValue(req)
    local showOverlay = InShowOverlay:GetValue(req).Value == 1
    -- Line 313: GET THE APPLIED FLAG VALUE
    local applied = InApplied:GetValue(req).Value == 1   // ← KEY LINE
    
    if not img then
        return
    end
    
    -- Get current point positions from user dragging
    local v1p1 = InVert1Point1:GetValue(req)
    local v1p2 = InVert1Point2:GetValue(req)
    local v2p1 = InVert2Point1:GetValue(req)
    local v2p2 = InVert2Point2:GetValue(req)
    
    -- Extract coordinates
    local v1x1, v1y1 = v1p1.X, v1p1.Y
    local v1x2, v1y2 = v1p2.X, v1p2.Y
    local v2x1, v2y1 = v2p1.X, v2p1.Y
    local v2x2, v2y2 = v2p2.X, v2p2.Y
    
    local result = img
```

#### Step 2: CONDITIONAL CALCULATION (lines 334-357) 
#### **THIS IS WHERE THE RACE CONDITION HAPPENS**
```lua
    -- Line 334: IF applied flag is TRUE...
    if applied then
        -- Calculate values from reference lines
        local calcPitch, calcYaw, calcRoll = CalculateAlignmentFromVerticals(
            v1x1, v1y1, v1x2, v1y2,
            v2x1, v2y1, v2x2, v2y2
        )
        
        -- Line 342-344: STORE calculated angles
        -- *** RACE CONDITION #1: SetSource is ASYNC ***
        InStoredPitch:SetSource(Number(calcPitch), req.Time)
        InStoredYaw:SetSource(Number(calcYaw), req.Time)
        InStoredRoll:SetSource(Number(calcRoll), req.Time)
        -- These values won't be updated yet!
        
        -- Update UI labels
        local calcLabelText = string.format("Yaw: %.2f°  Pitch: %.2f°  Roll: %.2f°", 
                                            calcYaw, calcPitch, calcRoll)
        InCalcInfoLabel:SetAttrs({LINKS_Name = calcLabelText})
        
        -- Output to other nodes
        OutPitch:Set(req, calcPitch)
        OutYaw:Set(req, calcYaw)
        OutRoll:Set(req, calcRoll)
        
        -- Line 356: Reset Applied flag
        -- *** RACE CONDITION #2: Multiple SetSource calls ***
        InApplied:SetSource(Number(0), req.Time)
        -- This also doesn't take effect immediately!
    end
    
    -- Line 359-366: Get values (may still be old!)
    local storedPitch = InStoredPitch:GetValue(req).Value
    local storedYaw = InStoredYaw:GetValue(req).Value
    local storedRoll = InStoredRoll:GetValue(req).Value
    
    local pitchOffset = InPitchOffset:GetValue(req).Value
    local yawOffset = InYawOffset:GetValue(req).Value
    local rollOffset = InRollOffset:GetValue(req).Value
```

#### Step 3: FINAL CALCULATION (lines 369-375)
```lua
    -- Line 369-371: Calculate final values
    local finalPitch = storedPitch + pitchOffset
    local finalYaw = storedYaw + yawOffset
    local finalRoll = storedRoll + rollOffset
    
    -- Update UI labels
    local finalLabelText = string.format("Yaw: %.2f°  Pitch: %.2f°  Roll: %.2f°", 
                                         finalYaw, finalPitch, finalRoll)
    InFinalInfoLabel:SetAttrs({LINKS_Name = finalLabelText})
```

#### Step 4: APPLY TRANSFORMATION (lines 378-386) 
#### **WHERE THE IMAGE JUMP HAPPENS**
```lua
    -- Line 378: Check if ANY angle is non-zero
    if storedPitch ~= 0 or storedYaw ~= 0 or storedRoll ~= 0 or 
       pitchOffset ~= 0 or yawOffset ~= 0 or rollOffset ~= 0 then
        -- Apply transformation with INVERSE angles
        -- Line 379: *** THE JUMP HAPPENS HERE ***
        result = ApplyPanoCorrection(img, -finalPitch, -finalYaw, -finalRoll, req)
        --                                 ↑ Negated! Inverse rotation
    end
    
    -- Add overlay if requested
    if showOverlay then
        result = AddOverlay(result, v1x1, v1y1, v1x2, v1y2, v2x1, v2y1, v2x2, v2y2,
                          false, 0, 0, 0, req)
    end
    
    -- Output final result
    OutImage:Set(req, result)
end
```

---

## SECTION 6: TRANSFORMATION APPLICATION

### Location: Lines 392-466

```lua
function ApplyPanoCorrection(img, pitch, yaw, roll, req)
    local width = img.Width
    local height = img.Height
    
    -- Create output image
    local out = Image({IMG_Like = img})
    
    -- Convert angles to radians
    local pitchRad = math.rad(pitch)
    local yawRad = math.rad(yaw)
    local rollRad = math.rad(roll)
    
    -- Pre-calculate rotation matrix values
    local cosPitch = math.cos(pitchRad)
    local sinPitch = math.sin(pitchRad)
    local cosYaw = math.cos(yawRad)
    local sinYaw = math.sin(yawRad)
    local cosRoll = math.cos(rollRad)
    local sinRoll = math.sin(rollRad)
    
    -- Process each pixel (VERY SLOW for large images)
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            -- Line 418-423: Convert pixel to spherical (lon, lat)
            local nx = x / width
            local ny = y / height
            local lon = (nx - 0.5) * 360.0
            local lat = (0.5 - ny) * 180.0
            
            -- Line 426: Convert to 3D vector
            local vec = SphericalToVector(lon, lat)
            
            -- Line 428-442: Apply rotation matrices
            -- ORDER: Yaw → Pitch → Roll
            
            -- Yaw rotation (around Y axis) - applied first
            local x1 = vec.x * cosYaw + vec.z * sinYaw
            local y1 = vec.y
            local z1 = -vec.x * sinYaw + vec.z * cosYaw
            
            -- Pitch rotation (around X axis) - applied second
            local x2 = x1
            local y2 = y1 * cosPitch - z1 * sinPitch
            local z2 = y1 * sinPitch + z1 * cosPitch
            
            -- Roll rotation (around Z axis) - applied last
            local x3 = x2 * cosRoll - y2 * sinRoll
            local y3 = x2 * sinRoll + y2 * cosRoll
            local z3 = z2
            
            -- Line 445-450: Convert back to spherical and pixel coords
            local newLon = math.deg(math.atan2(x3, z3))
            local newLat = math.deg(math.asin(math.max(-1, math.min(1, y3))))
            
            -- Convert to pixel coordinates
            local srcX = (newLon / 360.0 + 0.5) * width
            local srcY = (0.5 - newLat / 180.0) * height
            
            -- Line 452-454: Handle wrapping and clamping
            srcX = srcX % width
            if srcX < 0 then srcX = srcX + width end
            srcY = math.max(0, math.min(height - 1, srcY))
            
            -- Sample and copy pixel
            img:GetPixel(srcX, srcY, p)
            out:SetPixel(x, y, p)
        end
    end
    
    return out
end
```

---

## SECTION 7: SPHERICAL COORDINATE SYSTEM

### Location: Lines 215-231 (Helper functions)

**Equirectangular to Spherical**
```lua
function NormalizedToSpherical(x, y)
    -- Converts normalized (0-1) coordinates to spherical (degree)
    -- Line 216: Longitude: x∈[0,1] → lon∈[-180°, +180°]
    local lon = (x - 0.5) * 360.0
    
    -- Line 217: Latitude: y∈[0,1] → lat∈[+90°, -90°]
    local lat = (0.5 - y) * 180.0
    
    return lon, lat
end

function SphericalToVector(lon, lat)
    -- Converts spherical degrees to 3D unit vector
    local lonRad = math.rad(lon)
    local latRad = math.rad(lat)
    
    -- Standard sphere equations
    local x = math.cos(latRad) * math.sin(lonRad)
    local y = math.sin(latRad)
    local z = math.cos(latRad) * math.cos(lonRad)
    
    return {x = x, y = y, z = z}
end
```

---

## SECTION 8: ANGLE CALCULATION

### Location: Lines 259-308

```lua
function CalculateAlignmentFromVerticals(v1x1, v1y1, v1x2, v1y2, v2x1, v2y1, v2x2, v2y2)
    -- Convert to 3D vectors
    local v1Lon1, v1Lat1 = NormalizedToSpherical(v1x1, v1y1)
    local v1Lon2, v1Lat2 = NormalizedToSpherical(v1x2, v1y2)
    local v1Vec1 = SphericalToVector(v1Lon1, v1Lat1)
    local v1Vec2 = SphericalToVector(v1Lon2, v1Lat2)
    
    local v2Lon1, v2Lat1 = NormalizedToSpherical(v2x1, v2y1)
    local v2Lon2, v2Lat2 = NormalizedToSpherical(v2x2, v2y2)
    local v2Vec1 = SphericalToVector(v2Lon1, v2Lat1)
    local v2Vec2 = SphericalToVector(v2Lon2, v2Lat2)
    
    -- Calculate direction vectors
    local line1Dir = VectorNormalize({
        x = v1Vec2.x - v1Vec1.x,
        y = v1Vec2.y - v1Vec1.y,
        z = v1Vec2.z - v1Vec1.z
    })
    
    local line2Dir = VectorNormalize({
        x = v2Vec2.x - v2Vec1.x,
        y = v2Vec2.y - v2Vec1.y,
        z = v2Vec2.z - v2Vec1.z
    })
    
    -- Average for stability
    local avgDir = VectorNormalize({
        x = (line1Dir.x + line2Dir.x) / 2,
        y = (line1Dir.y + line2Dir.y) / 2,
        z = (line1Dir.z + line2Dir.z) / 2
    })
    
    -- Line 297: Extract pitch from YZ plane
    local pitch = -math.deg(math.atan2(avgDir.z, avgDir.y))
    
    -- Line 301: Extract roll from XY plane
    local roll = math.deg(math.atan2(avgDir.x, avgDir.y))
    
    -- Line 305: Yaw not determined by vertical lines
    local yaw = 0
    
    return pitch, yaw, roll
end
```

---

## CRITICAL PATHS SUMMARY

| What | Where | Issue |
|------|-------|-------|
| Default values | Lines 40-75, 146-168 | All zeros, should not transform |
| User clicks Apply | NotifyChanged line 205 | Async SetSource |
| Calculate angles | Process line 336 | Only if applied=1 |
| Store angles | Process lines 342-344 | **ASYNC - Race Condition** |
| Reset applied flag | Process line 356 | **ASYNC - Race Condition** |
| Read stored angles | Process lines 360-362 | May get old values! |
| Apply transform | Process line 379 | Happens if any angle ≠ 0 |
| Panoramic mapping | ApplyPanoCorrection lines 415-463 | Equirectangular sphere transform |

---

**File**: `/home/user/fusion-vr-align/PanoAlign.fuse`
**Type**: Blackmagic Fusion Fuse Plugin (Lua)
**Size**: ~19KB
**Key Issue**: SetSource() async behavior causes race conditions in Process()
