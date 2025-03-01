//
//  SlotGameTwoVC.swift
//  Ax7PowerSpin
//
//  Created by jin fu on 2025/3/1.
//


import UIKit

class AxSlotWaveGameVC: UIViewController {

    @IBOutlet weak var imgA1: UIImageView!
    @IBOutlet weak var imgA2: UIImageView!
    @IBOutlet weak var imgA3: UIImageView!
    @IBOutlet weak var imgA4: UIImageView!
    @IBOutlet weak var imgB1: UIImageView!
    @IBOutlet weak var imgB2: UIImageView!
    @IBOutlet weak var imgB3: UIImageView!
    @IBOutlet weak var imgB4: UIImageView!
    @IBOutlet weak var imgC1: UIImageView!
    @IBOutlet weak var imgC2: UIImageView!
    @IBOutlet weak var imgC3: UIImageView!
    @IBOutlet weak var imgC4: UIImageView!
    @IBOutlet weak var imgD1: UIImageView!
    @IBOutlet weak var imgD2: UIImageView!
    @IBOutlet weak var imgD3: UIImageView!
    @IBOutlet weak var imgD4: UIImageView!
    
    @IBOutlet weak var lblScore: UILabel!
    
    var arrIcons: [UIImage] = []
    
    // Add new properties
    private var isSpinning = false
    private var currentValues: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    private let spinDuration: TimeInterval = 0.8
    private let spinRotations: CGFloat = 2.0
    private var score: Int = 0 {
        didSet {
            lblScore.text = "Score: \(score)"
            animateScoreChange(oldValue: oldValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrIcons = splitImageIntoGrid(image: UIImage(named: "icons")!, rows: 4, columns: 8)
        setupInitialSlots()
        
        // Initialize score display
        score = 0
        lblScore.text = "Score: 0"
    }
    
    private func setupInitialSlots() {
        let allSlots = [imgA1, imgA2, imgA3, imgA4,
                       imgB1, imgB2, imgB3, imgB4,
                       imgC1, imgC2, imgC3, imgC4,
                       imgD1, imgD2, imgD3, imgD4]
        
        for slot in allSlots {
            slot?.layer.cornerRadius = 8
            slot?.clipsToBounds = true
            slot?.image = arrIcons.randomElement()
        }
    }
    
    @IBAction func spinButtonTapped(_ sender: Any) {
        guard !isSpinning else { return }
        isSpinning = true
        spinAllSlots()
    }
    
    private func spinAllSlots() {
        let allSlots = [
            [imgA1, imgA2, imgA3, imgA4],
            [imgB1, imgB2, imgB3, imgB4],
            [imgC1, imgC2, imgC3, imgC4],
            [imgD1, imgD2, imgD3, imgD4]
        ]
        
        for (rowIndex, row) in allSlots.enumerated() {
            for (colIndex, slot) in row.enumerated() {
                spinSlot(slot!, rowIndex: rowIndex, colIndex: colIndex, delay: Double(rowIndex) * 0.2)
            }
        }
        
        // Check for wins after all slots have stopped
        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration + 0.8) { [weak self] in
            self?.isSpinning = false
            self?.checkForWins()
        }
    }
    
    private func spinSlot(_ slot: UIImageView, rowIndex: Int, colIndex: Int, delay: TimeInterval) {
        // Create spinning animation
        UIView.animate(withDuration: spinDuration, delay: delay, options: .curveEaseInOut) {
            slot.transform = CGAffineTransform(rotationAngle: .pi * self.spinRotations)
            slot.alpha = 0.5
        } completion: { _ in
            // Reset transform and set new random image
            slot.transform = .identity
            slot.alpha = 1.0
            let randomIndex = Int.random(in: 0..<self.arrIcons.count)
            slot.image = self.arrIcons[randomIndex]
            self.currentValues[rowIndex][colIndex] = randomIndex
            
            // Add a bounce effect
            self.addBounceAnimation(to: slot)
        }
    }
    
    private func addBounceAnimation(to view: UIView) {
        let bounce = CASpringAnimation(keyPath: "transform.scale")
        bounce.fromValue = 0.8
        bounce.toValue = 1.0
        bounce.duration = 0.5
        bounce.damping = 8
        bounce.initialVelocity = 0.5
        view.layer.add(bounce, forKey: nil)
    }
    
    private func checkForWins() {
        // Check rows
        for (rowIndex, row) in currentValues.enumerated() {
            checkForMatches(in: row, rowIndex: rowIndex)
        }
        
        // Check columns
        for col in 0..<4 {
            let column = currentValues.map { $0[col] }
            checkForMatches(in: column, colIndex: col)
        }
    }
    
    private func checkForMatches(in line: [Int], rowIndex: Int? = nil, colIndex: Int? = nil) {
        var matches: [(value: Int, indices: [Int])] = []
        var currentValue = line[0]
        var currentIndices = [0]
        
        // Find consecutive matches
        for i in 1..<line.count {
            if line[i] == currentValue {
                currentIndices.append(i)
            } else {
                if currentIndices.count >= 2 {
                    matches.append((currentValue, currentIndices))
                }
                currentValue = line[i]
                currentIndices = [i]
            }
        }
        
        // Check last group
        if currentIndices.count >= 2 {
            matches.append((currentValue, currentIndices))
        }
        
        // Calculate score and highlight matches
        for match in matches {
            // Calculate score based on match length
            let matchScore = calculateScore(matchLength: match.indices.count)
            score += matchScore
            
            if let rowIndex = rowIndex {
                highlightWinningRowSegment(row: rowIndex, columns: match.indices)
            } else if let colIndex = colIndex {
                highlightWinningColumnSegment(col: colIndex, rows: match.indices)
            }
        }
    }
    
    private func calculateScore(matchLength: Int) -> Int {
        // Base score multiplied by match length
        let baseScore = 100
        let multiplier = pow(2.0, Double(matchLength - 2)) // Exponential scoring for longer matches
        return Int(Double(baseScore) * multiplier)
    }
    
    private func animateScoreChange(oldValue: Int) {
        // Create score change label
        let scoreChangeLabel = UILabel()
        scoreChangeLabel.textColor = .green
        scoreChangeLabel.font = UIFont.boldSystemFont(ofSize: 24)
        let scoreDifference = score - oldValue
        scoreChangeLabel.text = "+\(scoreDifference)"
        
        // Position it near the score label
        scoreChangeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreChangeLabel)
        
        NSLayoutConstraint.activate([
            scoreChangeLabel.centerXAnchor.constraint(equalTo: lblScore.centerXAnchor),
            scoreChangeLabel.bottomAnchor.constraint(equalTo: lblScore.topAnchor, constant: -10)
        ])
        
        // Animate the score change
        UIView.animate(withDuration: 1.0, animations: {
            scoreChangeLabel.transform = CGAffineTransform(translationX: 0, y: -50)
            scoreChangeLabel.alpha = 0
        }) { _ in
            scoreChangeLabel.removeFromSuperview()
        }
        
        // Animate the score label
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.4
        flash.autoreverses = true
        flash.repeatCount = 2
        lblScore.layer.add(flash, forKey: nil)
        
        // Add scale animation
        UIView.animate(withDuration: 0.2, animations: {
            self.lblScore.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.lblScore.transform = .identity
            }
        }
    }
    
