/// Photos of the experiment "ảnh xe" (docs/design/photo-credits.md, Unsplash License): one per licence class,
/// shown behind the class choice and the overview, and the sports car of the start screen.
abstract final class ClassPhotos {
  static const start = 'assets/images/photos/start.jpg';
  static const _byClass = {
    'A1': 'assets/images/photos/class_a1.jpg', // scooter at night (≤ 125 cm³)
    'A': 'assets/images/photos/class_a.jpg', // sport motorbike (> 125 cm³)
    'B': 'assets/images/photos/class_b.jpg', // car
  };

  static String? of(String? licenseClass) => _byClass[licenseClass];
}
