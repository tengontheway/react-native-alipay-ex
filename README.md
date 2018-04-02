# react-native-alipay-ex

![Download](https://www.npmjs.com/package/react-native-alipay-ex)

A alipay API for react-native . Works on iOS and Android.

## Content

- [Installation](#installation)
- [API](#api)


## Installation

### First step(Download):
Run `npm i react-native-alipay-ex --save`

### Second step(Plugin Installation):

#### Automatic installation(Use auto or manual)

`react-native link react-native-alipay-ex` or `rnpm link react-native-alipay-ex`

#### Manual installation(Use auto or manual)

**Android:**

1. In your android/settings.gradle file, make the following additions:
```java
include ':react-native-alipay-ex'
project(':react-native-alipay-ex').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-alipay-ex/android')
```

2. In your android/app/build.gradle file, add the `:react-native-alipay-ex` project as a compile-time dependency:

```java
...
dependencies {
    ...
    compile project(':react-native-alipay-ex')
}
```

3. Update the MainApplication.java file to use `react-native-alipay-ex` via the following changes:

```java
import com.cd.plugins.alipay.AliPayReactPackage;

public class MainApplication extends Application implements ReactApplication {

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        ...

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new AliPayReactPackage()  //here
            );
        }
    };

    ...
}
```

**iOS:**

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-alipay-ex` and add `SplashScreen.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libAliPayEx.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. To fix `'SplashScreen.h' file not found`, you have to select your project → Build Settings → Search Paths → Header Search Paths to add:

   `$(SRCROOT)/../node_modules/react-native-alipay-ex/ios`   
   `recursive`

5. If have this bug, copy `AliPayEx/alipay/libs/ALipaySDK.framework` to your project, and add it  to `Linked Frameworks and libraries`
```
"_OBJC_CLASS_$_AlipaySDK", referenced from:
      objc-class-ref in AliPaySDK(AliPayModule.o)
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

### Third step(Plugin Configuration):

**iOS:**

Update `AppDelegate.m` with the following additions:  
Ensure enter handleOpenURL callback after alipay finished

```obj-c

#import "AlipayModule.h"  // here

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  
  [AliPayModule handleOpenURL:url];     // here
 
  return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{

  [AliPayModule handleOpenURL:url];     // here

  return YES;
}

```

## Usage

Use like so:

```javascript
import AliPay from 'react-native-alipay-ex'

export default class WelcomePage extends Component {
    onPressPay = () => {
        AliPay.pay(res.data, (ret) => {
            if (ret && !ret.code) {
                this.paySucceed()
            } else {
                this.payFailed()
            }
        })
    }
}
```

## API


Method            | Type     | Optional | Description
----------------- | -------- | -------- | -----------
pay()   | function | false | Alipay (Native Method )

## Base alipay config
- [Android alipay config](assets/支付宝Android.md)
- [iOS alipay config](assets/支付宝iOS.md)



**MIT Licensed**