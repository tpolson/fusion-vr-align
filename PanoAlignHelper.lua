--[[
Pano Align Helper Script for Blackmagic Fusion

This script provides an alternative to the Fuse for better performance.
Instead of processing pixels in Lua, it calculates the alignment angles
and applies them using Fusion's native Pano Map or Transform3D nodes.

Usage:
1. Select the Loader node containing your 360 panorama
2. Run this script from Fusion's Script menu
3. Follow the dialog prompts to define reference lines
4. Script creates and configures native Fusion nodes for alignment

This approach is MUCH faster than the Fuse version for high-res images.

Author: Created for panoramic image alignment
Version: 1.0
]]--

-- Get composition and tools
local comp = fu:GetCurrentComp()
local flow = comp.CurrentFrame.FlowView

-- Helper functions
function NormalizedToSpherical(x, y)
    local lon = (x - 0.5) * 360.0
    local lat = (0.5 - y) * 180.0
    return lon, lat
end

function SphericalToVector(lon, lat)
    local lonRad = math.rad(lon)
    local latRad = math.rad(lat)

    local x = math.cos(latRad) * math.sin(lonRad)
    local y = math.sin(latRad)
    local z = math.cos(latRad) * math.cos(lonRad)

    return {x = x, y = y, z = z}
end

