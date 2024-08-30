var exec = require('cordova/exec');

exports.configureWithAppID = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'configureWithAppID', [args]);
};

exports.getConsents = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'getConsents');
};

exports.updateConsents = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'updateConsents', [args]);
};

exports.startSession = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'startSession', [args]);
};

exports.setPushIdentifier = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'setPushIdentifier', [args]);
};

exports.lifecycleStart = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecycleStart');
};

exports.lifecyclePause = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecyclePause');
};