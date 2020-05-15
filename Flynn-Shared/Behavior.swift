//
//  Actor.swift
//  Flynn
//
//  Created by Rocco Bowling on 5/10/20.
//  Copyright © 2020 Rocco Bowling. All rights reserved.
//

import Foundation

// TODO: switch BehaviorArgs to dynamicallyCall(withArguments:). This has several benefits
// 1. it sends an Array (I think), and not a struct.
// 2. If its an Array, it can be passed to C and back as a pointer without copying
// 3. we know how to do blocks without copying (store in bahavior, store pointer to block, send pointer to block).
// 4. given 1-3, if we do them all we might be able to have fast, copy-less behavior calling!
public typealias BehaviorArgs = [Any]

public extension Array {
    // Extract and convert a subscript all in one command. Since we don't have compiler
    // support for checking parameters with behaviors, I am leaning towards crashing
    // in order to help identify buggy code faster.
    func get<T>(_ idx: Int) -> T {
        return self[idx] as! T
    }
    
    func check(_ idx: Int) -> Any {
        return self[idx]
    }
}

public typealias BehaviorBlock = ((BehaviorArgs) -> Void)

@dynamicCallable
public struct Behavior<T:Actor> {
    let _actor:T
    let _block:BehaviorBlock
    public init(_ actor:T, _ block:@escaping BehaviorBlock) {
        self._actor = actor
        self._block = block
    }
    @discardableResult public func dynamicallyCall(withArguments args:BehaviorArgs) -> T {
        let local_args = args
        let local_block = _block
        pony_actor_dispatch(_actor._pony_actor, {
            local_block(local_args)
        })
        return _actor
    }
}
