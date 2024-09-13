#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Recursive function to search for MainActivity.java
function findMainActivity(dir, fileName) {
    let files = fs.readdirSync(dir);
    for (let i = 0; i < files.length; i++) {
        let fullPath = path.join(dir, files[i]);
        let stat = fs.lstatSync(fullPath);
        if (stat.isDirectory()) {
            let found = findMainActivity(fullPath, fileName);
            if (found) return found;
        } else if (files[i] === fileName) {
            return fullPath;
        }
    }
    return null;
}

module.exports = function (context) {
    const platformRoot = path.join(context.opts.projectRoot, 'platforms/android');
    const mainActivityPath = findMainActivity(path.join(platformRoot, 'app/src'), 'MainActivity.java');

    if (mainActivityPath) {
        let mainActivityContent = fs.readFileSync(mainActivityPath, 'utf8');

        // Add the imports after 'import android.os.Bundle;'
        const imports = `
import android.content.Intent;
import static com.adobe.marketing.mobile.cordova.AppConstants.INTENT_FROM_PUSH;
import com.adobe.marketing.mobile.Messaging;
`;

        const bundleImport = 'import android.os.Bundle;';
        if (!mainActivityContent.includes('import android.content.Intent;')) {
            const bundleImportIndex = mainActivityContent.indexOf(bundleImport) + bundleImport.length;
            mainActivityContent = [
                mainActivityContent.slice(0, bundleImportIndex),
                imports,
                mainActivityContent.slice(bundleImportIndex)
            ].join('');
        }

        // Add the onNewIntent method if it doesn't exist
        const onNewIntentMethod = `
    @Override
    protected void onNewIntent(Intent intent) {
        if (intent != null) {
            if (intent.getBooleanExtra(INTENT_FROM_PUSH, false)) {
                Messaging.handleNotificationResponse(intent, true, null);
                intent.removeExtra(INTENT_FROM_PUSH);
            }
        }
        super.onNewIntent(intent);
    }
`;

        if (!mainActivityContent.includes('protected void onNewIntent')) {
            // Add the onNewIntent method before the last closing brace '}'
            const lastClosingBraceIndex = mainActivityContent.lastIndexOf('}');
            if (lastClosingBraceIndex !== -1) {
                mainActivityContent = [
                    mainActivityContent.slice(0, lastClosingBraceIndex),
                    onNewIntentMethod,
                    mainActivityContent.slice(lastClosingBraceIndex)
                ].join('');
            }
        }

        // Write the updated content back to MainActivity.java
        fs.writeFileSync(mainActivityPath, mainActivityContent, 'utf8');
        console.log(`MainActivity.java updated with the onNewIntent method and necessary imports at: ${mainActivityPath}`);
    } else {
        console.error('MainActivity.java not found! Ensure the project has been built for Android.');
    }
};