//
//  TKTimingFunction.swift
//  Pods
//
//  Created by Takuya Okamoto on 2015/10/06.
//
//

// inspired by https://gist.github.com/raphaelschaad/6739676


import UIKit

/**
# CAMediaTimingFunction in Anywhere.
All the cool animation curves from `CAMediaTimingFunction` but it is only available to use with CoreAnimation.
This is the TimingFunction class like CAMediaTimingFunction available in AnyWhere.
This is translated by [JavaScript](http://greweb.me/2012/02/bezier-curve-based-easing-functions-from-concept-to-implementation/).
# Usage
``` swift
let move = SKAction.moveTo(point, duration:2.0)
let timingFunc = TKTimingFunction(controlPoints: 0.6, 0.0, 0.1, 0.6)
move.timingFunction = {timingFunc.get($0)}
```
*/
class TKTimingFunction {
	
	let mX1: CGFloat
	let mY1: CGFloat
	let mX2: CGFloat
	let mY2: CGFloat
	
	init(controlPoints c1x: CGFloat, _ c1y: CGFloat, _ c2x: CGFloat, _ c2y: CGFloat) {
		self.mX1 = c1x
		self.mY1 = c1y
		self.mX2 = c2x
		self.mY2 = c2y
	}
	
	func get(_ aX: CGFloat) -> CGFloat {
		if (mX1 == mY1 && mX2 == mY2) { return aX }// linear
		return calcBezier(getTForX(aX), mY1, mY2)
	}
	
	func get(_ t: Float) -> Float {
		return Float(self.get(CGFloat(t)))
	}
	
	func A(_ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat { return 1.0 - 3.0 * aA2 + 3.0 * aA1 }
	func B(_ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat { return 3.0 * aA2 - 6.0 * aA1 }
	func C(_ aA1: CGFloat)               -> CGFloat { return 3.0 * aA1 }
	
	// Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
	func calcBezier(_ aT: CGFloat, _ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat {
		return ((A(aA1, aA2)*aT + B(aA1, aA2))*aT + C(aA1))*aT
	}
	
	// Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
	func getSlope(_ aT: CGFloat, _ aA1: CGFloat, _ aA2: CGFloat) -> CGFloat {
		return 3.0 * A(aA1, aA2)*aT*aT + 2.0 * B(aA1, aA2) * aT + C(aA1)
	}
	
	func getTForX(_ aX: CGFloat) -> CGFloat {
		// Newton raphson iteration
		var aGuessT = aX
		for _ in 0 ..< 4 {
			let currentSlope = getSlope(aGuessT, mX1, mX2)
			if (currentSlope == 0.0) {return aGuessT}
			let currentX = calcBezier(aGuessT, mX1, mX2) - aX
			aGuessT -= currentX / currentSlope
		}
		return aGuessT
	}
}
