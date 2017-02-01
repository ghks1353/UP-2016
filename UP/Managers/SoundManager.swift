//
//  SoundManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
	
	public enum bundleSounds:String {
		case GameReadyBGM = "bgm-game-waiting.mp3"
		case GameJumpUPBGM = "bgm-game-jumpup-field.mp3"
	}
	
	////////////// system bgm sounds
	//(중첩불가)
	static var systemBGMPlayer:AVAudioPlayer?
	static var playingSoundName:String?
	
	static func playBGMSound(_ soundName:String, repeatCount:Int = -1 ) {
		let bgmURL:URL? = Bundle.main.url(forResource: soundName, withExtension: nil)
		
		if (playingSoundName != nil && systemBGMPlayer != nil) {
			if (playingSoundName! == soundName) {
				systemBGMPlayer!.numberOfLoops = repeatCount;
				return //같은 BGM은 끊었다 재생하지 않음
			}
		} //end if
		
		if (systemBGMPlayer != nil) {
			playingSoundName = nil
			systemBGMPlayer!.stop()
			systemBGMPlayer = nil
		} //end if
		
		//try to play
		do {
			systemBGMPlayer = try AVAudioPlayer( contentsOf: bgmURL! )
			
			systemBGMPlayer!.numberOfLoops = repeatCount;
			
			systemBGMPlayer!.prepareToPlay()
			systemBGMPlayer!.play();
			
			playingSoundName = soundName;
		} catch {
			
		}
	} //end func
	
	static func stopBGMSound() {
		if (systemBGMPlayer != nil) {
			playingSoundName = nil
			systemBGMPlayer!.stop()
			systemBGMPlayer = nil
		} //end if
	} //end func
	
	static func pauseResumeBGMSound(_ status:Bool = false ) {
		//플레이중인 사운드가 있을 경우 일시정지
		
		if (status == false) {
			//일시정지
			if (systemBGMPlayer != nil) {
				if (systemBGMPlayer!.isPlaying == true) {
					systemBGMPlayer!.pause();
				}
			}
		} else { //계속
			if (systemBGMPlayer != nil) {
				if (systemBGMPlayer!.isPlaying == false) {
					systemBGMPlayer!.play();
				}
			}
		}
	} //end func
	
	////////////// alarm sounds
	static var list:Array<SoundInfoObj> = [
		SoundInfoObj(soundName: "Marble Soda", fileName: "sounds-alarms-test-marvelsoda.aiff"),
		SoundInfoObj(soundName: "Miracle 5ympho X", fileName: "sounds-alarms-test-miracle5ynphox.aiff"),
		SoundInfoObj(soundName: "占쏙옙占쏙옙", fileName: "sounds-alarms-test-sokyepsokyep.aiff")
	]
	
	//사운드 이름에 대한 실제 사운드 오브젝트 반환
	static func findSoundObjectWithFileName(_ soundFileName:String) -> SoundInfoObj? {
		for i:Int in 0 ..< list.count {
			if (list[i].soundFileName == soundFileName) {
				return list[i]
			}
		} //end for
		
		return nil
	} //end func
	
}
