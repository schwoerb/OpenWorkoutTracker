# Path Smoothing Feature

## Overview
This feature adds Bezier curve-based path smoothing to reduce the jagged appearance of GPS tracks in OpenWorkoutTracker. The smoothing helps create more visually appealing routes that are closer to commercial offerings like Garmin.

## Implementation Details

### Core Components
1. **SmoothedCrumbPathRenderer** - Enhanced renderer for live activity tracking that uses cubic Bezier curves
2. **PathSmoothingUtils** - Utility class for smoothing coordinate arrays used in historical route display
3. **Preferences** - Added `shouldSmoothPaths` setting to enable/disable the feature

### Files Added/Modified
- `IOS/View/SmoothedCrumbPathRenderer.h/m` - New Bezier curve renderer
- `IOS/View/PathSmoothingUtils.h/m` - New smoothing utility functions
- `IOS/Model/Preferences.h/m` - Added path smoothing preference
- `IOS/View/MappedActivityViewController.m` - Updated to use smoothed renderer
- `IOS/View/MapViewController.m` - Updated to smooth historical routes

### User Interface
The path smoothing option is accessible through the Map Options menu in the activity view:
- "Path Smoothing On" - Enables Bezier curve smoothing
- "Path Smoothing Off" - Uses original linear path rendering

### Technical Details
- **Smoothing Algorithm**: Uses cubic Bezier curves with control points calculated based on neighboring GPS points
- **Smoothing Factor**: Default 0.3 (30% smoothing) provides good balance between accuracy and visual appeal
- **Performance**: Minimal impact as smoothing is applied during rendering, not data collection
- **Backward Compatibility**: Feature is disabled by default to maintain existing behavior

### Benefits
- Reduces visual "jaggedness" in GPS tracks
- Creates more aesthetically pleasing route displays
- Potentially reduces apparent route length by smoothing out GPS noise
- Maintains GPS accuracy for distance/speed calculations (smoothing is visual only)

## Usage
1. Start or view an activity with GPS tracking
2. Tap the Map button in the toolbar
3. Select "Path Smoothing On" to enable smooth path rendering
4. The setting persists across app sessions
