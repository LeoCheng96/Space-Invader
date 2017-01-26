//
//  GameViewController.swift
//
//  Created by Mei on 2016-12-31.
//  Copyright © 2016 LeoCheng. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

var backingAudio = AVAudioPlayer()
var bossAudio = AVAudioPlayer()

class GameViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "Fantasy_Game_Background", ofType: "mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        do {
            backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL)
        } catch {
            return print("Cannot find audio file")
        }
        
        backingAudio.numberOfLoops = -1
        backingAudio.volume = 1
        backingAudio.play()
        
        let filePathBoss = Bundle.main.path(forResource: "Into-Battle_v001", ofType: "mp3")
        let audioNSURLBoss = NSURL(fileURLWithPath: filePathBoss!)
        do {
            bossAudio = try AVAudioPlayer(contentsOf: audioNSURLBoss as URL)
        } catch {
            return print("Cannot find boss audio file")
        }
        
        bossAudio.numberOfLoops = -1
        bossAudio.volume = 1
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            // Present the scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
