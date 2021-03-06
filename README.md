StoryboardXibController
===

[![Pod Version](http://img.shields.io/cocoapods/v/StoryboardXibController.svg?style=flat)](http://cocoadocs.org/docsets/StoryboardXibController/)
[![Pod Platform](http://img.shields.io/cocoapods/p/StoryboardXibController.svg?style=flat)](http://cocoadocs.org/docsets/StoryboardXibController/)
[![Pod License](http://img.shields.io/cocoapods/l/StoryboardXibController.svg?style=flat)](http://cocoadocs.org/docsets/StoryboardXibController/)

**StoryboardXibController** is a utility class made to separate complex view controllers and view data out of your storyboard and into your Xibs, all within Xcode's Interface Builder.

Using this class you can easily load an Xib from within a storyboard at runtime. Currently this is restricted to Xib files whose **File's Owner** is a `UIViewController` or `UIViewController` subclass.

Installation
---
**StoryboardXibController** is available through **[cocoapods](http://cocoapods.org)**, to install simple add the following line to your `PodFile`:

``` ruby
  pod "StoryboardXibController"
```

Alternatively you can clone the **[github repo](https://github.com/Codecademy/StoryboardXibController)**.

Setup
---
Once you've installed the class:

* Add a new view controller scene to your storyboard. 

* Find the **Custom Class** property within the view controller's **Identity Inspector** tab

* Change the view controller's **Custom Class** from `UIViewController` to `StoryboardXibController`.

![Custom Class](https://github.com/Codecademy/StoryboardXibController/blob/master/README/Class.png?raw=true)

**In Xcode 6:**

* Find the **Screen Controller** property within the view controller's **Attributes Inspector** tab

* Change the view controller's **Screen Controller** to the name of the class of your `Xib`'s **File's Owner**/main view controller.

* Find the **Screen Nib** property immediately below

* Change the view controller's **Screen Nib** property to the name of the `Xib` file you wish to load.

**In Xcode 5 and below:**
 
* Find the **User Defined Runtime Attributes** within the same **Identity Inspector** tab

* Add an attribute with the **Key Path** `screenControllerClass` of **Type** `String` with the **Value** of the name of the class of your `Xib`'s **File's Owner**/main view controller.

![screenControllerClass](https://github.com/Codecademy/StoryboardXibController/blob/master/README/AttributeScreenControllerClass.png?raw=true)

* Add a second attribute with the **Key Path** `screenNib` of **Type** `String` with the `Value` of the name of the `Xib` file you wish to load.

![screenNib](https://github.com/Codecademy/StoryboardXibController/blob/master/README/AttributeScreenNib.png?raw=true)

* Enjoy!

Additional Configuration
---
* To align the contained view with the Top Layout Guide or Bottom Layout Guide toggle the two view controller properties:
	* `Align To Top Layout Guide`
	* `Align To Bottom Layout Guide`
	
![screenAlignToLayoutGuide](https://github.com/Codecademy/StoryboardXibController/blob/master/README/AttributesAlignToGuides.png?raw=true)

* Or if you're pre-Xcode6 add attributes of `BOOL` value with the **Key Paths**:
	* `alignToTopLayoutGuide`
	* `alignToBottomLayoutGuide`

Thanks to [@fatuhoku](https://github.com/fatuhoku) for the idea and assistance in developing the feature.


Contributing
---
If you have any ideas, suggestions or bugs to report please [create an issue](https://github.com/Codecademy/StoryboardXibController/issues/new) labeled *feature* or *bug* (check to see if the issue exists first please!). Or suggest a pull request!
