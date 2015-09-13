![](https://img.shields.io/badge/build-pass-brightgreen.svg?style=flat-square)
![](https://img.shields.io/badge/platform-iOS9+-ff69b4.svg?style=flat-square)
![](https://img.shields.io/badge/Require-XCode7-lightgrey.svg?style=flat-square)


# iOS 9 - New API - CoreSpotlight - Example
iOS 9~ Experiments - New API Components - Internal Search APIs with CoreSpotlight.

## Example

![](https://raw.githubusercontent.com/Sweefties/iOS9-NewAPI-CoreSpotlight-Example/master/source/iPhone6S_Simulator2x-CoreSpotlight.jpg)


## Requirements

- >= XCode 7.0 / 7.1 beta~. (writed with xcode 7.1 beta)
- >= Swift 2.
- >= iOS 9.0.

Tested on iOS 9.1 Simulators, iPhone 6.

## Usage

To run the example project, download or clone the repo.


### Example Code!


- Set at least the following attributes: `title`, `contentDescription`, `thumbnailData`, `rating`, and `keywords`.
- Add `CoreSpotlight` + `MobileCoreServices` Frameworks

```swift
import CoreSpotlight
import MobileCoreServices
```

- CoreSpotlight example
```swift
// defines an object that represents an item that can be indexed..
var searchableItems: [CSSearchableItem] = []

// define Item Attribute Set
let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
attributeSet.title = item.title

// define search keywords
var keywords = item.title.componentsSeparatedByString(" ")
keywords.append(item.category)
attributeSet.keywords = keywords

// create searchable item
let searchItem = CSSearchableItem(uniqueIdentifier: item.title, domainIdentifier: "domain-id", attributeSet: attributeSet)
searchableItems.append(searchItem)

```

- Defines an object that represents the on-device index
```swift
// On-device Index
CSSearchableIndex.defaultSearchableIndex().indexSearchableItems(searchableItems) { (error) -> Void in
    if error != nil {
        print(error?.localizedDescription)
    }else{
        print("items indexed witch success!")
    }
}
```


Build and Run!
Switch to Search View in your simulator or devices and test by typing one keyword!
