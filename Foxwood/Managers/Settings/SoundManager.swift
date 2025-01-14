//
//  SoundManager.swift
//  Foxwood
//
//  Created by Alex on 13.01.2025.
//

import AVKit

final class SoundManager {
    static let shared = SoundManager()
    
    var soundPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    
    private var wasPlayingBeforeBackground = false
    
    private init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleAppDidEnterBackground() {
        wasPlayingBeforeBackground = musicPlayer?.isPlaying ?? false
        stopMusic()
    }
    
    @objc private func handleAppWillEnterForeground() {
        if wasPlayingBeforeBackground && SettingsManager.shared.isMusicOn {
            playMusic()
        }
    }
    
    func playSound() {
        guard SettingsManager.shared.isSoundOn else { return }
        guard let url = Bundle.main.url(forResource: "click", withExtension: "mp3") else { return }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func playMusic() {
        guard SettingsManager.shared.isMusicOn else { return }
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else { return }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func stopMusic() {
        musicPlayer?.stop()
    }
    
    func updateMusicState() {
        if SettingsManager.shared.isMusicOn {
            playMusic()
        } else {
            stopMusic()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
