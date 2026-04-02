import UIKit
import CallKit
import AVFoundation
import Flutter

// Direct CXProvider wrapper.
// flutter_callkit_incoming's iOS handler calls result(true) AFTER showCallkitIncoming(),
// which triggers a main-thread deadlock with CXProvider on iOS 26+. This class is
// registered via AppDelegate with its own MethodChannel("com.pingye/callkit") that
// calls result(nil) immediately, then dispatches CallKit work safely.
@objc class PingyeCallKitProvider: NSObject, CXProviderDelegate {

    private let cxProvider: CXProvider
    private var activeUUID: UUID?
    private var channel: FlutterMethodChannel?

    @objc static var shared: PingyeCallKitProvider?

    @objc init(channel: FlutterMethodChannel) {
        let config = CXProviderConfiguration(localizedName: "Phone")
        config.supportsVideo = false
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        config.supportedHandleTypes = [.phoneNumber, .generic]

        self.cxProvider = CXProvider(configuration: config)
        self.channel = channel
        super.init()
        // queue: nil → main queue for delegate callbacks (safe when called from background)
        cxProvider.setDelegate(self, queue: nil)
    }

    @objc func showCall(name: String, number: String) {
        let update = CXCallUpdate()
        let handleValue = number.isEmpty ? name : number
        update.remoteHandle = CXHandle(type: .generic, value: handleValue)
        update.localizedCallerName = name
        update.hasVideo = false
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false

        let uuid = UUID()
        activeUUID = uuid
        print("[PingyeCallKit] reportNewIncomingCall — \(name) \(handleValue)")

        cxProvider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let e = error {
                print("[PingyeCallKit] error: \(e.localizedDescription)")
                self?.activeUUID = nil
            } else {
                print("[PingyeCallKit] call displayed OK")
            }
        }
    }

    // MARK: - CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        activeUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        channel?.invokeMethod("onAccepted", arguments: nil)
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        activeUUID = nil
        channel?.invokeMethod("onDeclined", arguments: nil)
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        try? audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .defaultToSpeaker])
        try? audioSession.setActive(true)
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}
