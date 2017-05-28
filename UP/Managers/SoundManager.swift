//
//  SoundManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

class SoundManager:NSObject, AVAudioPlayerDelegate {
	
	static var sharedInstance:SoundManager = SoundManager()
	static var userSoundsURL:[URL] = []
	
	public enum bundleSounds:String {
		case GameReadyBGM = "bgm-game-waiting.mp3"
		case GameJumpUPBGM = "bgm-game-jumpup-field.mp3"
		
		case GozaJumpUPBGM = "bgm-game-gozaup-field.mp3"
	} //bundlesounds
	
	public enum bundleEffectsGozaUP:String {
		case GameEffect0 = "effect-game-gozaup-ef0.mp3"
		case GameEffect1 = "effect-game-gozaup-ef1.mp3"
		case GameEffect2 = "effect-game-gozaup-ef2.mp3"
		case GameEffect3 = "effect-game-gozaup-ef3.mp3"
		case GameEffect4 = "effect-game-gozaup-ef4.mp3"
		case GameEffect5 = "effect-game-gozaup-ef5.mp3"
		case GameEffect6 = "effect-game-gozaup-ef6.mp3"
		case GameEffect7 = "effect-game-gozaup-ef7.mp3"
	} //bundleeffects for GozaUP
	
	public enum bundleEffectsJumpUP:String {
		case CharacterJump = "effect-game-jumpup-jump.wav"
		case CharacterDoubleJump = "effect-game-jumpup-double-jump.wav"
		case EnemyJump = "effect-game-jumpup-enemy-jump.wav"
		case EnemyFall = "effect-game-jumpup-enemy-fall.wav"
		case EnemyFly = "effect-game-jumpup-ememy-flying.wav"
		case EnemyWarning = "effect-game-jumpup-warning.wav"
		
		case CloudFall = "effect-game-jumpup-cloud-fall.wav"
		case NiddleJump = "effect-game-jumpup-niddle-jump.wav"
		case NiddleFall = "effect-game-jumpup-niddle-fall.wav"
		
	} //bundleeffects for JumpUP
	
	public enum bundleEffectsGeneralGame:String {
		case Countdown = "effect-game-general-countdown.wav"
		case CountdownStart = "effect-game-general-countdown-start.wav"
		case Gameover = "effect-game-general-gameover.wav"
	} //end bundleeffects (general)
	
	public enum PlaybackPlayMode {
		case Default
		case NormalMode
		case AlarmMode
	}
	
	////////////// system bgm sounds
	//(중첩불가)
	static var systemBGMPlayer:AVAudioPlayer?
	static var cachedEffectSounds:[String:AVAudioPlayer] = [:]
	static var playingSoundName:String?
	
	static var previousPlaybackMode:PlaybackPlayMode = .Default
	
