var exec = require('cordova/exec');

exports.configureWithAppID = function (success, error, args) {
    exec(success, error, 'AdobeMobilePlugin', 'configureWithAppID', [args]);
};

exports.getConsents = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'getConsents');
};

exports.lifecycleStart = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecycleStart');
};

exports.lifecyclePause = function (success, error) {
    exec(success, error, 'AdobeMobilePlugin', 'lifecyclePause');
};