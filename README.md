# KoiWheel

[![CI Status](https://img.shields.io/travis/kwabford/KoiWheel.svg?style=flat)](https://travis-ci.org/kwabford/KoiWheel)
[![Version](https://img.shields.io/cocoapods/v/KoiWheel.svg?style=flat)](https://cocoapods.org/pods/KoiWheel)
[![License](https://img.shields.io/cocoapods/l/KoiWheel.svg?style=flat)](https://cocoapods.org/pods/KoiWheel)
[![Platform](https://img.shields.io/cocoapods/p/KoiWheel.svg?style=flat)](https://cocoapods.org/pods/KoiWheel)

A customisable subclass of UIControl which allows you to create a Jog Wheel or Knob.

## Preview
![preview](Media/simple_color.gif)
Updating the Wheel's Tint Color based on its value.

## Usage
Drag and drop an `UIView` object into your view controller and set its class and module to `KoiWheel`.

## Supported Properties
| Properties        | Description      | Default value  |
| ------------- |-------------| -----|
| Value      | The Value of the Wheel. The number of revolutions from initial position.     | 0.0 |
| Minimum Value      | The Smallest Value of the Wheel.     | 0.0 |
| Maximum Value      | The Largest Value of the Wheel.     | 100.0 |
| Angular Resistance      | The greater the value the faster rotation slows to a stop.     | 1.0 |
| Marker Color      | The color of the Orientation Marker. The marker is only visable if Knob Image is `nil`     | `UIColor.white` |
| Knob Image      | An image for custom designing the wheel. Setting this to a non-nil value hides default Orientation Marker     | `nil` |
| Knob Overlay Image      | An non-rotating decoration image for custom designing the wheel (eg. the glare on a record).      | `nil` |
| Overlay Alpha      | The alpha of the overlay image     | 1.0 |


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KoiWheel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KoiWheel'
```

## Author

kwabford, kwabford@gmail.com

## License

KoiWheel is available under the MIT license. See the LICENSE file for more info.
