//
//  UPAlarmSoundLists.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class UPAlarmSoundLists {
	
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
	}
	
}