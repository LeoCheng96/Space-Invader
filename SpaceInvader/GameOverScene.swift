//
//  GameOverScene.swift
//
//  Created by Mei on 2017-01-01.
//  Copyright © 2017 LeoCheng. All rights reserved.
//

import Foundation
import SpriteKit

let gameOverSound = SKAction.playSoundFileNamed("gameover.wav", waitForCompletion: true)
let restartSound = SKAction.playSoundFileNamed("sound18.mp3", waitForCompletion: false)


class GameOverScene: SKScene {
    
    let restartLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
    let backArrow = SKSpriteNode(imageNamed: "arrow")
    
    
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.size = self.size
        self.addChild(background)
        
        let blackBackground = SKSpriteNode(imageNamed: "overlay")
        blackBackground.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        blackBackground.zPosition = 1
        blackBackground.alpha = 0.5
        blackBackground.size = self.size
        self.addChild(blackBackground)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 2
        self.addChild(gameOverLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.6)
        scoreLabel.zPosition = 2
        self.addChild(scoreLabel)
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScore")
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScore")
            let scaleOut = SKAction.scale(to: 1.3, duration: 0.4)
            let scaleIn = SKAction.scale(to: 1, duration: 0.4)
            let fadeSequence = SKAction.sequence([scaleOut, scaleIn])
            let fadeForever = SKAction.repeatForever(fadeSequence)
            scoreLabel.run(fadeForever)
        }
        
        let highscoreLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
        highscoreLabel.text = "High Score: \(highScoreNumber)"
        highscoreLabel.fontSize = 70
        highscoreLabel.fontColor = SKColor.white
        highscoreLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
        highscoreLabel.zPosition = 2
        self.addChild(highscoreLabel)
        
        restartLabel.text = "RESTART"
        restartLabel.fontSize = 70
        restartLabel.fontColor = SKColor.white
        restartLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.30)
        restartLabel.zPosition = 2
        self.addChild(restartLabel)
        
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
        let fadeForever = SKAction.repeatForever(fadeSequence)
        restartLabel.run(fadeForever)
        
        backArrow.position = CGPoint(x: self.size.width*0.18, y: self.size.height*0.94)
        backArrow.zPosition = 2
        backArrow.size = self.size
        backArrow.setScale(0.04)
        backArrow.name = "backArrow"
        self.addChild(backArrow)
        
        let wait = SKAction.wait(forDuration: 0.18)
        let soundSequence = SKAction.sequence([wait, gameOverSound])
        self.run(soundSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch) {
                self.run(restartSound)
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
                
            } else if backArrow.contains(pointOfTouch) {
                
                let sceneToMoveTo = MainMenuScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
                
            }
            
        }
    }
    
}