	static func playBGMSound(_ soundName:String, repeatCount:Int = -1 ) {
		let bgmURL:URL? = Bundle.main.url(forResource: soundName, withExtension: nil)
		
		if (playingSoundName != nil && systemBGMPlayer != nil) {
			if (playingSoundName! == soundName) {
				systemBGMPlayer!.numberOfLoops = repeatCount
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
			
			systemBGMPlayer!.numberOfLoops = repeatCount
			
			systemBGMPlayer!.prepareToPlay()
			systemBGMPlayer!.play()
			
			playingSoundName = soundName
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
					systemBGMPlayer!.pause()
				}
			}
		} else { //계속
			if (systemBGMPlayer != nil) {
				if (systemBGMPlayer!.isPlaying == false) {
					systemBGMPlayer!.play()
				}
			}
		}
	} //end func
	
	
	/// Effect
	static func playEffectSound(_ soundName:String, destroyAfterCompleted:Bool = false ) {
		//이펙트는 임시객체가 생성됨.
		var effectSoundPlayer:AVAudioPlayer?
		
		if (cachedEffectSounds[ soundName ] == nil) {
			//Create new object
			effectSoundPlayer = try! AVAudioPlayer( contentsOf: Bundle.main.url(forResource: soundName, withExtension: nil)! )
			
			effectSoundPlayer!.prepareToPlay()
			
			cachedEffectSounds[ soundName ] = effectSoundPlayer
		} else {
			//Use cached object
			effectSoundPlayer = cachedEffectSounds[ soundName ]
		} //end if
		
		if (destroyAfterCompleted) {
			effectSoundPlayer!.delegate = sharedInstance
		} //end if
		
		effectSoundPlayer!.play()
	} //end func
	
	////////// Audio playback settings
	
	////effect delegate
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		for (k, v) in SoundManager.cachedEffectSounds {
			if (v == player) {
				SoundManager.cachedEffectSounds.remove(at: SoundManager.cachedEffectSounds.index(forKey: k)!)
				break
			} //end if
		} //end for
	} //end func
	
	static func setAudioPlayback(_ playMode:PlaybackPlayMode ) {
		if (playMode == previousPlaybackMode) {
			return
		} //end if
		
		var aSessionCategoryOptions:AVAudioSessionCategoryOptions?
		var aSessionCategory:String?
		
		switch(playMode) {
			case .AlarmMode: //알람 모드 (무음 모드에서도 울림) 설정
				aSessionCategory = AVAudioSessionCategoryPlayback
				aSessionCategoryOptions = AVAudioSessionCategoryOptions.mixWithOthers
				break
			case .NormalMode: //일반 모드 (무음 모드에선 울리지 않음) 설정
				aSessionCategory = AVAudioSessionCategoryAmbient
				aSessionCategoryOptions = AVAudioSessionCategoryOptions.mixWithOthers
				break
			default: return
		} //end switch
		
		do {
			try AVAudioSession.sharedInstance().setCategory(aSessionCategory!, with: aSessionCategoryOptions!)
			do {
				try AVAudioSession.sharedInstance().setActive(true)
			} catch let error as NSError {
				print("[SoundManager] Playback mode setting error: ", error.localizedDescription)
			}
		} catch let error as NSError {
			print("[SoundManager] Playback mode setting error: ", error.localizedDescription)
		} //end do catch
		
		previousPlaybackMode = playMode
	} //end func
	
	////////////////// Fetch document sound list
	static func fetchCustomSoundsList() {
		let documentsUrl:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		
		do {
			// Get the directory contents urls (including subfolders urls)
			let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
			
			userSoundsURL = directoryContents.filter{ $0.pathExtension == "mp3" || $0.pathExtension == "aac" || $0.pathExtension == "m4a" || $0.pathExtension == "wav" }
			print("[SoundManager] Loaded ",userSoundsURL.count,"custom sound files")
			//let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
			//print("mp3 list:", mp3FileNames)
			
		} catch let error as NSError {
			userSoundsURL.removeAll()
			print("[SoundManager] Failed to load custom sound files: ", error.localizedDescription)
		} //end try-catch
	} //end func
	
	////////////// alarm sounds
	static var list:Array<SoundData> = [
		SoundData(soundName: "alarmSounds8BitMelody", fileName: "sounds-alarms-8bitmelody.aiff"),
		
		SoundData(soundName: "Marble Soda", fileName: "sounds-alarms-test-marvelsoda.aiff"),
		SoundData(soundName: "占쏙옙占쏙옙", fileName: "sounds-alarms-test-sokyepsokyep.aiff"),
		SoundData(soundName: "냥냥-냐냐-냐냐냐냥", fileName: "sounds-alarms-test-nyancat.aiff")
	]
	
	//사운드 이름에 대한 실제 사운드 오브젝트 반환
	static func findSoundObjectWithFileName(_ soundFileName:String, isCustomSound:Bool = false) -> SoundData? {
		if (isCustomSound) {
			//CustomSound의 경우, 오브젝트를 새로 만듬.
			let tmpSoundData:SoundData = SoundData(soundName: "", fileName: "")
			tmpSoundData.soundURL = URL(fileURLWithPath: soundFileName)
			return tmpSoundData
		} //end if
		
		for i:Int in 0 ..< list.count {
			if (list[i].soundFileName == soundFileName) {
				return list[i]
			}
		} //end for
		
		return nil
	} //end func
	
}
