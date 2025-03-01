//
//  SlotGameVC.swift
//  Ax7PowerSpin
//
//  Created by jin fu on 2025/3/1.
//


import UIKit
import AVFAudio

class AxPowerSlotGameVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var viewGame: UIView!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var buttonSpin: UIButton!
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    // MARK: - Properties
    private var score: Int = 1000 {
        didSet {
            labelScore.text = "Score: \(score)"
        }
    }
    
    private var level: Int = 1 {
        didSet {
            labelLevel.text = "Level: \(level)"
        }
    }
    
    private let symbols = [
        UIImage(named: "cherry"),
        UIImage(named: "lemon"),
        UIImage(named: "grape"),
        UIImage(named: "watermelon"),
        UIImage(named: "bell"),
        UIImage(named: "star"),
        UIImage(named: "seven")
    ].compactMap { $0 } // Ensure all images are valid
    
    private var reels: [UIImageView] = []
    private var audioPlayer: AVAudioPlayer?
    
    // Floating label for result display
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.alpha = 0 // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        loadSound()
        setupResultLabel()
    }
    
    // MARK: - Setup
    private func setupGame() {
        // Configure UI
        viewGame.layer.cornerRadius = 20
        viewGame.layer.borderWidth = 3
        viewGame.layer.borderColor = UIColor.systemYellow.cgColor
        
        buttonSpin.layer.cornerRadius = 15
        buttonSpin.setTitle("Spin", for: .normal)
        buttonSpin.backgroundColor = .systemYellow
        buttonSpin.setTitleColor(.black, for: .normal)
        buttonSpin.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        labelScore.font = UIFont.boldSystemFont(ofSize: 18)
        labelLevel.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Initialize reels
        createReels()
        
        // Set initial score and level
        score = 1000
        level = 1
    }
    
    private func createReels() {
        let reelWidth = viewGame.bounds.width / 3
        let reelHeight = viewGame.bounds.height
        
        for i in 0..<3 {
            let reel = UIImageView(frame: CGRect(x: CGFloat(i) * reelWidth, y: 0, width: reelWidth, height: reelHeight))
            reel.contentMode = .scaleAspectFit
            reel.image = symbols.randomElement()
            viewGame.addSubview(reel)
            reels.append(reel)
        }
    }
    
    // MARK: - Spin Animation
    @IBAction func spinButtonTapped(_ sender: UIButton) {
        buttonSpin.isEnabled = false
        playSound()
        spinReels()
    }
    
    private func spinReels() {
        for (index, reel) in reels.enumerated() {
            // Rapidly change symbols during spin
            animateRapidSymbolChanges(for: reel, delay: Double(index) * 0.2) {
                // Set final symbol after animation
                reel.image = self.symbols.randomElement()
                
                // Check for win after all reels have stopped
                if index == self.reels.count - 1 {
                    self.checkForWin()
                    self.buttonSpin.isEnabled = true
                }
            }
        }
    }
    
    private func animateRapidSymbolChanges(for reel: UIImageView, delay: Double, completion: @escaping () -> Void) {
        let animationDuration = 2.0 // Total duration of the spin
        let symbolChangeInterval = 0.1 // Interval between symbol changes
        
        // Start rapid symbol changes
        var elapsedTime = 0.0
        Timer.scheduledTimer(withTimeInterval: symbolChangeInterval, repeats: true) { timer in
            elapsedTime += symbolChangeInterval
            reel.image = self.symbols.randomElement()
            
            // Stop the timer and call completion after the total duration
            if elapsedTime >= animationDuration {
                timer.invalidate()
                completion()
            }
        }
        
        // Add a bounce effect at the end
        UIView.animate(withDuration: 0.3, delay: animationDuration, options: .curveEaseInOut, animations: {
            reel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                reel.transform = CGAffineTransform.identity
            })
        })
    }
    
    // MARK: - Game Logic
    private func checkForWin() {
        let reel1 = reels[0].image!
        let reel2 = reels[1].image!
        let reel3 = reels[2].image!
        
        if reel1 == reel2 && reel2 == reel3 {
            // All reels match
            score += 100 * level
            level += 1
            showResult(message: "Jackpot! You won 100 points!")
        } else if reel1 == reel2 || reel2 == reel3 || reel1 == reel3 {
            // Two reels match
            score += 50 * level
            showResult(message: "Two matches! You won 50 points!")
        } else {
            // No matches
            score -= 10
            showResult(message: "No matches. Try again!")
        }
    }
    
    // MARK: - Floating Label Effect
    private func setupResultLabel() {
        view.addSubview(resultLabel)
        
        NSLayoutConstraint.activate([
            resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resultLabel.bottomAnchor.constraint(equalTo: viewGame.topAnchor, constant: -16),
            resultLabel.widthAnchor.constraint(equalToConstant: 360),
            resultLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func showResult(message: String) {
        resultLabel.text = message
        
        // Animate the label in
        UIView.animate(withDuration: 0.5, animations: {
            self.resultLabel.alpha = 1
        }, completion: { _ in
            // Animate the label out after a delay
            UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                self.resultLabel.alpha = 0
            }, completion: nil)
        })
    }
    
    // MARK: - Sound Effects
    private func loadSound() {
        if let soundURL = Bundle.main.url(forResource: "spin", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading sound: \(error)")
            }
        }
    }
    
    private func playSound() {
        audioPlayer?.play()
    }
}
