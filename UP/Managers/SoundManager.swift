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
		SoundInfoObj(soundName: "Miracle 5ympho X", fileName: "sounds-alarms-test-miracle5ynphox.aiff"),
		SoundInfoObj(soundName: "占쏙옙占쏙옙", fileName: "sounds-alarms-test-sokyepsokyep.aiff"),
		SoundInfoObj(soundName: "sounds-alarms-test-theseus", fileName: "sounds-alarms-test-theseus.aiff")
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
	
}
