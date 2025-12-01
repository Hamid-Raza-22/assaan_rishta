# Gender-Based Default Profile Icons Implementation

## Summary
Added gender-based default placeholder icons in the Filter view following **GetX architecture pattern**. When a profile image is not available:
- **Male profiles** → Show male icon placeholder
- **Female profiles** → Show female icon placeholder
- **Unknown/Null gender** → Show generic placeholder

## Architecture - GetX Pattern

This implementation follows proper **GetX separation of concerns**:
- **Controller** (`FilterController`) contains the business logic
- **View** (`FilterView`) only handles UI rendering
- The view calls controller methods using `controller.getGenderBasedPlaceholder()`

## Changes Made

### 1. Filter Controller (`filter_viewmodel.dart`)

#### Added `getGenderBasedPlaceholder()` Method (Line 307-323)
Added business logic method in the controller to determine which placeholder to use based on gender:

```dart
/// Get gender-based placeholder image
/// Returns male/female placeholder based on user's gender
String getGenderBasedPlaceholder(String? gender) {
  if (gender == null || gender.isEmpty) {
    return AppAssets.imagePlaceholder;
  }
  
  // Check gender (case-insensitive)
  final genderLower = gender.toLowerCase();
  if (genderLower == 'male') {
    return AppAssets.malePlaceholder;
  } else if (genderLower == 'female') {
    return AppAssets.femalePlaceholder;
  } else {
    return AppAssets.imagePlaceholder;
  }
}
```

### 2. Filter View (`filter_view.dart`)

#### Modified Profile Image Display (Line 282-294)
Changed to call the controller method `controller.getGenderBasedPlaceholder(user.gender)`:

```dart
ImageHelper(
  image: user.profileImage != null
      ? user.profileImage!
      : controller.getGenderBasedPlaceholder(user.gender), // 👈 Calls controller method
  imageType: user.profileImage != null
      ? ImageType.network
      : ImageType.asset,
  imageShape: ImageShape.circle,
  boxFit: BoxFit.cover,
  height: 90,
  width: 90,
),
```

**Key Points:**
- ✅ View has NO business logic
- ✅ All logic is in the controller
- ✅ Follows GetX best practices
- ✅ Easy to test and maintain

## Assets Used

The implementation uses existing placeholder images from the project:

| Gender | Asset Path | Asset Constant |
|--------|-----------|----------------|
| Male | `assets/images/male_place_holder.png` | `AppAssets.malePlaceholder` |
| Female | `assets/images/female_place_holder.png` | `AppAssets.femalePlaceholder` |
| Generic | `assets/images/image_placeholder.png` | `AppAssets.imagePlaceholder` |

## Data Model

The `ProfilesList` model (from `all_profile_list.dart`) contains:
- `profileImage` (String?) - The user's profile image URL
- `gender` (String?) - The user's gender ("Male" or "Female")

## Technical Details

### How It Works
1. When rendering a profile card in the filter view
2. Check if `user.profileImage` is not null
   - If yes → Display the network image
   - If no → Call `_getGenderBasedPlaceholder(user.gender)`
3. The helper method checks the gender value and returns appropriate placeholder
4. Display the placeholder as an asset image

### Edge Cases Handled
- ✅ Null gender → Shows generic placeholder
- ✅ Empty gender string → Shows generic placeholder
- ✅ Case variations (MALE, male, Male) → All work correctly
- ✅ Unknown gender values → Shows generic placeholder

## Testing Recommendations

Test the following scenarios:
1. Male profile without image → Should show male icon
2. Female profile without image → Should show female icon
3. Profile with null gender → Should show generic icon
4. Profile with image → Should show actual profile image
5. Profile with blur enabled → Blur should work with placeholders

## Note on Chat Feature

The Chat feature uses a different data model (`ChatUser`) which does not include gender information from Firebase. If you want to add gender-based placeholders to the chat feature as well:
1. Add gender field to Firebase user collection
2. Update `ChatUser` model to include gender
3. Apply similar placeholder logic to chat user cards

However, the current implementation focuses on the **Filter view** as requested.

## Files Modified
- `lib/app/viewmodels/filter_viewmodel.dart` - Added gender-based placeholder logic
- `lib/app/views/filter/filter_view.dart` - Updated to call controller method

## Date
2025-11-24
