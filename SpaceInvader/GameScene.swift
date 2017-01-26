//
//  GameScene.swift
//
//  Created by Mei on 2016-12-31.
//  Copyright © 2016 LeoCheng. All rights reserved.
//

import SpriteKit
import GameplayKit

var gameScore = 0
let bulletSound = SKAction.playSoundFileNamed("laser2.wav", waitForCompletion: false)
let bossSound = SKAction.playSoundFileNamed("bossLaser.wav", waitForCompletion: false)
let explosionSound = SKAction.playSoundFileNamed("Explosion.wav", waitForCompletion: false)
let lifeSound = SKAction.playSoundFileNamed("health.wav", waitForCompletion: false)


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let scoreLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
    
    let levelLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
    let pause = SKSpriteNode(imageNamed: "pause")
    let playButton = SKSpriteNode(imageNamed: "play")
    
    var levelNumber = 0
    
    var livesNumber = 5
    var bossLivesNumber = 100
    let livesLabel = SKLabelNode(fontNamed: "Xcelsion Italic")
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let healthOutline = SKSpriteNode(imageNamed: "healthOut")
    let healthInside = SKSpriteNode(imageNamed: "healthIn")
    
    let wOverlay = SKSpriteNode(imageNamed: "whiteOverlay")
    
    let blackBackground = SKSpriteNode(imageNamed: "overlay")
    
    let boss = SKSpriteNode(imageNamed: "boss")
    
    var levelDuration = TimeInterval()
    
    var tempVol = backingAudio.volume
    var tempVol2 = bossAudio.volume
    
    
    enum gameState {
        case preGame
        case inGame
        case pauseGame
        case endGame
    }
    
    var currentGameState = gameState.preGame
    
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1
        static let Bullet : UInt32 = 0b10
        static let Life : UInt32 = 0b11
        static let Enemy : UInt32 = 0b100
        static let Boss : UInt32 = 0b101
        static let BossBullet : UInt32 = 0b111
    }
    
    let gameArea : CGRect
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat, max: CGFloat) -> CGFloat {
        return random()*(max-min)+min
    }
    
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth)/2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        levelDuration = 1.2
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background2")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
            background.name = "Background"
            background.zPosition = 0
            self.addChild(background)
        }
        
        wOverlay.size = self.size
        wOverlay.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        wOverlay.zPosition = 55
        wOverlay.alpha = 0
        self.addChild(wOverlay)
        
        player.setScale(3)
        player.position = CGPoint(x: self.size.width/2, y: 0-player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        healthOutline.size = CGSize(width: self.size.width*0.7, height: 225)
        healthOutline.position = CGPoint(x: self.size.width/2, y: self.size.height*0.95)
        healthOutline.zPosition = 5
        healthOutline.alpha = 0
        self.addChild(healthOutline)
        
        healthInside.size = CGSize(width: self.size.width*0.6255, height: 45)
        healthInside.position = CGPoint(x: self.size.width*0.186, y: self.size.height*0.951)
        healthInside.zPosition = 5
        healthInside.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthInside.alpha = 0
        self.addChild(healthInside)
        
        blackBackground.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        blackBackground.zPosition = 6
        blackBackground.alpha = 0
        blackBackground.size = self.size
        self.addChild(blackBackground)
        
        scoreLabel.text = "Score:0"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height+scoreLabel.frame.size.height)
        scoreLabel.zPosition = 10
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: \(livesNumber)"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height+livesLabel.frame.size.height)
        livesLabel.zPosition = 10
        self.addChild(livesLabel)
        
        pause.setScale(2.5)
        pause.position = CGPoint(x: self.size.width/2, y: self.size.height*0.91)
        pause.name = "pause"
        pause.zPosition = 10
        pause.alpha = 0
        self.addChild(pause)
        
        playButton.setScale(1)
        playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        playButton.name = "play"
        playButton.zPosition = 10
        playButton.alpha = 0
        self.addChild(playButton)
        
        let moveOntoScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOntoScreenAction)
        livesLabel.run(moveOntoScreenAction)
        
        tapToStartLabel.text = "TAP TO BEGIN"
        tapToStartLabel.fontSize = 75
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.7)
        tapToStartLabel.zPosition = 2
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.7)
        let fadeIn = SKAction.fadeIn(withDuration: 0.7)
        let fadeSequence = SKAction.sequence([fadeIn, fadeOut])
        let fadeForever = SKAction.repeatForever(fadeSequence)
        tapToStartLabel.run(fadeForever)
        
        boss.setScale(2.5)
        boss.name = "Boss"
        boss.position = CGPoint(x: self.size.width/2, y: self.size.height*1.2)
        boss.zPosition = 2
        boss.physicsBody = SKPhysicsBody(rectangleOf: boss.size)
        boss.physicsBody?.affectedByGravity = false
        boss.physicsBody?.categoryBitMask = PhysicsCategories.Boss
        boss.physicsBody?.collisionBitMask = PhysicsCategories.None
        boss.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.addChild(boss)
        
    }
    
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        scoreLabel.run(scaleSequence)
        
        
        if gameScore == 10 || gameScore == 20 || gameScore == 30 || gameScore == 40 || gameScore == 50 || gameScore == 60 || gameScore == 70 || gameScore == 80 || gameScore == 90  {
            
            spawnBoss()
            
        }
        
        if gameScore == 100 {
            startNewLevel()
            levelLabel.text = "Survive"
            let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
            let sequence = SKAction.sequence([fadeIn, fadeOut, fadeIn, fadeOut,fadeIn, fadeOut])
            levelLabel.run(sequence)
            
        }
    }
    
    var lastUpdateTime : TimeInterval = 0
    var deltaFrameTime : TimeInterval = 0
    var amountToMovePerSecond : CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond*CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background", using: {
            background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height*2
            }
        })
        
    }
    
    func runGameOver() {
        
        
        
        currentGameState = gameState.endGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet", using: {
            bullet, stop in
            bullet.removeAllActions()
        })
        self.enumerateChildNodes(withName: "Enemy", using: {
            enemy, stop in
            enemy.removeAllActions()
        })
        
        let changeSceneAction = SKAction.run {
            self.changeScene()
        }
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([changeSceneAction, waitToChangeScene])
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: transition)
        
    }
    
    func loseLife() {
        
        livesNumber -= 1
        
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        let fadeIn = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let sequence = SKAction.sequence([ fadeIn, fadeOut])
        wOverlay.run(sequence)
        
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    
    func gainLife() {
        
        livesNumber += 1
        
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let colorize = SKAction.run {
            self.livesLabel.color = SKColor.red
        }
        let decolorize = SKAction.run {
            self.livesLabel.color = SKColor.white
        }
        let scaleSequence = SKAction.sequence([colorize, scaleUp, scaleDown, decolorize])
        livesLabel.run(scaleSequence)
        
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //assign lowest category number to body1
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            // if player hit enemy
            
            let explosion = SKSpriteNode(imageNamed: "explosion")
            explosion.position = body1.node!.position
            explosion.zPosition = 5
            explosion.setScale(2)
            explosion.name = "explosion"
            self.addChild(explosion)
            
            let explosion2 = SKSpriteNode(imageNamed: "explosion")
            explosion2.position = body2.node!.position
            explosion2.zPosition = 5
            explosion2.setScale(2)
            explosion2.name = "explosion2"
            self.addChild(explosion2)
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            livesNumber = 0
            livesLabel.text = "Lives: \(livesNumber)"
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            livesLabel.run(scaleSequence)
            
            let runGO = SKAction.run {
                self.runGameOver()
            }
            let runOverlay = SKAction.run {
                self.overlayRun()
            }
            let overSequence = SKAction.sequence([explosionSound, runOverlay, runGO])
            
            
            self.run(overSequence)
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.BossBullet {
            // if player hit bossBullet
            
            livesNumber -= 1
            livesLabel.text = "Lives: \(livesNumber)"
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            livesLabel.run(scaleSequence)
            
            let fadeIn = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
            let sequence = SKAction.sequence([ fadeIn, fadeOut])
            wOverlay.run(sequence)
            
            if livesNumber > 0 {
                spawnExplosion(spawnPosition: body2.node!.position)
                body2.node?.removeFromParent()
            } else {
                
                if #available(iOS 10.0, *) {
                    backingAudio.setVolume(tempVol, fadeDuration: 2)
                } else {
                    backingAudio.volume = tempVol
                    backingAudio.play()
                }
                if #available(iOS 10.0, *) {
                    bossAudio.setVolume(0, fadeDuration: 2)
                    bossAudio.stop()
                    bossAudio.volume = tempVol2
                } else {
                    bossAudio.stop()
                }
                
                let explosion2 = SKSpriteNode(imageNamed: "explosion")
                explosion2.position = body1.node!.position
                explosion2.zPosition = 5
                explosion2.setScale(2)
                explosion2.name = "explosion2"
                self.addChild(explosion2)
                
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
                
                let runGO = SKAction.run {
                    self.runGameOver()
                }
                let runOverlay = SKAction.run {
                    self.overlayRun()
                }
                let overSequence = SKAction.sequence([explosionSound, runOverlay, runGO])
                
                self.run(overSequence)
                
            }
        }
        
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Boss {
            // if player hit boss
            
            let explosion = SKSpriteNode(imageNamed: "explosion")
            explosion.position = body1.node!.position
            explosion.zPosition = 5
            explosion.setScale(2)
            explosion.name = "explosion"
            self.addChild(explosion)
            
            body1.node?.removeFromParent()
            
            
            livesNumber = 0
            livesLabel.text = "Lives: \(livesNumber)"
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1, duration: 0.2)
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            livesLabel.run(scaleSequence)
            
            if #available(iOS 10.0, *) {
                backingAudio.setVolume(tempVol, fadeDuration: 2)
            } else {
                backingAudio.volume = tempVol
                backingAudio.play()
            }
            if #available(iOS 10.0, *) {
                bossAudio.setVolume(0, fadeDuration: 2)
                bossAudio.stop()
                bossAudio.volume = tempVol2
            } else {
                bossAudio.stop()
            }
            
            
            let runGO = SKAction.run {
                self.runGameOver()
            }
            let runOverlay = SKAction.run {
                self.overlayRun()
            }
            let overSequence = SKAction.sequence([explosionSound, runOverlay, runGO])
            
            
            self.run(overSequence)
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy  {
            // if bullet hit enemy
            
            addScore()
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Boss  {
            //if bullet hit boss
            
            if boss.position.y < self.size.height + boss.size.height/2 {
                bossLivesNumber -= 1
                
                
                if healthInside.size.width > 0 {
                    healthInside.size.width -= self.size.width*0.6255/CGFloat(levelNumber*100)
                }
                
                if body1.node != nil {
                    spawnExplosion(spawnPosition: body1.node!.position)
                }
                
                body1.node?.removeFromParent()
            }
            
            if bossLivesNumber == 0 {
                
                self.removeAction(forKey: "spawningBullets")
                
                healthInside.alpha = 0
                
                if boss.action(forKey: "wiggling") != nil {
                    boss.removeAction(forKey: "wiggling")
                }
                
                let moveBack = SKAction.moveTo(y: self.size.height*1.2, duration: 2)
                boss.run(moveBack)
                
                let moveIn = SKAction.moveTo(y: self.size.height*0.9, duration: 2)
                let fadeInward = SKAction.fadeAlpha(to: 1, duration: 2)
                scoreLabel.run(moveIn)
                livesLabel.run(moveIn)
                pause.run(fadeInward)
                
                let fadeOutward = SKAction.fadeAlpha(to: 0, duration: 2)
                healthOutline.run(fadeOutward)
                
                
                if #available(iOS 10.0, *) {
                    backingAudio.setVolume(tempVol, fadeDuration: 2)
                    backingAudio.play()
                } else {
                    backingAudio.volume = tempVol
                    backingAudio.play()
                }
                if #available(iOS 10.0, *) {
                    bossAudio.setVolume(0, fadeDuration: 2)
                    bossAudio.stop()
                    bossAudio.volume = tempVol2
                    bossAudio.stop()
                } else {
                    bossAudio.stop()
                }
                
                startNewLevel()
                levelLabel.text = "Level \(gameScore/10)"
                let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1)
                let sequence = SKAction.sequence([fadeIn, fadeOut])
                levelLabel.run(sequence)
                
            }
        }
        
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Life  {
            // if player hit life
            
            self.gainLife()
            
            if body2.node != nil {
                spawnLife(spawnPosition: body2.node!.position)
            }
            
            body2.node?.removeFromParent()
        }
    }
    
    func overlayRun() {
        let fadeIn = SKAction.fadeAlpha(to: 0.2, duration: 0.2)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let sequence = SKAction.sequence([ fadeIn, fadeOut])
        wOverlay.run(sequence)
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 5
        explosion.setScale(0)
        explosion.name = "explosion3"
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func spawnLife(spawnPosition: CGPoint) {
        
        let lifeGain = SKSpriteNode(imageNamed: "lifeGain")
        lifeGain.position = spawnPosition
        lifeGain.zPosition = 5
        lifeGain.setScale(0)
        lifeGain.name = "lifeGain"
        self.addChild(lifeGain)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let delete = SKAction.removeFromParent()
        
        let lifeSequence = SKAction.sequence([lifeSound, scaleIn, fadeOut, delete])
        
        lifeGain.run(lifeSequence)
    }
    
    
    func fireBullet() {
        if gameScore < 20 {
            let bullet = SKSpriteNode(imageNamed: "bullet")
            bullet.setScale(1)
            bullet.name = "Bullet"
            bullet.position = player.position
            bullet.zPosition = 1
            bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
            bullet.physicsBody?.affectedByGravity = false
            bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
            bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
            bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
            self.addChild(bullet)
            
            let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
            let deleteBullet = SKAction.removeFromParent()
            let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
            
            bullet.run(bulletSequence)
        } else if gameScore < 40  {
            self.fireBulletTwo()
        } else {
            self.fireBulletThree()
        }
        
    }
    
    func fireBulletTwo() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.name = "Bullet"
        bullet.position = CGPoint(x: player.position.x-30, y: player.position.y)
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let bulletTwo = SKSpriteNode(imageNamed: "bullet")
        bulletTwo.setScale(1)
        bulletTwo.name = "Bullet"
        bulletTwo.position = CGPoint(x: player.position.x+30, y: player.position.y)
        bulletTwo.zPosition = 1
        bulletTwo.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bulletTwo.physicsBody?.affectedByGravity = false
        bulletTwo.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bulletTwo.physicsBody?.collisionBitMask = PhysicsCategories.None
        bulletTwo.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bulletTwo)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let delay = SKAction.wait(forDuration: 0.1)
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        let bulletSequence2 = SKAction.sequence([delay, bulletSound, moveBullet, deleteBullet])
        
        bullet.run(bulletSequence)
        bulletTwo.run(bulletSequence2)
        
    }
    
    func fireBulletThree() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.name = "Bullet"
        bullet.position = CGPoint(x: player.position.x-95, y: player.position.y)
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let bulletTwo = SKSpriteNode(imageNamed: "bullet")
        bulletTwo.setScale(1)
        bulletTwo.name = "Bullet"
        bulletTwo.position = CGPoint(x: player.position.x+95, y: player.position.y)
        bulletTwo.zPosition = 1
        bulletTwo.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bulletTwo.physicsBody?.affectedByGravity = false
        bulletTwo.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bulletTwo.physicsBody?.collisionBitMask = PhysicsCategories.None
        bulletTwo.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bulletTwo)
        
        let bulletThree = SKSpriteNode(imageNamed: "bullet")
        bulletThree.setScale(1)
        bulletThree.name = "Bullet"
        bulletThree.position = CGPoint(x: player.position.x+30, y: player.position.y)
        bulletThree.zPosition = 1
        bulletThree.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bulletThree.physicsBody?.affectedByGravity = false
        bulletThree.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bulletThree.physicsBody?.collisionBitMask = PhysicsCategories.None
        bulletThree.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bulletThree)
        
        let bulletFour = SKSpriteNode(imageNamed: "bullet")
        bulletFour.setScale(1)
        bulletFour.name = "Bullet"
        bulletFour.position = CGPoint(x: player.position.x-30, y: player.position.y)
        bulletFour.zPosition = 1
        bulletFour.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bulletFour.physicsBody?.affectedByGravity = false
        bulletFour.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bulletFour.physicsBody?.collisionBitMask = PhysicsCategories.None
        bulletFour.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bulletFour)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let delay = SKAction.wait(forDuration: 0.1)
        let bulletSequence = SKAction.sequence([ bulletSound, moveBullet, deleteBullet])
        let bulletSequence2 = SKAction.sequence([delay, bulletSound, moveBullet, deleteBullet])
        
        
        bullet.run(bulletSequence)
        bulletTwo.run(bulletSequence2)
        bulletThree.run(bulletSequence)
        bulletFour.run(bulletSequence2)
        
    }
    
    
    func fireBulletForever() {
        let fire = SKAction.run {
            self.fireBullet()
        }
        let wait = SKAction.wait(forDuration: 0.2)
        let fireSequence = SKAction.sequence([fire, wait])
        let fireForever = SKAction.repeatForever(fireSequence)
        self.run(fireForever)
    }
    
    
    func startNewLevel() {
        
        levelNumber += 1
        amountToMovePerSecond += 150
        
        
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1.1
        case 3: levelDuration = 1.0
        case 4: levelDuration = 0.9
        case 5: levelDuration = 0.8
        case 6: levelDuration = 0.7
        case 7: levelDuration = 0.6
        case 8: levelDuration = 0.5
        case 9: levelDuration = 0.4
        case 10: levelDuration = 0.1
        default: levelDuration = 0.2
        print("Cannot find level info")
        }
        
        
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        if self.action(forKey: "spawningLives") != nil {
            self.removeAction(forKey: "spawningLives")
        }
        
        let spawn = SKAction.run {
            self.spawnEnemy()
        }
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
        if levelNumber > 1 {
            let spawnLife = SKAction.run {
                self.spawnLife()
            }
            let waitToSpawnLife = SKAction.wait(forDuration: 3)
            let spawnLifeSequence = SKAction.sequence([waitToSpawnLife, spawnLife])
            //let spawnLifeForever = SKAction.repeatForever(spawnLifeSequence)
            self.run(spawnLifeSequence, withKey: "spawningLives")
        }
    }
    
    func spawnEnemy() {
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height*0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1.8)
        enemy.name = "Enemy"
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseLifeAction = SKAction.run {
            self.loseLife()
            let position = CGPoint(x: enemy.position.x, y: 0)
            self.spawnExplosion(spawnPosition: position)
            
        }
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLifeAction])
        
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    func spawnBoss() {
        
        bossLivesNumber = levelNumber*100
        healthInside.size.width = self.size.width*0.6255
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        if #available(iOS 10.0, *) {
            tempVol = backingAudio.volume
            backingAudio.setVolume(0, fadeDuration: 2)
        } else {
            backingAudio.stop()
        }
        if #available(iOS 10.0, *) {
            bossAudio.volume = 0
            bossAudio.play()
            bossAudio.setVolume(tempVol2, fadeDuration: 3)
        } else {
            bossAudio.play()
        }
        let moveIn = SKAction.moveTo(y: self.size.height*0.85, duration: 3)
        boss.run(moveIn)
        
        let moveOut = SKAction.moveTo(y: self.size.height*1.2, duration: 2)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1)
        scoreLabel.run(moveOut)
        livesLabel.run(moveOut)
        pause.run(fadeOut)
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 2)
        healthOutline.run(fadeIn)
        healthInside.run(fadeIn)
        
        let wiggle = SKAction.moveTo(y: self.size.height*0.88, duration: 5)
        let wiggleBack = SKAction.moveTo(y: self.size.height*0.82, duration: 5)
        let sequence = SKAction.sequence([wiggle, wiggleBack])
        let wiggleForever = SKAction.repeatForever(sequence)
        boss.run(wiggleForever, withKey: "wiggling")
        
        let wait = SKAction.wait(forDuration: 1.5)
        let spawn = SKAction.run {
            self.bossFire()
        }
        let waitToSpawn = SKAction.wait(forDuration: levelDuration+0.25)
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(wait)
        self.run(spawnForever, withKey: "spawningBullets")
        
    }
    
    func bossFire() {
        
        let number = arc4random_uniform(7) + 1;
        print(number)
        
        let bullet = SKSpriteNode(imageNamed: "bossBullet")
        bullet.setScale(2)
        bullet.name = "bossBullet"
        bullet.position = CGPoint(x: self.size.width*0.2, y: boss.position.y*0.9)
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 1 {
            self.addChild(bullet)
        }
        
        let bullet2 = SKSpriteNode(imageNamed: "bossBullet")
        bullet2.setScale(2)
        bullet2.name = "bossBullet"
        bullet2.position = CGPoint(x: self.size.width*0.3, y: boss.position.y*0.9)
        bullet2.zPosition = 1
        bullet2.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet2.physicsBody?.affectedByGravity = false
        bullet2.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet2.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet2.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 2 {
            self.addChild(bullet2)
        }
        
        let bullet3 = SKSpriteNode(imageNamed: "bossBullet")
        bullet3.setScale(2)
        bullet3.name = "bossBullet"
        bullet3.position = CGPoint(x: self.size.width*0.4, y: boss.position.y*0.9)
        bullet3.zPosition = 1
        bullet3.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet3.physicsBody?.affectedByGravity = false
        bullet3.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet3.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet3.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 3 {
            self.addChild(bullet3)
        }
        
        let bullet4 = SKSpriteNode(imageNamed: "bossBullet")
        bullet4.setScale(2)
        bullet4.name = "bossBullet"
        bullet4.position = CGPoint(x: self.size.width*0.5, y: boss.position.y*0.9)
        bullet4.zPosition = 1
        bullet4.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet4.physicsBody?.affectedByGravity = false
        bullet4.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet4.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet4.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 4 {
            self.addChild(bullet4)
        }
        
        let bullet5 = SKSpriteNode(imageNamed: "bossBullet")
        bullet5.setScale(2)
        bullet5.name = "bossBullet"
        bullet5.position = CGPoint(x: self.size.width*0.6, y: boss.position.y*0.9)
        bullet5.zPosition = 1
        bullet5.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet5.physicsBody?.affectedByGravity = false
        bullet5.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet5.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet5.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 5 {
            self.addChild(bullet5)
        }
        let bullet6 = SKSpriteNode(imageNamed: "bossBullet")
        bullet6.setScale(2)
        bullet6.name = "bossBullet"
        bullet6.position = CGPoint(x: self.size.width*0.7, y: boss.position.y*0.9)
        bullet6.zPosition = 1
        bullet6.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet6.physicsBody?.affectedByGravity = false
        bullet6.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet6.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet6.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 6 {
            self.addChild(bullet6)
        }
        
        let bullet7 = SKSpriteNode(imageNamed: "bossBullet")
        bullet7.setScale(2)
        bullet7.name = "bossBullet"
        bullet7.position = CGPoint(x: self.size.width*0.8, y: boss.position.y*0.9)
        bullet7.zPosition = 1
        bullet7.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet7.physicsBody?.affectedByGravity = false
        bullet7.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bullet7.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet7.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        if number != 7 {
            self.addChild(bullet7)
        }
        
        let moveBullet = SKAction.moveTo(y: 0 - bullet.size.height, duration: 3)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bossSound, moveBullet, deleteBullet])
        let soundlessBulletSequence = SKAction.sequence([moveBullet, deleteBullet])
        
        bullet.run(bulletSequence)
        bullet2.run(soundlessBulletSequence)
        bullet3.run(bulletSequence)
        bullet4.run(soundlessBulletSequence)
        bullet5.run(bulletSequence)
        bullet6.run(soundlessBulletSequence)
        bullet7.run(bulletSequence)
    }
    
    func spawnLife() {
        let randomYStart = random(min: gameArea.maxY/3, max: gameArea.maxY-10)
        let randomYEnd = random(min: gameArea.maxY/3, max: gameArea.maxY-10)
        
        var startPoint = CGPoint(x: 0, y: 0)
        var endPoint = CGPoint(x: 0, y: 0)
        
        let randomNumber = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        if randomNumber > 0.5 {
            startPoint = CGPoint(x: -5, y: randomYStart)
            endPoint = CGPoint(x: self.size.width+10, y: randomYEnd)
        } else {
            startPoint = CGPoint(x: self.size.width+5, y: randomYEnd)
            endPoint = CGPoint(x: -10, y: randomYStart)
            
        }
        
        let life = SKSpriteNode(imageNamed: "heart")
        life.setScale(0.5)
        life.name = "life"
        life.position = startPoint
        life.zPosition = 2
        life.physicsBody = SKPhysicsBody(rectangleOf: life.size)
        life.physicsBody?.affectedByGravity = false
        life.physicsBody?.categoryBitMask = PhysicsCategories.Life
        life.physicsBody?.collisionBitMask = PhysicsCategories.None
        life.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.addChild(life)
        
        let moveLife = SKAction.move(to: endPoint, duration: 3)
        let deleteLife = SKAction.removeFromParent()
        let lifeSequence = SKAction.sequence([moveLife, deleteLife])
        
        if currentGameState == gameState.inGame {
            life.run(lifeSequence)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.pauseGame {
            let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 0.1)
            pause.run(fadeInAction)
            
            let fadeOutAction = SKAction.fadeAlpha(to: 0, duration: 0.1)
            playButton.run(fadeOutAction)
            
            backingAudio.play()
            currentGameState = gameState.inGame
            
            let spawn = SKAction.run {
                self.spawnEnemy()
            }
            let waitToSpawn = SKAction.wait(forDuration: levelDuration)
            let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
            let spawnForever = SKAction.repeatForever(spawnSequence)
            self.run(spawnForever, withKey: "spawningEnemies")
            
            self.enumerateChildNodes(withName: "Bullet", using: {
                bullet, stop in
                bullet.isPaused = false
            })
            self.enumerateChildNodes(withName: "Enemy", using: {
                enemy, stop in
                enemy.isPaused = false
                
            })
            self.enumerateChildNodes(withName: "explosion3", using: {
                explosion, stop in
                explosion.isPaused = false
            })
            
            levelLabel.isPaused = false
            
            let fadeOutSmallAction = SKAction.fadeAlpha(to: 0, duration: 0.1)
            blackBackground.run(fadeOutSmallAction)
            
        } else if currentGameState == gameState.inGame {
            for touch: AnyObject in touches {
                let pointOfTouch = touch.location(in: self)
                let nodeITapped = nodes(at: pointOfTouch)
                
                
                if nodeITapped[0].name == "pause" {
                    let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 0.1)
                    playButton.run(fadeInAction)
                    
                    let fadeOutAction = SKAction.fadeAlpha(to: 0, duration: 0.1)
                    pause.run(fadeOutAction)
                    
                    backingAudio.pause()
                    currentGameState = gameState.pauseGame
                    
                    if self.action(forKey: "spawningEnemies") != nil {
                        self.removeAction(forKey: "spawningEnemies")
                    }
                    self.enumerateChildNodes(withName: "Bullet", using: {
                        bullet, stop in
                        bullet.isPaused = true
                    })
                    self.enumerateChildNodes(withName: "Enemy", using: {
                        enemy, stop in
                        enemy.isPaused = true
                    })
                    
                    self.enumerateChildNodes(withName: "explosion3", using: {
                        explosion, stop in
                        explosion.isPaused = true
                    })
                    levelLabel.isPaused = true
                    
                    
                    let fadeInSmallAction = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
                    blackBackground.run(fadeInSmallAction)
                    
                } else {
                    
                    if currentGameState == gameState.inGame {
                        let move = SKAction.move(to: pointOfTouch, duration: 0.2)
                        player.run(move)
                        
                        if self.action(forKey: "firing") != nil {
                            self.removeAction(forKey: "firing")
                        }
                        let fire = SKAction.run {
                            self.fireBullet()
                        }
                        let wait = SKAction.wait(forDuration: 0.2)
                        let fireSequence = SKAction.sequence([fire, wait])
                        let fireForever = SKAction.repeatForever(fireSequence)
                        self.run(fireForever, withKey: "firing")
                    }
                }
            }
            
        }
        else if currentGameState == gameState.preGame {
            startGame()
            levelLabel.text = "Level 0"
            levelLabel.fontSize = 70
            levelLabel.fontColor = SKColor.white
            levelLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.7)
            levelLabel.alpha = 0
            levelLabel.zPosition = 10
            self.addChild(levelLabel)
            
            let wait = SKAction.wait(forDuration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.5)
            let fadeOut = SKAction.fadeAlpha(to: 0, duration: 1)
            let sequence = SKAction.sequence([wait, fadeIn, fadeOut])
            levelLabel.run(sequence)
        }
    }
    
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run {
            self.startNewLevel()
        }
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        
        let fadeInAction = SKAction.fadeAlpha(to: 1, duration: 0.5)
        pause.run(fadeInAction)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPOT = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPOT.x
            let amountDraggedY = pointOfTouch.y - previousPOT.y
            
            if currentGameState == gameState.inGame {
                player.position.x = player.position.x + amountDragged
                player.position.y = player.position.y + amountDraggedY
            }
            
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
            if player.position.y > gameArea.maxY - player.size.height/2{
                player.position.y = gameArea.maxY - player.size.height/2
            }
            
            if player.position.y < gameArea.minY + player.size.height/2 {
                player.position.y = gameArea.minY + player.size.height/2
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.inGame {
            
            if self.action(forKey: "firing") != nil {
                self.removeAction(forKey: "firing")
            }
            
        }
    }
    
}
