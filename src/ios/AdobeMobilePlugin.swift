import Foundation

@objc(UrbiMaps)
class AdobeMobilePlugin: CDVPlugin {

     override func pluginInitialize() {
        super.pluginInitialize()
        print("---- ✅ ---- pluginInitialize ---- ✅ ----")
    }

    @objc(startScan:)
    func startScan(_ command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Edge OK")
        print("---- ✅ ---- Edge OK ---- ✅ ----")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(connectDevice:)
    func connectDevice(_ command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Consant OK")
        print("---- ✅ ---- Consant OK ---- ✅ ----")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}