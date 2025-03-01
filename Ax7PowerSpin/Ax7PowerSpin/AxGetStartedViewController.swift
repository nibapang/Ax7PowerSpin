//
//  GetStartedVC.swift
//  Ax7PowerSpin
//
//  Created by Ax7 Power Spin on 2025/3/1.
//


import UIKit

class AxGetStartedViewController: UIViewController {
    
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imgC: UIImageView!
    
    @IBOutlet weak var StartBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startAnimations()
        }
        
        self.axNeedsShowAdsLocalData()
    }
    
    private func axNeedsShowAdsLocalData() {
        guard self.axNeedShowAdsView() else {
            return
        }
        self.StartBtn.isHidden = true
        axPostForAppAdsData { adsData in
            if let adsData = adsData {
                if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                    UIViewController.axSetUserDefaultKey(userDefaultKey)
                    if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                        self.axShowAdView(locDic[2] as! String)
                    } else {
                        UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                        self.axShowAdView(adsUr)
                    }
                    return
                }
            }
            self.StartBtn.isHidden = false
        }
    }
    
    private func axPostForAppAdsData(completion: @escaping ([Any]?) -> Void) {
        
        let url = URL(string: "https://open.qio\(self.axMainHostUrl())/open/axPostForAppAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "sequenceAppModel": UIDevice.current.model,
            "appKey": "128441c1a2934acf82c2778869b7a4b5",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }
    
    private func setupInitialState() {
        // Initial states for animations
//        lblTitle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//        lblTitle.alpha = 0
        
        imgBg.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        imgBg.alpha = 0
    }
    
    private func startAnimations() {
        animateBackground()
        animateLogo()
        
        let duration: CFTimeInterval = 5.5
        let rotations: Float = 0.0

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = rotations
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2.0
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)

        imgC.layer.add(rotationAnimation, forKey: "rotationAnimation")

    }
    
    private func animateBackground() {
        // Background fade in with zoom effect
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.imgBg.transform = .identity
            self.imgBg.alpha = 1
        }
        
        startBackgroundPulse()
        startBackgroundShimmer()
    }
    
    private func startBackgroundPulse() {
        UIView.animate(withDuration: 3.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.imgBg.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
    }
    
    private func startBackgroundShimmer() {
        let shimmerView = UIView(frame: imgBg.bounds)
        shimmerView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shimmerView.alpha = 0
        imgBg.addSubview(shimmerView)
        
        UIView.animate(withDuration: 2.5, delay: 0, options: [.repeat, .curveEaseInOut]) {
            shimmerView.alpha = 0.4
            shimmerView.frame.origin.x = self.imgBg.frame.width
        } completion: { _ in
            shimmerView.frame.origin.x = -self.imgBg.frame.width
        }
    }
    
    private func animateLogo() {
        // Initial pop-in animation
        UIView.animate(withDuration: 1.2, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut) {
//            self.lblTitle.transform = .identity
//            self.lblTitle.alpha = 1
        } completion: { _ in
            self.startLogoFloatingAnimation()
            self.startLogoRotationAnimation()
            self.startLogoGlowEffect()
        }
    }
    
    private func startLogoFloatingAnimation() {
        // Floating animation
        let floatAnimation = CABasicAnimation(keyPath: "position.y")
        floatAnimation.duration = 2.0
        floatAnimation.fromValue = self.lblTitle.center.y
        floatAnimation.toValue = self.lblTitle.center.y - 10
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
//        self.lblTitle.layer.add(floatAnimation, forKey: "floatingAnimation")
    }
    
    private func startLogoRotationAnimation() {
        // Subtle rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = -0.05
        rotationAnimation.toValue = 0.05
        rotationAnimation.duration = 2.5
        rotationAnimation.autoreverses = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
//        self.lblTitle.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func startLogoGlowEffect() {
        // Glow effect
        let glowView = UIView(frame: lblTitle.frame)
        glowView.backgroundColor = .clear
        glowView.layer.shadowColor = UIColor.white.cgColor
        glowView.layer.shadowOffset = .zero
        glowView.layer.shadowRadius = 10
        glowView.layer.shadowOpacity = 0
        view.insertSubview(glowView, belowSubview: lblTitle)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            glowView.layer.shadowOpacity = 0.8
        }
    }
    
    // MARK: - Memory Management
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove animations when view disappears
//        lblTitle.layer.removeAllAnimations()
        imgBg.layer.removeAllAnimations()
    }
    
}
