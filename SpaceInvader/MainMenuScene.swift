//
//  MainMenuScene.swift
//
//  Created by Mei on 2017-01-01.
//  Copyright © 2017 LeoCheng. All rights reserved.
//

import Foundation
import SpriteKit

let startSound = SKAction.playSoundFileNamed("sound18.mp3", waitForCompletion: false)

class MainMenuScene : SKScene {
    
    let startGame = SKLabelNode(fontNamed: "Xcelsion Italic")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.size = self.size
        self.addChild(background)
        
        let gameBy = SKLabelNode(fontNamed: "Xcelsion Italic")
        gameBy.text = "Leo Cheng"
        gameBy.fontSize = 35
        gameBy.fontColor = SKColor.white
        gameBy.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.76)
        gameBy.zPosition = 1
        self.addChild(gameBy)
        
        let gameName1 = SKLabelNode(fontNamed: "Xcelsion Italic")
        gameName1.text = "SPACE"
        gameName1.fontSize = 125
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "Xcelsion Italic")
        gameName2.text = "INVADERS"
        gameName2.fontSize = 125
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.64)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        
        startGame.text = "START GAME"
        startGame.fontSize = 80
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.4)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
        let fadeForever = SKAction.repeatForever(fadeSequence)
        startGame.run(fadeForever)
        
        let settings = SKSpriteNode(imageNamed: "music")
        settings.position = CGPoint(x: self.size.width*0.83, y: self.size.height*0.94)
        settings.zPosition = 2
        settings.size = self.size
        settings.setScale(0.03)
        settings.name = "settings"
        self.addChild(settings)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = nodes(at: pointOfTouch)
            
            if nodeITapped[0].name == "startButton" {
                
                self.run(startSound)
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
            }
            
            if nodeITapped[0].name == "settings" {
                let sceneToMoveTo = SettingsScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
            }
            
        }
    }
    
}
