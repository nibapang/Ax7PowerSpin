//
//  SceneGameVC.swift
//  Ax7PowerSpin
//
//  Created by Ax7 Power Spin on 2025/3/1.
//


import UIKit
import SceneKit

class AxTankFindSlotSceneGameVC: UIViewController, SCNSceneRendererDelegate {
    
    @IBOutlet weak var viewGame: SCNView!
    
    var sceneView: SCNView!
    var scene: SCNScene!
    
    var loaderNode: SCNNode!
    var selfieStick: SCNNode!
    var planeNode: SCNNode!
    
    var smokeEffect: SCNParticleSystem!
    
    var grassNodes: [SCNNode] = []{
        didSet{
            print(grassNodes.count)
        }
    }
    var taskLabel: UILabel!
    
    var moveTimer: Timer?
    var currentDirection: SCNVector3?
    
    var upButton: UIButton!
    var downButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setupScene()
            self.setupNodes()
            self.setupTaskUI()
            self.setupMovementButtons()
            self.setupRotateButton()
            self.addGrassObjects()
            self.addGrassPlane()
        }
        
        playSound(name: "loader", type: ".mp3", repeatCount: 0)
        setVolume(0.4)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopSound()
    }
    
    // MARK: - Scene Setup
    func setupScene() {
        sceneView = viewGame
        scene = SCNScene(named: "GameScene.scn")
        sceneView.scene = scene
        
        sceneView.delegate = self
        scene.physicsWorld.contactDelegate = self
    }
    
    // MARK: - Setup Rotate Button
    func setupRotateButton() {
        let buttonSize: CGFloat = 60
        let rotateButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 100, width: buttonSize, height: buttonSize))
        
        rotateButton.setTitle("🔄", for: .normal)
        rotateButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        rotateButton.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        rotateButton.layer.cornerRadius = buttonSize / 2
        rotateButton.addTarget(self, action: #selector(rotateSelfieStick), for: .touchUpInside)
        
        view.addSubview(rotateButton)
    }
    
    // MARK: - Rotate SelfieStick by 90 Degrees
    @objc func rotateSelfieStick() {
        let currentRotation = selfieStick.eulerAngles.y
        let newRotation = currentRotation - Float.pi / 2
        
        let rotateAction = SCNAction.rotateTo(x: CGFloat(selfieStick.eulerAngles.x),
                                              y: CGFloat(newRotation),
                                              z: CGFloat(selfieStick.eulerAngles.z),
                                              duration: 0.3,
                                              usesShortestUnitArc: true)
        
        selfieStick.runAction(rotateAction)
        
        print("✅ SelfieStick rotated to \(newRotation * (180 / .pi))°")
    }
    
    
    
    // MARK: - Add Grass Objects Using Existing Node
    func addGrassObjects() {
        guard let plane = planeNode.geometry as? SCNPlane else {
            print("❌ Plane node is missing!")
            return
        }

        // ✅ Find the existing "grass" node in the scene
        guard let originalGrassNode = scene.rootNode.childNode(withName: "grass", recursively: true) else {
            print("❌ Could not find 'grass' node in scene!")
            return
        }

        let planeWidth = plane.width
        let planeHeight = plane.height

        for i in 0..<20 {
            // ✅ Duplicate the existing grass node
            let grassNode = originalGrassNode.clone()
            
            // ✅ Generate a truly random position on the plane
            let randomX = Float.random(in: -Float(planeWidth) / 2...Float(planeWidth) / 2)
            let randomZ = Float.random(in: -Float(planeHeight) / 2...Float(planeHeight) / 2)

            grassNode.position = SCNVector3(randomX, 0.25, randomZ) // Slightly above the ground
            grassNode.eulerAngles = originalGrassNode.eulerAngles // Keep same orientation
            grassNode.name = "grass_\(i)" // ✅ Unique name to prevent conflicts

            // ✅ Make sure each grass node has a physics body
            grassNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            grassNode.physicsBody?.categoryBitMask = 2
            grassNode.physicsBody?.contactTestBitMask = 1

            scene.rootNode.addChildNode(grassNode) // ✅ Add to scene
            grassNodes.append(grassNode) // ✅ Track the grass node
            
            print("✅ Duplicated Grass at:", grassNode.position)
        }
        
        taskLabel.text = "Grass Left: \(grassNodes.count)"
    }
    
    func addGrassPlane() {
        guard let plane = planeNode.geometry as? SCNPlane,
              let originalGrassNode = scene.rootNode.childNode(withName: "g", recursively: true) else {
            print("❌ Plane node or grass node is missing!")
            return
        }

        let planeWidth = plane.width
        let planeHeight = plane.height
        
        // Create a dispatch group to manage the grass creation
        let group = DispatchGroup()
        
        // Create grass in batches for better performance
        DispatchQueue.global(qos: .userInitiated).async {
            // Total number of grass instances
            let totalGrass = 2000
            
            for _ in 0..<totalGrass {
                group.enter()
                
                DispatchQueue.main.async {
                    let grassPlaneNode = originalGrassNode.clone()
                    
                    // Random position
                    let randomX = Float.random(in: -Float(planeWidth) / 2...Float(planeWidth) / 2)
                    let randomZ = Float.random(in: -Float(planeHeight) / 2...Float(planeHeight) / 2)
                    
                    // Random scale for variety (0.8 to 1.2 of original size)
                    let randomScale = Float.random(in: 0.1...1.2)
                    
                    // Random rotation for natural look
                    let randomRotation = Float.random(in: 0...Float.pi * 2)
                    
                    grassPlaneNode.position = SCNVector3(randomX, 0.01, randomZ)
                    grassPlaneNode.scale = SCNVector3(randomScale, randomScale, randomScale)
                    grassPlaneNode.eulerAngles.y = randomRotation
                    grassPlaneNode.name = "grassPlane"
                    
                    // Add slight random color variation
                    if let material = grassPlaneNode.geometry?.firstMaterial {
                        let baseColor = material.diffuse.contents as? UIColor ?? .green
                        material.diffuse.contents = baseColor.withAlphaComponent(CGFloat.random(in: 0.8...1.0))
                    }
                    
                    self.scene.rootNode.addChildNode(grassPlaneNode)
                    group.leave()
                }
            }
        }
    }
    
    // MARK: - Nodes Setup
    func setupNodes() {
        loaderNode = scene.rootNode.childNode(withName: "loader", recursively: true)
        selfieStick = scene.rootNode.childNode(withName: "selfieStick", recursively: true)!
        planeNode = scene.rootNode.childNode(withName: "plane", recursively: true)!
        
        // Retrieve smoke node from loader
        if let smokeNode = loaderNode.childNode(withName: "smoke", recursively: true),
           let smoke = smokeNode.particleSystems?.first {
            smokeEffect = smoke
            smokeEffect.birthRate = 0  // Start with no smoke
        } else {
            print("❌ Smoke node not found in loader!")
        }
    }
    
    // MARK: - Task UI Setup
    func setupTaskUI() {
        taskLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 200, height: 30))
        taskLabel.text = "Grass Left: \(grassNodes.count)"
        taskLabel.textColor = .black
        taskLabel.font = UIFont(name: "Impact", size: 22)
        view.addSubview(taskLabel)
    }
    
    // MARK: - Setup Movement Buttons
    func setupMovementButtons() {
        let buttonSize: CGFloat = 60
        let bottomOffset: CGFloat = view.bounds.height - 200
        
        upButton = createButton(title: "⬆", frame: CGRect(x: view.bounds.width / 1.2 - buttonSize / 2, y: bottomOffset - 15, width: buttonSize, height: buttonSize), action: #selector(startMovingUp), stopAction: #selector(stopMoving))
        downButton = createButton(title: "⬇", frame: CGRect(x: view.bounds.width / 1.2 - buttonSize / 2, y: bottomOffset + buttonSize + 15, width: buttonSize, height: buttonSize), action: #selector(startMovingDown), stopAction: #selector(stopMoving))
        leftButton = createButton(title: "⬅", frame: CGRect(x: view.bounds.width / 1.2 - buttonSize - 15, y: bottomOffset + buttonSize / 2, width: buttonSize, height: buttonSize), action: #selector(startMovingLeft), stopAction: #selector(stopMoving))
        rightButton = createButton(title: "➡", frame: CGRect(x: view.bounds.width / 1.2 + 15, y: bottomOffset + buttonSize / 2, width: buttonSize, height: buttonSize), action: #selector(startMovingRight), stopAction: #selector(stopMoving))
    }
    
    func createButton(title: String, frame: CGRect, action: Selector, stopAction: Selector) -> UIButton {
        let button = UIButton(frame: frame)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = .gray.withAlphaComponent(0.7)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: action, for: .touchDown)  // Start when pressed
        button.addTarget(self, action: stopAction, for: [.touchUpInside, .touchUpOutside])  // Stop when released
        view.addSubview(button)
        return button
    }
    
    // MARK: - Start Continuous Movement
    @objc func startMovingUp() {
        startMoving(direction: SCNVector3(0, 0, -0.2))
    }
    
    @objc func startMovingDown() {
        startMoving(direction: SCNVector3(0, 0, 0.2))
    }
    
    @objc func startMovingLeft() {
        startMoving(direction: SCNVector3(-0.2, 0, 0))
    }
    
    @objc func startMovingRight() {
        startMoving(direction: SCNVector3(0.2, 0, 0))
    }
    
    func startMoving(direction: SCNVector3) {

        currentDirection = direction
        
        // Enable smoke
        smokeEffect?.birthRate = 500
        setVolume(1.0)
        smokeEffect.particleVelocity *= 2
        
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let newPosition = SCNVector3(
                self.loaderNode.position.x + direction.x,
                self.loaderNode.position.y + direction.y,
                self.loaderNode.position.z + direction.z
            )
            self.loaderNode.runAction(SCNAction.move(to: newPosition, duration: 0.1))
            
            let angle = atan2(direction.z, direction.x)
            let rotation = SCNAction.rotateTo(x: 0, y: -CGFloat(angle - .pi/2), z: 0, duration: 0.1, usesShortestUnitArc: true)
            self.loaderNode.runAction(rotation)
            
            self.selfieStick.position = newPosition
        }
        
    }
    
    // MARK: - Stop Movement When Button is Released
    @objc func stopMoving() {
        moveTimer?.invalidate()
        moveTimer = nil
        currentDirection = nil
        
        // Disable smoke
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.smokeEffect?.birthRate = 50
            self.setVolume(0.4)
            self.smokeEffect.particleVelocity *= 1/2
        }
    }
    
    // MARK: - Task Completion
    private func updateTaskProgress() {
        taskLabel.text = "Poker Box Left: \(grassNodes.count)"
        
        if grassNodes.isEmpty {
            showTaskCompleteAlert()
        }
    }
    
    private func showTaskCompleteAlert() {
        stopMoving()
        let alert = UIAlertController(title: "Task Complete!", message: "You've cleared all the boxes!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}

// MARK: - Collision Detection
extension AxTankFindSlotSceneGameVC: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        
        if contact.nodeA.name == "loader" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.name == "plane" { return }
        
        if contactNode.isHidden { return }
        
        contactNode.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            contactNode.opacity = 0.5
            contactNode.physicsBody?.categoryBitMask = 0
            
            self.grassNodes.removeAll { $0 == contactNode }
            
            self.updateTaskProgress()
        }
    }
    
}
