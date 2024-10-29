var exec = require('cordova/exec');

/**
 * Configures the AdobeMobilePlugin with the provided App ID.
 *
 * @param {Function} success - A callback function that is executed when the configuration is successful.
 * @param {Function} error - A callback function that is executed if there is an error during configuration.
 * @param {Object} args - The configuration arguments, such as the App ID.
 */
exports.configureWithAppID = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'configureWithAppID', [args]);
};

/**
 * Retrieves the current consent settings from AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the consents are successfully retrieved.
 * @param {Function} error - A callback function that is executed if there is an error retrieving the consents.
 */
exports.getConsents = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'getConsents');
};

/**
 * Updates the consent settings in the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the consents are successfully updated.
 * @param {Function} error - A callback function that is executed if there is an error updating the consents.
 * @param {Object} args - The new consent settings to be applied.
 */
exports.updateConsents = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'updateConsents', [args]);
};

/**
 * Starts a session with the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the session is successfully started.
 * @param {Function} error - A callback function that is executed if there is an error starting the session.
 * @param {Object} args - The session-related arguments, such as session configuration.
 */
exports.startSession = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'startSession', [args]);
};

/**
 * Sets the push notification identifier for the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the push identifier is successfully set.
 * @param {Function} error - A callback function that is executed if there is an error setting the push identifier.
 * @param {String} args - The push identifier token.
 */
exports.setPushIdentifier = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'setPushIdentifier', [args]);
};

/**
 * Starts the lifecycle for the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the lifecycle is successfully started.
 * @param {Function} error - A callback function that is executed if there is an error starting the lifecycle.
 */
exports.lifecycleStart = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecycleStart');
};

/**
 * Pauses the lifecycle for the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the lifecycle is successfully paused.
 * @param {Function} error - A callback function that is executed if there is an error pausing the lifecycle.
 */
exports.lifecyclePause = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecyclePause');
};

/**
 * Resets the user identities in the AdobeMobilePlugin.
 *
 * This method clears all identities that have been previously set in the Adobe Mobile SDK, allowing you 
 * to start fresh or reset the user’s identity information. This can be useful for privacy compliance or 
 * re-authentication scenarios.
 *
 * @param {Function} success - A callback function that is executed when the identities are successfully reset.
 * @param {Function} error - A callback function that is executed if there is an error resetting the identities.
 */
exports.resetIdentities = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'resetIdentities');
};

/**
 * Sends an event to the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the event is successfully sent.
 * @param {Function} error - A callback function that is executed if there is an error while sending the event.
 * @param {String} eventName - The name of the event to be sent.
 * @param {String} eventType - The type of the event to be sent.
 * @param {Object} contextData - An object containing additional contextual data for the event.
 * @param {Object} financeData - An object containing financial-related data, such as accountID or personId.
 * 
 * The `contextData` parameter should contain key-value pairs that provide contextual information
 * about the event being tracked.
 * 
 * The `financeData` parameter is expected to contain financial data relevant to the event.
 * For example, it can include keys like `accountID` and `personId`.
 *
 * @example
 * // Example of how to call the sendEvent function
 * sendEvent(
 *   function() { console.log('Event sent successfully'); }, 
 *   function(err) { console.error('Error sending event:', err); },
 *   'eventNameExample', 
 *   'eventTypeExample', 
 *   { accountID: '123456', personId: '654321' }
 * );
 */
exports.sendEvent = function (success, error, eventName, eventType, eventData) {
    exec(success, error, 'AdobeMobilePlugin', 'sendEvent', [eventName, eventType, eventData]);
};

/**
 * Updates user identities in the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the identities are successfully updated.
 * @param {Function} error - A callback function that is executed if there is an error updating the identities.
 * @param {String} key - The identity key (e.g., email, customerId).
 * @param {String} value - The identity value.
 * @param {String} authenticationType - The type of authentication (e.g., anonymous, authenticated).
 * @param {Boolean} isPrimary - A boolean indicating whether the identity is primary.
 */
exports.updateIdentities = function (success, error, key, value, authenticationType, isPrimary) {
    exec(success, error, 'AdobeMobilePlugin', 'updateIdentities', [key, value, authenticationType, isPrimary]);
};

/**
 * Removes a user identity from the AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the identity is successfully removed.
 * @param {Function} error - A callback function that is executed if there is an error removing the identity.
 * @param {String} key - The identity key to be removed.
 * @param {String} value - The identity value to be removed.
 */
exports.removeIdentity = function (success, error, key, value) {
    exec(success, error, 'AdobeMobilePlugin', 'removeIdentity', [key, value]);
};

/**
 * Updates the configuration settings for AdobeMobilePlugin.
 *
 * @param {Function} success - A callback function that is executed when the configuration is successfully updated.
 * @param {Function} error - A callback function that is executed if there is an error updating the configuration.
 * @param {Object} args - The configuration settings to be updated.
 */
exports.updateConfigurationWith = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'updateConfigurationWith', [args]);
};