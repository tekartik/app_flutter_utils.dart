package com.tekartik.tekartik_app_flutter_plugin;

import android.app.ActivityManager;
import android.content.Context;

/**
 * Created by alex on 14/09/16.
 */
public class MonkeyUtils {

    static public boolean isRunning(Context context) {
        ActivityManager activityManager = getActivityManager(context);
        // isUserAMonkey is available in API
        return isRunning(activityManager);

    }

    static public ActivityManager getActivityManager(Context context) {
        return (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    }

    static public boolean isRunning(ActivityManager activityManager) {
        return activityManager.isUserAMonkey();
    }
}
