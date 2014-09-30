//
//  GameViewController.swift
//  Crunchies
//
//  Created by JOSH HENDERSHOT on 9/23/14.
//  Copyright (c) 2014 Joshua Hendershot. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import iAd
import GameKit
import CoreMotion


let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
let IS_IPHONE5 = UIScreen.mainScreen().bounds.size.height == 568
let IS_IPHONE6 = UIScreen.mainScreen().bounds.size.height == 667
let IS_IPHONE6PLUS = UIScreen.mainScreen().bounds.size.height == 736


extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, ADBannerViewDelegate {
    var scene: GameScene!
    var level: Level!
    var noElfinWay: Int!
    var player: GKLocalPlayer = GKLocalPlayer.localPlayer()
    var allLeaderboards: [String:GKLeaderboard] = Dictionary()
    

    var currentLevel: Int!
    var movesLeft = 0
    var score = 0
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    lazy var backgroundMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("happyland_128", withExtension: "mp3")
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        player.numberOfLoops = -1
        return player
        }()
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var shuffleButton: UIButton!
    
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
    }
    func handleSwipe(swap: Swap) {
        
        view.userInteractionEnabled = false
        
        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let levelCheck = NSUserDefaults.standardUserDefaults().objectForKey("level") as Int!
        let diffCheck = NSUserDefaults.standardUserDefaults().objectForKey("difficulty") as Int!

        
        if levelCheck == nil {
            currentLevel = 0
            NSUserDefaults.standardUserDefaults().setInteger(currentLevel, forKey: "level")
            NSUserDefaults.standardUserDefaults().synchronize()
            println("new game works")
        } else {
            currentLevel = NSUserDefaults.standardUserDefaults().objectForKey("level") as Int
            println("different level!")
        }
        if diffCheck == nil {
            noElfinWay = 0
            NSUserDefaults.standardUserDefaults().setInteger(noElfinWay, forKey: "difficulty")
            NSUserDefaults.standardUserDefaults().synchronize()
            println("diff check works works")

        }
        
        noElfinWay = NSUserDefaults.standardUserDefaults().objectForKey("difficulty") as Int
        
        var nc = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("newGame", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification:NSNotification!) -> Void in
            self.resetGameNormal()
            println("got the message!")
        })
        nc.addObserverForName("newGameElfin", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification:NSNotification!) -> Void in
            self.resetGameElfin()
            println("got the Elfin message!")
        })
        

        
//        currentLevel = 4
//        NSUserDefaults.standardUserDefaults().setInteger(noElfinWay, forKey: "difficulty")
//        NSUserDefaults.standardUserDefaults().synchronize()
        
        var nC = NSNotificationCenter.defaultCenter()
        nC.addObserver(self, selector: Selector("authChanged"), name: GKPlayerAuthenticationDidChangeNotificationName, object: nil)
        
        if player.authenticated == false {
            player.authenticateHandler = {(viewController,error) -> Void in
                
                if viewController != nil {
                    
                    self.presentViewController(viewController, animated: true, completion: nil)
                    
                }
            }
        }
        
        var bannerView = ADBannerView(adType: ADAdType.Banner)
        bannerView.delegate = self
        
        if IS_IPHONE5 {
            
            bannerView.frame = CGRectMake(0, 518, 320, 50)
            
        } else if IS_IPHONE6 {
            bannerView.frame = CGRectMake(0, 617, 320, 50)
            
        } else {
            bannerView.frame = CGRectMake(0, 696, 320, 50)
        }
        self.view.addSubview(bannerView)
        
        println("tee hee 1")
