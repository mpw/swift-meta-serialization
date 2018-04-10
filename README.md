# MetaSerialization
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/cherrywoods/swift-meta-serialization.svg?branch=testing)](https://travis-ci.org/cherrywoods/swift-meta-serialization)

MetaSerialization is a framework to simplify the creation of new serialisation libraries for the swift standard library environment (Encodable, Decodable, Codable, etc.)
It's aim is to let anyone create a serialization library that works with the swift serialization framework by nearly just writing the real serialization code. 
To archive this goal, it includes a default `Encoder` and `Decoder` implementation that delegate a small part of their work to implementations of `MetaSupplier` / `Unwrapper`, but are furthermore extendible. Most common use cases should however not require overriding eigther `MetaEncoder` or `MetaDecoder`, but should be archivable with a short custom implementation of `MetaSupplier` / `Unwrapper`. 
In the most extreme form, it is possible to build codable support for an existing framework in [2 lines of code](https://github.com/cherrywoods/swift-meta-serialization/blob/73f067c2c542d4548813d3c8884755dee270ec64/Examples/Example1/Example1.swift#L14-L16).

## Installation
MetaSerialization supports these dependency managers:
 - [CocoaPods](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#cocoapods),
 - [Carthage](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#carthage)
 - [Swift Package Manager](https://github.com/cherrywoods/swift-meta-serialization/blob/master/docs/Guides/Installation.md#swift-package-manager).

## Documentation
Is available at https://cherrywoods.github.io/swift-meta-serialization/ or in the docs folder of this repository. 
These docs also include an [introduction page](https://cherrywoods.github.io/swift-meta-serialization/introduction.html) that outlines the general problem that should be solved by MetaSerialization and a [getting started guide](https://cherrywoods.github.io/swift-meta-serialization/getting-started.html).

You can find a few additional resources in the [wiki tab of this repository](https://github.com/cherrywoods/swift-meta-serialization/wiki). However those guides are mostly about version 1 and might not be helpfull for the current version.

Feel free to open an issue if you have questions about this framework. All suggestions to improve MetaSerialization or it's documentation are welcome (as long as you stick to the [Code of Conduct](https://github.com/cherrywoods/swift-meta-serialization/blob/master/CODE_OF_CONDUCT.md)).

## Limitation
MetaSerialization can only do it's work properly, if you do not use the function encode(to: ) of the Encodable protocol directly in your implementation of it. Use the encode methods of the (Un)Keyed/SingleValueEncodingContainers instead.

## Testing
This project is tested against the tests of JSONEncoder from Foundation among other tests specifically designed for MetaSerialization.
All test can be found in the [Tests folder](https://github.com/cherrywoods/swift-meta-serialization/tree/master/Tests). 

MetaSerialization uses [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble) for testing.


This applies for version 1, the current release. While this release works fine in general and passes all test that JSONEncoder specifies, it isn't that great to subclass and overwrite. Due to this, there is a new version (2.0) that is currently not release ready, because a lot of added features has not been tested yet. However, 2.0 is also already capable of all JSONEncoder tests. You may clone directly from the master branch to get the new version.

## Licensing
This framework is licensed at the Apache Version 2.0 License, (nearly) the same license swift is licensed at.

## Help wanted!
 - [ ] Include more tests
 - [ ] Write more documentation, e.g. the complete decoding example process isn't complete.
 - [ ] Provide a simpler way to use MetaSerialization
