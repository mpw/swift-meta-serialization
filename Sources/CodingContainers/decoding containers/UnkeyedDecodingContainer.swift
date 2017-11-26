//
//  UnkeyedDecodingContainer.swift
//  meta-serialization
//
//  Created by cherrywoods on 20.10.17.
//  Copyright © 2017 cherrywoods. All rights reserved.
//

import Foundation

/**
 Manages a UnkeyedContainerMeta
 */
open class MetaUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    private var reference: Reference
    private var referencedMeta: UnkeyedContainerMeta {
        get {
            return reference.element as! UnkeyedContainerMeta
        }
        set (newValue) {
            reference.element = newValue
        }
    }
    
    public var codingPath: [CodingKey]
    
    // MARK: - initalization
    
    public init(referencing reference: Reference) {
        
        self.reference = reference
        self.codingPath = reference.coder.codingPath
        
    }
    
    // MARK: - container methods
    
    public var count: Int? {
        // because the unkeyed container is already halfway decoded, the number of elements should be known
        return referencedMeta.count
    }
    
    public var isAtEnd: Bool {
        return self.currentIndex == self.count
    }
    
    // UnkeyedContainerMeta is required to start at 0 and end at count-1
    public var currentIndex: Int = 0
    
    // MARK: - decoding
    
    public func decodeNil() throws -> Bool {
        
        let isNil = try self.decode(ValuePresenceIndicator.self).isNil
        // as documentation says, we should not increment currentIndex, if the value is not nil,
        // but decode already incremented currentValue,
        // so if the value isn't nil, we need to decrement it again
        if !isNil { self.currentIndex -= 1 }
        return isNil
        
    }
    
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        // first check whether the container still has an element
        guard let subMeta = referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "UnkeyedContainer is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // the coding path needs to be extended, because unwrap(meta) may throw an error
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: currentIndex)!)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // see MetaKeyedEncodingContainer
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        let value: T = try (self.reference.coder as! MetaDecoder).unwrap(subMeta)
        // now we decoded a value with success,
        // therefor we can increment currentIndex
        self.currentIndex += 1
        
        return value
        
    }
    
    // MARK: - nested container
    
    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(type, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let keyedSubMeta = subMeta as? KeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(KeyedDecodingContainer<NestedKey>.self, context)
        }
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: keyedSubMeta)
        
        return KeyedDecodingContainer(
            MetaKeyedDecodingContainer<NestedKey>(referencing: nestedReference)
        )
        
    }
    
    public func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        // and furthermore the new container gets the codingPath from decoder
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
        }
        
        // check, wheter subMeta is a UnkeyedContainerMeta
        guard let unkeyedSubMeta = subMeta as? UnkeyedContainerMeta else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Encoded and expected type did not match")
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self, context)
        }
        
        // now all errors, that might have happend, have not been thrown, and currentIndex can be incremented
        currentIndex += 1
        let nestedReference = DirectReference(coder: self.reference.coder, element: unkeyedSubMeta)
        
        return  MetaUnkeyedDecodingContainer(referencing: nestedReference)
        
    }
    
    // MARK: - super encoder
    
    public func superDecoder() throws -> Decoder {
        
        // need to extend coding path in decoder, because decoding might result in an error thrown
        try reference.coder.stack.append(codingKey: IndexCodingKey(intValue: self.currentIndex)!)
        defer {
            do {
                try reference.coder.stack.removeLastCodingKey()
            } catch {
                // this should never happen
                preconditionFailure("Tried to remove codingPath with associated container")
            }
        }
        
        // first check whether the container still has an element
        guard let subMeta = self.referencedMeta.get(at: currentIndex) else {
            
            let context = DecodingError.Context(codingPath: self.codingPath,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(Decoder.self, context)
        }
        
        let referenceToOwnMeta = UnkeyedContainerReference(coder: self.reference.coder, element: self.referencedMeta, index: currentIndex)
        self.currentIndex += 1
        return ReferencingMetaDecoder(referencing: referenceToOwnMeta, meta: subMeta)
        
    }
    
}
