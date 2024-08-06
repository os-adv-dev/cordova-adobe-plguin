var AdobeMobileExtension = (function() {
    var exec = require('cordova/exec');
	var AdobeMobileExtension = (typeof exports !== 'undefined') && exports || {};
	// ===========================================================================
	// public APIs
	// ===========================================================================

    // Sent Event to Adobe Experience Portal
    AdobeMobileExtension.extensionVersion = function (success, error) {
        var FUNCTION_NAME = "sendEvent";

        if (success && !isFunction(success)) {
            printNotAFunction("success", FUNCTION_NAME);
            return;
        }

        if (error && !isFunction(error)) {
            printNotAFunction("error", FUNCTION_NAME);
            return;
        }

        exec(success, error, 'AdobeMobileExtension', FUNCTION_NAME, []);
    };

	return AdobeMobileExtension;
}());

// ===========================================================================
// helper functions
// ===========================================================================
function isString(value) {
    return typeof value === 'string' || value instanceof String;
}

function printNotAString(paramName, functionName) {
    console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a String.");
}

function isFunction (value) {
    return typeof value === 'function';
}

function printNotAFunction(paramName, functionName) {
    console.log("Ignoring call to '" + functionName + "'. The '" + paramName + "' parameter is required to be a function.");
}

module.exports = AdobeMobileExtension;
