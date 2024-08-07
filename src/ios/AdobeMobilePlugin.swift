import Foundation
import AEPCore
import AEPEdge
import AEPEdgeConsent
import AEPLifecycle
import AEPEdgeIdentity

@objc(AdobeMobilePlugin) class AdobeMobilePlugin: CDVPlugin {

    @objc(configureWithAppID:)
    func configureWithAppID(command: CDVInvokedUrlCommand) {
        guard let applicationID = command.argument(at: 0) as? String, !applicationID.isEmpty else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the application ID to the Adobe SDK initialization")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }

        MobileCore.registerExtensions([Identity.self, Edge.self, Consent.self, Lifecycle.self], {
           MobileCore.configureWith(appId: applicationID)
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Adobe SDK is initialized with success!")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        })
    }

    @objc(getConsents:)
    func getConsents(command: CDVInvokedUrlCommand) {
        Consent.getConsents { consents, error in
            guard error == nil, let consents = consents else { return }
            guard let jsonData = try? JSONSerialization.data(withJSONObject: consents, options: .prettyPrinted) else { return }
            guard let jsonStr = String(data: jsonData, encoding: .utf8) else { return }
            print(jsonStr)
        }
    }

    @objc(lifecycleStart:)
    func lifecycleStart(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            MobileCore.lifecycleStart(additionalContextData: nil)
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(lifecyclePause:)
    func lifecyclePause(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            MobileCore.lifecyclePause()
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
