//
//  SoundManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class SoundManager {
	
	static var list:Array<SoundInfoObj> = [
		SoundInfoObj(soundName: "alarm-testsound-giza", fileName: "alarm-test.aiff"),
		SoundInfoObj(soundName: "Marble Soda", fileName: "marvelsoda.aiff"),
		SoundInfoObj(soundName: "국뽕★가랭", fileName: "alarm-test-koreagarang.aiff"),
		SoundInfoObj(soundName: "Epic Sax Guy", fileName: "alarm-test-epicsax.aiff")
	];
	
	static func findSoundObjectWithFileName(soundFileName:String)->SoundInfoObj {
		var targetSoundInfoObj:SoundInfoObj = SoundInfoObj(soundName: "", fileName: ""); //nil
		for i:Int in 0 ..< list.count {
			if (list[i].soundFileName == soundFileName) {
				targetSoundInfoObj = list[i];
				break;
			}
		} //end for
		
		return targetSoundInfoObj;
	} //end func
	
	
	//TODO: 사운드가 사라지면 기본 사운드로 바꿔야함
	// - 기존 등록된 알람에 대해선 같은 시각으로 추가하고 알람음만 바꿔치기 해야함.
	
}