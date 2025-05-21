import 'storage.dart';

extension AppFirebaseStorageBucketExt on Bucket {
  String getAdminWebUploadFolder(FirebaseApp firebaseApp, String path) =>
      firebaseStorageGetAdminWebUploadFolder(
        firebaseApp.options.projectId!,
        name,
        path,
      );
}

/// Get web admin folder
String firebaseStorageGetAdminWebUploadFolder(
  String projectId,
  String bucketName,
  String path,
) =>
    'https://console.firebase.google.com/project/$projectId/storage/$bucketName/files/${Uri.encodeComponent(path)}';
