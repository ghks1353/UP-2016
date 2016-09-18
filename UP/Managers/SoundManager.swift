//
//  SoundManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class SoundManager {
	
	static var list:Array<SoundInfoObj> = [
		SoundInfoObj(soundName: "Marble Soda", fileName: "sounds-alarms-test-marvelsoda.aiff"),
		SoundInfoObj(soundName: "Sapphire", fileName: "sounds-alarms-test-kari-sapphire.aiff"),
		SoundInfoObj(soundName: "WANDERLUST", fileName: "sounds-alarms-test-wanderlust.aiff"),
		SoundInfoObj(soundName: "The big black", fileName: "sounds-alarms-test-bigblack.aiff"),
		SoundInfoObj(soundName: "바ㅏㅏ카야로오오오ㅗㅗ", fileName: "sounds-alarms-test-marvelsodamatsuda.aiff")
		
	];
	
	//사운드 이름에 대한 실제 사운드 오브젝트 반환
	static func findSoundObjectWithFileName(_ soundFileName:String) -> SoundInfoObj? {
		for i:Int in 0 ..< list.count {
			if (list[i].soundFileName == soundFileName) {
				return list[i];
			}
		} //end for
		
		return nil;
	} //end func
	
	
	//TODO: 사운드가 사라지면 기본 사운드로 바꿔야함
	// - 기존 등록된 알람에 대해선 같은 시각으로 추가하고 알람음만 바꿔치기 해야함.
	
}
