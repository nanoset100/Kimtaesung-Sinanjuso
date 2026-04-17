import Flutter
import UIKit
import Firebase
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase 초기화 (GoogleService-Info.plist 기반)
    FirebaseApp.configure()
    // Google Maps iOS SDK 초기화
    GMSServices.provideAPIKey("AIzaSyAx7VFbWTgXQ2PTrZ8o4lLgSJg6vr-9kwA")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