    private func highlightWinningRowSegment(row: Int, columns: [Int]) {
        let allSlots = [
            [imgA1, imgA2, imgA3, imgA4],
            [imgB1, imgB2, imgB3, imgB4],
            [imgC1, imgC2, imgC3, imgC4],
            [imgD1, imgD2, imgD3, imgD4]
        ][row]
        
        let matchedSlots = columns.map { allSlots[$0] }
        for slot in matchedSlots {
            celebrateWinningSlot(slot!)
        }
    }
    
    private func highlightWinningColumnSegment(col: Int, rows: [Int]) {
        let allSlots = [
            [imgA1, imgB1, imgC1, imgD1],
            [imgA2, imgB2, imgC2, imgD2],
            [imgA3, imgB3, imgC3, imgD3],
            [imgA4, imgB4, imgC4, imgD4]
        ][col]
        
        let matchedSlots = rows.map { allSlots[$0] }
        for slot in matchedSlots {
            celebrateWinningSlot(slot!)
        }
    }
    
    private func celebrateWinningSlot(_ slot: UIImageView) {
        // Scale and glow animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.5
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = 3
        
        // Add glow effect
        slot.layer.shadowColor = UIColor.yellow.cgColor
        slot.layer.shadowOffset = .zero
        slot.layer.shadowRadius = 10
        slot.layer.shadowOpacity = 0
        
        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.duration = 0.5
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 1
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = 3
        
        // Add particle effect
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: slot.bounds.width/2, y: slot.bounds.height/2)
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 1, height: 1)
        
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "star")?.cgImage
        cell.birthRate = 10
        cell.lifetime = 1.5
        cell.velocity = 50
        cell.scale = 0.2
        cell.scaleRange = 0.1
        cell.emissionRange = .pi * 2
        cell.alphaSpeed = -0.5
        cell.color = UIColor.yellow.cgColor
        
        emitter.emitterCells = [cell]
        slot.layer.addSublayer(emitter)
        
        // Add animations
        slot.layer.add(scaleAnimation, forKey: "scale")
        slot.layer.add(glowAnimation, forKey: "glow")
        
        // Clean up after animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            slot.layer.removeAllAnimations()
            slot.layer.shadowOpacity = 0
            emitter.removeFromSuperlayer()
        }
    }
    
    func splitImageIntoGrid(image: UIImage, rows: Int, columns: Int) -> [UIImage] {
        
        guard let cgImage = image.cgImage else { return [] }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        let tileWidth = imageWidth / CGFloat(columns)
        let tileHeight = imageHeight / CGFloat(rows)
        
        var imagePieces: [UIImage] = []
        
        for row in 0..<rows {
            for col in 0..<columns {
                let x = CGFloat(col) * tileWidth
                let y = CGFloat(row) * tileHeight
                let rect = CGRect(x: x, y: y, width: tileWidth, height: tileHeight)
                
                if let croppedCgImage = cgImage.cropping(to: rect) {
                    let croppedImage = UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
                    imagePieces.append(croppedImage)
                }
            }
        }
        
        return imagePieces
    }
    
    // Add method to save high score
    private func saveHighScore() {
        let currentHighScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > currentHighScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            showHighScoreAlert()
        }
    }
    
    private func showHighScoreAlert() {
        let alert = UIAlertController(
            title: "New High Score!",
            message: "Congratulations! You've achieved a new high score of \(score)!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
        present(alert, animated: true)
    }
    
    // Optional: Add method to reset score
    @IBAction func resetScore(_ sender: Any) {
        score = 0
    }
}
