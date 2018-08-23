package com.netease.edu.study.debug;

import android.app.Application;

import com.huawei.android.hms.agent.HMSAgent;
import com.meizu.cloud.pushinternal.DebugLogger;
import com.meizu.cloud.pushsdk.PushManager;
import com.meizu.cloud.pushsdk.util.MzSystemUtils;


/**
 * application类 | application class
 */
public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
//        HMSAgent.init(this);
//        DebugLogger.initDebugLogger(this);

        if(MzSystemUtils.isBrandMeizu(this)) {
            PushManager.register(this, "115295", "88402a532cc34d47a51cc022619f9555");
            String pushId = PushManager.getPushId(this);
            DebugLogger.i("MyApplication", "pushId" + pushId);
        }
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        HMSAgent.destroy();
    }
}
