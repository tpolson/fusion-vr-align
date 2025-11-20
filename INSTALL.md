# Installation Guide

## Quick Install

### Windows

1. Open File Explorer and navigate to:
   ```
   %APPDATA%\Blackmagic Design\Fusion\Fuses\
   ```
   Or manually:
   ```
   C:\Users\[YOUR_USERNAME]\AppData\Roaming\Blackmagic Design\Fusion\Fuses\
   ```

2. Copy `PanoAlign.fuse` into this folder

3. Restart Fusion

### macOS

1. Open Finder, press `Cmd+Shift+G` and go to:
   ```
   ~/Library/Application Support/Blackmagic Design/Fusion/Fuses/
   ```

2. Copy `PanoAlign.fuse` into this folder

3. Restart Fusion

### Linux

1. Open terminal and navigate to:
   ```bash
   ~/.fusion/BlackmagicDesign/Fusion/Fuses/
   ```

2. Copy the fuse file:
   ```bash
   cp PanoAlign.fuse ~/.fusion/BlackmagicDesign/Fusion/Fuses/
   ```

3. Restart Fusion

## Verify Installation

1. Open Blackmagic Fusion
2. In the Flow area, right-click and select "Add Tool"
3. Navigate to: **Transform > Pano Align**
4. If you see "Pano Align", installation was successful!

Alternatively, use the Select Tool window (Shift+Space) and type "Pano Align"

## Troubleshooting

### Fuses Folder Doesn't Exist

Create it manually:

**Windows**:
```cmd
mkdir "%APPDATA%\Blackmagic Design\Fusion\Fuses"
```

**macOS/Linux**:
```bash
mkdir -p ~/Library/Application\ Support/Blackmagic\ Design/Fusion/Fuses/
```
Or on Linux:
```bash
mkdir -p ~/.fusion/BlackmagicDesign/Fusion/Fuses/
```

### Tool Still Not Appearing

1. Check the Console window in Fusion (Ctrl+Shift+1 or Cmd+Shift+1)
2. Look for any Lua errors related to PanoAlign
3. Ensure the file has `.fuse` extension (not `.fuse.txt`)
4. Try the PathMap method instead (see below)

### Using PathMap (Alternative Method)

If the standard installation doesn't work:

1. Place `PanoAlign.fuse` in any folder of your choice
2. In Fusion: **File > Preferences > Path Map**
3. Find the `Fuses:` entry
4. Click the "..." button to add a path
5. Browse to the folder containing `PanoAlign.fuse`
6. Click OK and restart Fusion

## Uninstallation

Simply delete the `PanoAlign.fuse` file from the Fuses folder and restart Fusion.

## For Resolve Users

If you're using DaVinci Resolve (which includes Fusion):

The Fuses folder location is:

**Windows**:
```
%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Fuses\
```

**macOS**:
```
~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Fuses/
```

**Linux**:
```
~/.local/share/DaVinciResolve/Fusion/Fuses/
```

Note: Some versions of Resolve may have restrictions on custom Fuses. Check Resolve documentation for your version.
