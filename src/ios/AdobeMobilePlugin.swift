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

    @objc(updateConfigurationWith:)
    func updateConfigurationWith(command: CDVInvokedUrlCommand) {
        do {
            let messagingSandbox = command.arguments[0] as? Bool ?? false
            MobileCore.updateConfigurationWith(configDict: ["messaging.useSandbox": messagingSandbox])
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            
        } catch let error {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    func hexStringToData(_ hexString: String) -> Data? {
        var data = Data()
        var hex = hexString
        while hex.count > 0 {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let byteStr = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            if let byte = UInt8(byteStr, radix: 16) {
                data.append(byte)
            } else {
                return nil // Invalid hex character
            }
        }
        return data
    }
    
    @objc(setPushIdentifier:)
    func setPushIdentifier(command: CDVInvokedUrlCommand) {
        if let deviceTokenHex = command.arguments[0] as? String {
            if deviceTokenHex.lowercased() == "none" {
                // Convert "none" string to Data and send it to unregister token in Adobe
                let noneData = "none".data(using: .utf8)
                MobileCore.setPushIdentifier(noneData)
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                return
            }
    
            // Convert hex string back to Data
            if let deviceTokenData = hexStringToData(deviceTokenHex) {
                MobileCore.setPushIdentifier(deviceTokenData)
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid token format")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
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
            Assurance.startSession(url: sessionUrl)
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
                
                guard let args = command.arguments as? [Any], args.count >= 3,
                      let eventName = args[0] as? String,
                      let eventType = args[1] as? String,
                      let financeData = args[2] as? [String: Any] else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "eventType or eventName is null, please review your implementation")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }

                var xdmData: [String: Any] = [:]
                xdmData["eventType"] = eventType

                var pageViewsData: [String: Any] = [:]
                pageViewsData["value"] = 1

                var webPageDetailsData: [String: Any] = [:]
                webPageDetailsData["name"] = eventName
                webPageDetailsData["pageViews"] = pageViewsData

                var webData: [String: Any] = [:]
                webData["webPageDetails"] = webPageDetailsData

                xdmData["web"] = webData

                var paragonFinanceData: [String: Any] = [:]

                if let accountID = financeData["accountID"] as? String {
                    var customerActivityData: [String: Any] = [:]
                    customerActivityData["accountID"] = accountID
                    paragonFinanceData["customerActivity"] = customerActivityData
                }

                if let personId = financeData["personId"] as? String {
                    var identitiesData: [String: Any] = [:]
                    identitiesData["personId"] = personId
                    paragonFinanceData["identities"] = identitiesData
                }

                if !paragonFinanceData.isEmpty {
                    xdmData["_paragonfinance"] = paragonFinanceData
                }

                let experienceEvent = ExperienceEvent(xdm: xdmData)

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
                      let authenticatedState = args[2] as? String,
                      let isPrimary = args[3] as? Bool else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Invalid arguments for updateIdentities")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    return
                }

                let authenticationValue = AuthenticatedState(rawValue: authenticatedState) ?? .ambiguous
                let identityItem = IdentityItem(id: identityValue, authenticatedState: authenticationValue, primary: isPrimary)
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

    @objc(resetIdentities:)
    func resetIdentities(command: CDVInvokedUrlCommand) {
        DispatchQueue.global().async {
           MobileCore.setPrivacyStatus(PrivacyStatus.optedOut)
            MobileCore.resetIdentities()
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Success resetIdentities")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
}
