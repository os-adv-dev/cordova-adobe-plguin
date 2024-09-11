import Foundation
import AEPCore
import AEPEdge
import AEPAssurance
import AEPEdgeConsent
import AEPEdgeIdentity
import AEPUserProfile
import AEPIdentity
import AEPLifecycle
import AEPSignal
import AEPServices
import AEPMessaging


@objc(AdobeMobilePlugin) 
class AdobeMobilePlugin: CDVPlugin {

    @objc(configureWithAppID:)
    func configureWithAppID(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            guard let applicationID = command.argument(at: 0) as? String, !applicationID.isEmpty else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the application ID to the Adobe SDK initialization")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            
            MobileCore.registerExtensions(
                [
                    Messaging.self,
                    Edge.self,
                    Assurance.self,
                    Consent.self,
                    AEPEdgeIdentity.Identity.self,
                    AEPIdentity.Identity.self,
                    UserProfile.self,
                    Lifecycle.self,
                    Signal.self
                ], {
                    MobileCore.setLogLevel(.debug)
                    MobileCore.configureWith(appId: applicationID)
                
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Adobe SDK is initialized with success!")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            })
        }
    }
    
    @objc(setPushIdentifier:)
    func setPushIdentifier(command: CDVInvokedUrlCommand) {
        if((command.arguments[0] as? String) != nil) {
            let deviceToken = command.arguments[0] as? String ?? ""
            MobileCore.setPushIdentifier(deviceToken.data(using: .utf8))
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the token to use push registration")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(startSession:)
    func startSession(command: CDVInvokedUrlCommand) {
        guard let sessionUrl = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the sessionUrl to startSession")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        if let sessionUrl = URL(string: sessionUrl) {
            
            let mockUrl = URL(string: "com.outsystems.experts.adobemobilesample://vmzsdtoolsdev11.outsystems.net?adb_validation_sessionid=7cda7d07-9d66-4c73-93a3-23813708cfd2")
            
            Assurance.startSession(url: mockUrl)
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid session URL")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(getConsents:)
    func getConsents(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            Consent.getConsents { consents, error in
                
                guard error == nil, let consents = consents else {
                
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error to get getConsents \(error?.localizedDescription ?? "getConsents without data to return")")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                guard let jsonData = try? JSONSerialization.data(withJSONObject: consents, options: .prettyPrinted) else { return }
                guard let jsonStr = String(data: jsonData, encoding: .utf8) else { return }
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: jsonStr)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(updateConsents:)
    func updateConsents(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            
            let consentValue = command.arguments[0] as? String
            guard let sessionUrl = command.arguments[0] as? String else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "You need to pass the consent value to update")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
            
            Consent.getConsents { consents, error in
                guard error == nil, let consents = consents else {
                
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error to get getConsents \(error?.localizedDescription ?? "getConsents without data to return")")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                let collectConsent = ["collect": ["val": consentValue]]
                let currentConsents = ["consents": collectConsent]
                Consent.update(with: currentConsents)
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Success to update consents")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }

    @objc(lifecycleStart:)
    func lifecycleStart(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            MobileCore.lifecycleStart(additionalContextData: nil)
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Success lifecycleStart")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(lifecyclePause:)
    func lifecyclePause(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            MobileCore.lifecyclePause()
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Success lifecyclePause")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(sendEvent:)
    func sendEvent(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            do {
                // Ensure at least 3 arguments are provided
                guard let args = command.arguments as? [Any], args.count >= 3,
                      let eventValue = args[0] as? String,
                      let eventType = args[1] as? String,
                      let contextData = args[2] as? [String: Any] else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "eventType or eventValue is null, please review your implementation")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }

                // Create the XDM data
                var xdmData: [String: Any] = [:]
                xdmData["eventType"] = eventValue
                xdmData[eventType] = contextData

                // Create the ExperienceEvent
                let experienceEvent = ExperienceEvent(xdm: xdmData)

                // Send the event using the Adobe Edge SDK
                Edge.sendEvent(experienceEvent: experienceEvent) { _ in
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            } catch {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error parsing arguments or sending event")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(updateIdentities:)
    func updateIdentities(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            do {
                guard let args = command.arguments as? [Any], args.count >= 3,
                      let identityKey = args[0] as? String,
                      let identityValue = args[1] as? String,
                      let isPrimary = args[2] as? Bool else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid arguments for updateIdentities")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }

                let identityItem = IdentityItem(id: identityValue, authenticatedState: .ambiguous, primary: isPrimary)
                var identityMap = IdentityMap()
                identityMap.add(item: identityItem, withNamespace: identityKey)

                Identity.updateIdentities(with: identityMap)
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } catch {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error updating identities: \(error.localizedDescription)")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(removeIdentity:)
    func removeIdentity(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
            do {
                guard let args = command.arguments as? [Any], args.count >= 2,
                      let identityKey = args[0] as? String,
                      let identityValue = args[1] as? String else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid arguments for removeIdentity")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }

                let identityItem = IdentityItem(id: identityValue)
                Identity.removeIdentity(item: identityItem, withNamespace: identityKey)
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } catch {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Error removing identity: \(error.localizedDescription)")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
}