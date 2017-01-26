//
//  SettingsScene.swift
//
//  Created by Mei on 2017-01-02.
//  Copyright © 2017 LeoCheng. All rights reserved.
//

import Foundation
import SpriteKit

var dotPosition = 921.6
var dotPositionTwo = 921.6

class SettingsScene: SKScene {
    
    let dot = SKSpriteNode(imageNamed: "dot")
    let dotTwo = SKSpriteNode(imageNamed: "dot")
    
    
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
        
        let backArrow = SKSpriteNode(imageNamed: "arrow")
        backArrow.position = CGPoint(x: self.size.width*0.18, y: self.size.height*0.94)
        backArrow.zPosition = 2
        backArrow.size = self.size
        backArrow.setScale(0.04)
        backArrow.name = "backArrow"
        self.addChild(backArrow)
        
        let musicLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
        musicLabel.text = "Music"
        musicLabel.fontSize = 50
        musicLabel.fontColor = SKColor.white
        musicLabel.position = CGPoint(x: self.size.width*0.3, y: self.size.height*0.7)
        musicLabel.zPosition = 2
        self.addChild(musicLabel)
        
        let sfxLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
        sfxLabel.text = "SFX"
        sfxLabel.fontSize = 50
        sfxLabel.fontColor = SKColor.white
        sfxLabel.position = CGPoint(x: self.size.width*0.3, y: self.size.height*0.6)
        sfxLabel.zPosition = 2
        self.addChild(sfxLabel)
        
        let bar = SKSpriteNode(imageNamed: "bar")
        bar.position = CGPoint(x: self.size.width*0.6, y: self.size.height*0.712)
        bar.zPosition = 2
        bar.setScale(9)
        bar.name = "bar"
        self.addChild(bar)
        
        let barTwo = SKSpriteNode(imageNamed: "bar")
        barTwo.position = CGPoint(x: self.size.width*0.6, y: self.size.height*0.612)
        barTwo.zPosition = 2
        barTwo.setScale(9)
        barTwo.name = "barTwo"
        self.addChild(barTwo)
        
        dot.position = CGPoint(x: CGFloat(dotPosition), y: self.size.height*0.708)
        dot.zPosition = 3
        dot.setScale(3)
        self.addChild(dot)
        
        
        dotTwo.position = CGPoint(x: CGFloat(dotPositionTwo), y: self.size.height*0.608)
        dotTwo.zPosition = 3
        dotTwo.setScale(3)
        self.addChild(dotTwo)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = nodes(at: pointOfTouch)
            
            if nodeITapped[0].name == "backArrow" {
                let sceneToMoveTo = MainMenuScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: transition)
            }
            
            print(pointOfTouch.x)
            
            
            if nodeITapped[0].name == "bar" {
                dot.position.x = pointOfTouch.x
            }
            
            if dot.position.x > 1199.400390625 {
                dot.position.x = 1199.400390625
            }
            
            if dot.position.x < 642.111022949219 {
                dot.position.x = 642.111022949219
            }
            
            if nodeITapped[0].name == "barTwo" {
                dotTwo.position.x = pointOfTouch.x
            }
            
            if dotTwo.position.x > 1199.400390625 {
                dotTwo.position.x = 1199.400390625
            }
            
            if dotTwo.position.x < 642.111022949219 {
                dotTwo.position.x = 642.111022949219
            }
            
            let middle = 642.111022949219 + (1199.400390625 - 642.111022949219)/2
            let volume = 2*(Double(dot.position.x)-642.111022949219)/middle
            
            backingAudio.volume = Float(volume)
            bossAudio.volume = Float(volume)
            
            dotPosition = Double(dot.position.x)
            dotPositionTwo = Double(dotTwo.position.x)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let nodeITapped = nodes(at: pointOfTouch)
            let previousPOT = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPOT.x
            
            if nodeITapped[0].name == "bar" {
                dot.position.x += amountDragged
            }
            
            if dot.position.x > 1199.400390625 {
                dot.position.x = 1199.400390625
            }
            
            if dot.position.x < 642.111022949219 {
                dot.position.x = 642.111022949219
            }
            
            if nodeITapped[0].name == "barTwo" {
                dotTwo.position.x += amountDragged
            }
            
            if dotTwo.position.x > 1199.400390625 {
                dotTwo.position.x = 1199.400390625
            }
            
            if dotTwo.position.x < 642.111022949219 {
                dotTwo.position.x = 642.111022949219
            }
            
            let middle = 642.111022949219 + (1199.400390625 - 642.111022949219)/2
            let volume = 2*(Double(dot.position.x)-642.111022949219)/middle
            
            backingAudio.volume = Float(volume)
            bossAudio.volume = Float(volume)
            
            dotPosition = Double(dot.position.x)
            dotPositionTwo = Double(dotTwo.position.x)
        }
    }
    
    
    
}
