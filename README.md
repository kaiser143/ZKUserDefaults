# ZKUserDefaults

[![CI Status](https://img.shields.io/travis/zhangkai/ZKUserDefaults.svg?style=flat)](https://travis-ci.org/zhangkai/ZKUserDefaults)
[![Version](https://img.shields.io/cocoapods/v/ZKUserDefaults.svg?style=flat)](https://cocoapods.org/pods/ZKUserDefaults)
[![License](https://img.shields.io/cocoapods/l/ZKUserDefaults.svg?style=flat)](https://cocoapods.org/pods/ZKUserDefaults)
[![Platform](https://img.shields.io/cocoapods/p/ZKUserDefaults.svg?style=flat)](https://cocoapods.org/pods/ZKUserDefaults)

## Usage
- 新建类继承ZKUserDefaults, 声明属性，在需要写入文件的属性使用 `@dynamic`来声明自己实现get和set方法。
- ZKUserDefaults 会在初始化的时候调用子类方法 `setupDefaults`来向文件中写入初始数据

## Requirements

## Installation

ZKUserDefaults is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZKUserDefaults'
```

## Author

zhangkai, deyang143@126.com

## License

ZKUserDefaults is available under the MIT license. See the LICENSE file for more info.


