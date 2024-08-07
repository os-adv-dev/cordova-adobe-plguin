import Foundation
import Cordova
import ACPCore
import ACPIdentity
import ACPLifecycle
import ACPConsent
import ACPEdge

@objc(AdobeMobilePlugin) class AdobeMobilePlugin: CDVPlugin {

    @objc(configureWithAppID:)
    func configureWithAppID(command: CDVInvokedUrlCommand) {
        guard let applicationID = command.argument(at: 0) as? String, !applicationID.isEmpty else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the application ID to the Adobe SDK initialization")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        ACPCore.configure(withAppId: applicationID)

        let extensions: [AnyClass] = [
            ACPEdge.self,
            ACPConsent.self,
            ACPLifecycle.self,
            ACPIdentity.self
        ]

        ACPCore.registerExtensions(extensions) {
            print("AEP Mobile SDK is initialized")
        }

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Adobe SDK is initialized with success!")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(getConsents:)
    func getConsents(command: CDVInvokedUrlCommand) {
        ACPConsent.getConsents { consents, error in
            if let error = error {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }

            if let consents = consents, let jsonObject = try? JSONSerialization.jsonObject(with: consents, options: []) as? [String: Any] {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonObject)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Failed to get consents")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }

    @objc(lifecycleStart:)
    func lifecycleStart(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            ACPCore.lifecycleStart(nil)
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(lifecyclePause:)
    func lifecyclePause(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            ACPCore.lifecyclePause()
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}