//
//  FlynnTests.swift
//  FlynnTests
//
//  Created by Rocco Bowling on 5/10/20.
//  Copyright © 2020 Rocco Bowling. All rights reserved.
//

import XCTest
@testable import Flynn
import GLKit

public class ColorableState<T> {
    private var internalColor: GLKVector4 = GLKVector4Make(1, 1, 1, 1)

    lazy var beColor: ChainableBehavior<T> = ChainableBehavior { (_: BehaviorArgs) in
        print("Colorable.color from \(self)")
    }

    lazy var beAlpha: ChainableBehavior<T> = ChainableBehavior { (_: BehaviorArgs) in
        print("Colorable.alpha from \(self)")
    }

    init (_ actor: T) {
        beColor.setActor(actor)
        beAlpha.setActor(actor)
    }
}

protocol Colorable: Actor {
    var safeColorable: ColorableState<Self> { get set }
    var beColor: ChainableBehavior<Self> { get }
    var beAlpha: ChainableBehavior<Self> { get }
}

extension Colorable {
    var beColor: ChainableBehavior<Self> { return safeColorable.beColor }
    var beAlpha: ChainableBehavior<Self> { return safeColorable.beAlpha }
}

public final class Color: Actor, Colorable, Viewable {
    public lazy var safeColorable = ColorableState(self)

    public lazy var beRender = Behavior(self) { (args: BehaviorArgs) in
        // flynnlint:parameter CGRect - The bounds in which to render the view
        self.safeViewableRender(args[x:0])
    }
}