//        loadedView()
        
        beginGame()
        
    }
    
    func loadedView() {
        
   
        
        println("tee hee loadedview")

        // Let's start the game!
    }
    func showGameOver() {
        
        gameOverPanel.hidden = false
        scene.userInteractionEnabled = false
        shuffleButton.hidden = true
        
        submitScore()
        
        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        
        gameOverPanel.hidden = true
        scene.userInteractionEnabled = true
        
        beginGame()
        
    }
    func beginGame() {
        
        println("tee hee 2")
        
        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        // Load the level.
        level = Level(filename: "Level_\(String(currentLevel))")
        println("Level_\(String(currentLevel))")
        scene.level = level
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        
        // Hide the game over panel from the screen.
        gameOverPanel.hidden = true
        shuffleButton.hidden = true
        
        // Present the scene.
        skView.presentScene(scene)
        
        // Load and start background music.
        backgroundMusic.play()
        
        if noElfinWay == 1 {
            if IS_IPHONE5 {
                var image = UIImageView(frame: CGRectMake(20, 15, 30, 30))
                image.image = UIImage(named: "elfinIcon")
                self.view.addSubview(image)
            } else {
                var image = UIImageView(frame: CGRectMake(30, 22, 25, 25))
                image.image = UIImage(named: "elfinIcon")
                self.view.addSubview(image)
            }
            
        }
        
        
//        loadedView()
        if noElfinWay == 1 {
            movesLeft = level.maximumMoves - 5
        } else {
            movesLeft = level.maximumMoves
        }
        score = 0
        updateLabels()
        level.resetComboMultiplier()
        scene.animateBeginGame() {
            self.shuffleButton.hidden = false
        }
        
        shuffle()
    }
    func decrementMoves() {
        --movesLeft
        updateLabels()
        if currentLevel == 4 && score >= level.targetScore {
            self.presentViewController(GameResetViewController(), animated: true, completion: nil)
        } else if score >= level.targetScore  {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevel!++
            NSUserDefaults.standardUserDefaults().setInteger(currentLevel, forKey: "level")
            NSUserDefaults.standardUserDefaults().setInteger(noElfinWay, forKey: "difficulty")
            NSUserDefaults.standardUserDefaults().synchronize()
            showGameOver()
        }
        else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            submitScore()
            showGameOver()
        }
    }
    func resetGameNormal() {
        currentLevel = 0
        NSUserDefaults.standardUserDefaults().setInteger(currentLevel, forKey: "level")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        beginGame()
    }
    func resetGameElfin() {
        noElfinWay = 1
        NSUserDefaults.standardUserDefaults().setInteger(noElfinWay, forKey: "difficulty")
        NSUserDefaults.standardUserDefaults().synchronize()
        resetGameNormal()
        println("noelfinway is true")
        
    }
    func shuffle() {
        scene.removeAllCookieSprites()
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            beginNextTurn()
            return
        }
        scene.animateMatchedCookies(chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()
            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns) {
                    self.handleMatches()
                }
            }
        }
    }
    func beginNextTurn() {
        decrementMoves()
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.userInteractionEnabled = true
    }
    func updateLabels() {
        
        levelLabel.text = NSString(format: "%ld", currentLevel + 1)
        targetLabel.text = NSString(format: "%ld", level.targetScore)
        movesLabel.text = NSString(format: "%ld", movesLeft)
        scoreLabel.text = NSString(format: "%ld", score)
    }
    @IBAction func shuffleButtonPressed(AnyObject) {
        shuffle()
        decrementMoves()
    }
    
    func authChanged() {
        
        if player.authenticated == false {return}
        
        GKLeaderboard.loadLeaderboardsWithCompletionHandler { (leaderboards, error) -> Void in
            
            
            for leaderboard in leaderboards as [GKLeaderboard] {
                
                var identifier = leaderboard.identifier
                
                self.allLeaderboards[identifier] = leaderboard
                
            }
        }
    }
    
    func submitScore() {
        
        var scoreReporter = GKScore(leaderboardIdentifier: "total_points")
        scoreReporter.value = Int64(score)
        scoreReporter.context = 0
        
        GKScore.reportScores([scoreReporter], withCompletionHandler: { (error) -> Void in
            println("scores uploaded")
        })
        
        if currentLevel == 5 && score >= level.targetScore  {
            var gameComplete = GKAchievement(identifier: "game_complete")
            gameComplete.percentComplete = 100.0
            gameComplete.showsCompletionBanner = true
            GKAchievement.reportAchievements([gameComplete], withCompletionHandler: { (error) -> Void in
                
                println("achievement sent")
            })
        }
        if currentLevel == 5 && score >= level.targetScore && noElfinWay == true  {
            var gameComplete = GKAchievement(identifier: "game_complete_elfin")
            gameComplete.percentComplete = 100.0
            gameComplete.showsCompletionBanner = true
            GKAchievement.reportAchievements([gameComplete], withCompletionHandler: { (error) -> Void in
                
                println("achievement sent")
            })
        }
    }
    
    
    
}