import Flutter
import UIKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Direct CallKit channel — bypasses flutter_callkit_incoming's iOS 26 deadlock.
    // flutter_callkit_incoming calls result(true) AFTER showCallkitIncoming(), and
    // CXProvider's internal main-queue dispatch deadlocks when called from main thread.
    // This channel returns result(nil) immediately, then runs CallKit from the caller's context.
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.pingye/callkit",
        binaryMessenger: controller.binaryMessenger
      )
      let provider = PingyeCallKitProvider(channel: channel)
      PingyeCallKitProvider.shared = provider

      channel.setMethodCallHandler { [weak provider] call, result in
        // Return nil immediately — never block the method channel on CallKit work
        result(nil)
        if call.method == "showCall",
           let args = call.arguments as? [String: String] {
          provider?.showCall(
            name: args["name"] ?? "",
            number: args["number"] ?? ""
          )
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Required for CallKit background handling
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }
}