function VectorLength(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function VectorNormalize(v)
    local len = VectorLength(v)
    if len > 0.0001 then
        return {x = v.x / len, y = v.y / len, z = v.z / len}
    end
    return {x = 0, y = 0, z = 1}
end

function VectorCross(a, b)
    return {
        x = a.y * b.z - a.z * b.y,
        y = a.z * b.x - a.x * b.z,
        z = a.x * b.y - a.y * b.x
    }
end

function CalculateAlignment(hx1, hy1, hx2, hy2, vx1, vy1, vx2, vy2)
    -- Convert horizontal line points to 3D vectors
    local hLon1, hLat1 = NormalizedToSpherical(hx1, hy1)
    local hLon2, hLat2 = NormalizedToSpherical(hx2, hy2)
    local hVec1 = SphericalToVector(hLon1, hLat1)
    local hVec2 = SphericalToVector(hLon2, hLat2)

    -- Convert vertical line points to 3D vectors
    local vLon1, vLat1 = NormalizedToSpherical(vx1, vy1)
    local vLon2, vLat2 = NormalizedToSpherical(vx2, vy2)
    local vVec1 = SphericalToVector(vLon1, vLat1)
    local vVec2 = SphericalToVector(vLon2, vLat2)

    -- Calculate normal to the horizontal reference plane
    local horizNormal = VectorCross(hVec1, hVec2)
    horizNormal = VectorNormalize(horizNormal)

    -- Calculate pitch
    local pitch = math.deg(math.asin(horizNormal.y))

    -- Calculate roll from the horizontal line
    local avgLat = (hLat1 + hLat2) / 2
    local lonDiff = hLon2 - hLon1
    local latDiff = hLat2 - hLat1
    local roll = math.deg(math.atan2(latDiff, lonDiff))

    -- Calculate yaw from the vertical line
    local avgVLon = (vLon1 + vLon2) / 2
    local yaw = -avgVLon

    return pitch, yaw, roll
end

-- Main script execution
function Main()
    if not comp then
        print("Error: No composition is currently active.")
        return
    end

    -- Get selected tool
    local tool = comp.ActiveTool
    if not tool then
        print("Error: Please select your Loader or image source node first.")
        return
    end

    print("Pano Align Helper - Interactive Setup")
    print("======================================")
    print("")

    -- Dialog for reference line input
    local dialog = {
        {"Horizontal Reference Line", "Text", Default = "", Lines = 1, Wrap = false, ReadOnly = true},
        {"HX1", "Slider", Default = 0.25, Min = 0.0, Max = 1.0},
        {"HY1", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"HX2", "Slider", Default = 0.75, Min = 0.0, Max = 1.0},
        {"HY2", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"", "Text", Default = "", Lines = 1, Wrap = false, ReadOnly = true},
        {"Vertical Reference Line", "Text", Default = "", Lines = 1, Wrap = false, ReadOnly = true},
        {"VX1", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"VY1", "Slider", Default = 0.25, Min = 0.0, Max = 1.0},
        {"VX2", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"VY2", "Slider", Default = 0.75, Min = 0.0, Max = 1.0},
        {"", "Text", Default = "", Lines = 1, Wrap = false, ReadOnly = true},
        {"Method", "Dropdown", Default = 0, Options = {"Transform3D", "Pano Map"}},
    }

    local result = comp:AskUser("Pano Align - Define Reference Lines", dialog)

    if not result then
        print("Cancelled by user.")
        return
    end

    -- Extract values
    local hx1 = result.HX1
    local hy1 = result.HY1
    local hx2 = result.HX2
    local hy2 = result.HY2
    local vx1 = result.VX1
    local vy1 = result.VY1
    local vx2 = result.VX2
    local vy2 = result.VY2
    local method = result.Method

    -- Calculate alignment angles
    local pitch, yaw, roll = CalculateAlignment(hx1, hy1, hx2, hy2, vx1, vy1, vx2, vy2)

    print(string.format("Calculated Alignment:"))
    print(string.format("  Pitch: %.2f°", pitch))
    print(string.format("  Yaw: %.2f°", yaw))
    print(string.format("  Roll: %.2f°", roll))
    print("")

    -- Create nodes based on method
    comp:StartUndo("Pano Align Setup")

    if method == 0 then
        -- Use Transform3D method
        CreateTransform3DAlignment(comp, tool, pitch, yaw, roll)
    else
        -- Use Pano Map method
        CreatePanoMapAlignment(comp, tool, pitch, yaw, roll)
    end

    comp:EndUndo()

    print("Alignment nodes created successfully!")
    print("You can further adjust the angles in the created node.")
end

function CreateTransform3DAlignment(comp, source, pitch, yaw, roll)
    -- Create Transform3D node
    local transform = comp:AddTool("Transform3D", -32768, -32768)
    transform:SetAttrs({TOOLS_Name = "Pano_Align_Transform"})

    -- Connect to source
    transform.Input:ConnectTo(source.Output or source)

    -- Set rotation angles
    -- Transform3D uses XYZ rotation order
    transform.XRotation = {pitch}
    transform.YRotation = {yaw}
    transform.ZRotation = {roll}

    -- Set to position source tool
    if flow then
        local x, y = flow:GetPosTable(source).X, flow:GetPosTable(source).Y
        flow:SetPos(transform, x + 1.5, y)
    end

    print("Created Transform3D node with alignment.")
    return transform
end

function CreatePanoMapAlignment(comp, source, pitch, yaw, roll)
    -- Create Pano Map node
    local panomap = comp:AddTool("PanoMap", -32768, -32768)
    panomap:SetAttrs({TOOLS_Name = "Pano_Align_Map"})

    -- Connect to source
    panomap.Input:ConnectTo(source.Output or source)

    -- Set angles
    -- Pano Map might use different parameter names - adjust as needed
    -- This is a simplified version; actual Pano Map parameters may vary
    panomap.Pitch = {pitch}
    panomap.Yaw = {yaw}
    panomap.Roll = {roll}

    -- Set to position source tool
    if flow then
        local x, y = flow:GetPosTable(source).X, flow:GetPosTable(source).Y
        flow:SetPos(panomap, x + 1.5, y)
    end

    print("Created Pano Map node with alignment.")
    print("Note: Please verify parameter names in your Fusion version.")
    return panomap
end

-- Alternate function: Just calculate and display angles
function CalculateOnly()
    if not comp then
        print("Error: No composition is currently active.")
        return
    end

    local dialog = {
        {"Horizontal Reference (Point 1)", "Text", Default = "", Lines = 1, ReadOnly = true},
        {"HX1", "Slider", Default = 0.25, Min = 0.0, Max = 1.0},
        {"HY1", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"Horizontal Reference (Point 2)", "Text", Default = "", Lines = 1, ReadOnly = true},
        {"HX2", "Slider", Default = 0.75, Min = 0.0, Max = 1.0},
        {"HY2", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"", "Text", Default = "", Lines = 1, ReadOnly = true},
        {"Vertical Reference (Point 1)", "Text", Default = "", Lines = 1, ReadOnly = true},
        {"VX1", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"VY1", "Slider", Default = 0.25, Min = 0.0, Max = 1.0},
        {"Vertical Reference (Point 2)", "Text", Default = "", Lines = 1, ReadOnly = true},
        {"VX2", "Slider", Default = 0.5, Min = 0.0, Max = 1.0},
        {"VY2", "Slider", Default = 0.75, Min = 0.0, Max = 1.0},
    }

    local result = comp:AskUser("Calculate Pano Alignment Angles", dialog)

    if not result then
        return
    end

    local pitch, yaw, roll = CalculateAlignment(
        result.HX1, result.HY1, result.HX2, result.HY2,
        result.VX1, result.VY1, result.VX2, result.VY2
    )

    local output = string.format(
        "Calculated Alignment Angles:\n\n" ..
        "Pitch: %.3f°\n" ..
        "Yaw: %.3f°\n" ..
        "Roll: %.3f°\n\n" ..
        "Apply these values manually to your Pano Map or Transform3D node.",
        pitch, yaw, roll
    )

    comp:AskUser("Alignment Results", {
        {"Results", "Text", Default = output, Lines = 8, Wrap = true, ReadOnly = true}
    })
end

-- Run the main function
Main()
