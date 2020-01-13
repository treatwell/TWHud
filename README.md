# TWHud

Beautiful, simple, customizable and easy to use progress HUD for iOS written in Swift.

<div align="center">  
    
<a href="https://treatwell.com/tech/">
<img style="border-radius: 10%;" src="https://user-images.githubusercontent.com/39797949/72060244-42046680-32dc-11ea-9bf8-56e50e07de89.png" />
</a>

</div>

## Requirements

- iOS 10.0+
- Xcode 10.2+
- Swift 5+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter `https://github.com/treatwell/TWHud.git`.

<img width="825" alt="Add Package Dependency" src="https://user-images.githubusercontent.com/39797949/72062278-269b5a80-32e0-11ea-83bc-341739a44424.png">

### Carthage

Add the following entry to your Cartfile:
```swift
github "treatwell/TWHud"
```

## Usage

First, import `TWHud`
```swift
import TWHud
```

Then, in your `AppDelegate` you have to configure `TWHud`. Required configuration parameters are `maskImage` - image used as a mask for HUD and `colours` - array of colours used for animation.
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   TWHud.configure(with:
      TWHud.Configuration(
         maskImage: UIImage(named: "LoaderLogoMask")!,
         colours: [.red, .green, .blue]
      )
   )
}
```

You can configure even more, e.g.:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
   TWHud.configure(with:
      TWHud.Configuration(
         maskImage: UIImage(named: "LoaderLogoMask")!,
         cornerRadius: 5.0,
         size: CGSize(width: 140, height: 140),
         fillUpRect: CGRect(x: 14, y: 29, width: 72, height: 42),
         fillUpTime: 0.6,
         waitTime: 0.2,
         hudBackgroundColour: .white,
         containerBackgroundColour: UIColor.black.withAlphaComponent(0.5),
         colours: [.red, .green, .blue]
      )
   )
}
```

After configuring your `TWHud` in `AppDelegate`, you can use it anywhere in you iOS app code

```swift
TWHud.show()
```

This will create HUD over all your UI

![HUD over your UI](https://user-images.githubusercontent.com/39797949/72069054-f909dd80-32ee-11ea-9d27-e34291cfbb02.gif)

Dismiss it using

```swift
TWHud.dismiss()
```

If you don't need HUD over all your UI elementes, you can add it to your custom view

```swift
let hud = TWHud.showIn(
   view: container, 
   configuration: TWHud.Configuration(
      maskImage: UIImage(named: "LoaderLogoMask64")!,
      hudBackgroundColour: UIColor.lightGray,
      containerBackgroundColour: UIColor.lightGray,
      colours: [.red, .green, .blue, .yellow]
   )
)  
```

![HUD in custom view](https://user-images.githubusercontent.com/39797949/72069106-1f2f7d80-32ef-11ea-8340-b06fbca77875.gif)


Dismiss it using

```swift
hud.dismiss()
```

If you need specify which colour should be used after current one, you can add your validator to `AppDelegate`, after your `TWHud` configuration.

```swift
TWHud.shared?.nextFillColourIndexIsValid = { next, previous in
   // Next colour is different than current
   var valid: Bool = next != previous
   if valid {
      if next == 0 {
         valid = next != 6
      } else if next == 6 {
         valid = next != 0
      } else if next == 3 {
         valid = next != 5
      } else if next == 5 {
         valid = next != 3
      }
   }
            
   return valid
}
```

## Author Information
Marius Kažemėkaitis - marius@treatwell.com

## License
The contents of this repository is licensed under the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
