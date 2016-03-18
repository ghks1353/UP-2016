//
//  JumpUpElements.swift
//  UP
//
//  Created by ExFl on 2016. 3. 2..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import SpriteKit;

class JumpUpElements:SKSpriteNode {
	
	//Element type
	static let TYPE_DECORATION:Int = 0;
	static let TYPE_STATIC_ENEMY:Int = 1;
	static let TYPE_DYNAMIC_ENEMY:Int = 2;
	static let TYPE_EFFECT:Int = 3;
	
	/////////
	internal var elementType:Int = 0; //default is decoration
	internal var elementSpeed:Double = 1; //default is scroll speed (or 1)
	internal var elementFlag:Int = 0; //게임 틱 시 특별한 유닛 구분을 위함
	
	//element vars flag
	internal var elementTickFlag:Int = 0; //점프 비헤이비어 등의 flag를 위함
	
	//target element (optional)
	internal var elementTargetElement:SKSpriteNode?;
	internal var elementTargetPosFix:CGSize?;
	
	//Motions
	internal var motions_current:Int = -1;
	internal var motions_current_frame:Int = 0; //현재 모션에 대한 프레임
	internal var motions_frame_delay_left:Int = 0; //모션 프레임 사이의 간격
	
	internal var motions_effect:Array<SKTexture> = [];
	internal var motions_walking:Array<SKTexture> = [];
	internal var motions_jumping:Array<SKTexture> = [];
	
	//물리 영향을 미치는 부분
	internal var ySpeed:CGFloat = 0; //값에 따라 위/아래의 가속도로 작용함. 항상 뺌.
	internal var jumpFlaggedCount:Int = 0; //n단점프까지만 허용하게 설정
	
	internal func changeMotion( motionNumber:Int ) {
		//이렇게 해 주는 이유는 프레임의 초기화를 위해서임 !!!
		if (motions_current != motionNumber) {
			motions_current_frame = 0;
			motions_current = motionNumber;
		}
	} //end func
	
}