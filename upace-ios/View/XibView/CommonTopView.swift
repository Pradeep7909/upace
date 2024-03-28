//
//  CommonTopView.swift
//  upace-ios
//
//  Created by Qualwebs on 06/03/24.
//

import UIKit



@IBDesignable
class CommonTopView: UIView {
   
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rightImageHeightConstraint: NSLayoutConstraint!
    
    var leftButton: (() -> Void)?
    var rightButton: (() -> Void)?
    
    
    //MARK: Button Actions
    @IBAction func backButtonAction(_ sender: UIButton) {
        leftButton?()
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        rightButton?()
    }
    
    
    @IBOutlet weak var topBarWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    //MARK: Inspectable
    @IBInspectable var titleText: String = "Title" {
        didSet {
            title.text = titleText
        }
    }
    
    @IBInspectable var leftImage: UIImage = UIImage(named: "backArrow")!  {
        didSet {
            leftImageView.image = leftImage
        }
    }
    
    @IBInspectable var rightImage: UIImage = UIImage(named: "uplogo")!  {
        didSet {
            rightImageView.image = rightImage
        }
    }
    
    @IBInspectable var rightImageHeight : CGFloat = 30 {
        didSet{
            rightImageHeightConstraint.constant = rightImageHeight
        }
    }
    
    @IBInspectable var topBarViewWidth : CGFloat = 0 {
        didSet{
            topBarWidthConstraint.constant = topBarViewWidth
        }
    }
    
    //MARK: Initial setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
       
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CommonTopView", bundle: bundle)
        if let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView {
            addSubview(contentView)
            contentView.frame = bounds
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            progressView.alpha = 1
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    
    
    //MARK: Progress view control
    private func setProgressZero(){
        progressView.setProgress(0, animated: false)
    }
    
    func setProgress(_ progress: Float, duration: TimeInterval = 2.0) {
        self.progressView.layer.removeAllAnimations()
        setProgressZero()
        UIView.animate(withDuration: duration) {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    func setProgressToZero() {
        self.progressView.layer.removeAllAnimations()
        DispatchQueue.main.asyncAfter(deadline: .now() +  0.2){
            self.progressView.setProgress(0, animated: false)
        }
    }
}
