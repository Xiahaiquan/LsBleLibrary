//
//  LSTestViewController.swift
//  LieshengAudio
//
//  Created by Hunter on 2020/7/27.
//  Copyright © 2020 liesheng. All rights reserved.
//

import UIKit
import SnapKit

class TestViewController: UIViewController {
    
    fileprivate  let displayTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 10)
        textView.isEditable = false
        return textView
    }()
    
    let viewModel = LSItemFuncTestViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(self.displayTextView)
        self.displayTextView.snp.makeConstraints { (maker) in
            maker.top.equalTo(view.snp.top)
            maker.left.right.equalTo(view)
            maker.height.equalTo(SCREEN_HEIGHT/4)
        }
        
        let stressView = LSItemFuncTestView.init(frame: .init(x: 0, y: (SCREEN_HEIGHT/4 ) + 2, width: view.frame.width, height: ((view.frame.height * 3) / 4) - 2))
        stressView.delegate = self
        view.addSubview(stressView)
        
    }
    deinit {
        print("TestViewController.deinit")
    }

    func changeTextViewDisplay(Content:String) {
        
        DispatchQueue.main.async {
            self.displayTextView.text = String(self.displayTextView.text.suffix(800)).appending(Content) + "\n"
            self.displayTextView.scrollRectToVisible(CGRect(x: 0, y: self.displayTextView.contentSize.height-15, width: self.displayTextView.contentSize.width, height: 10), animated: true)
            
        }
        
    }
    
}
// MARK: - TextView的代理
extension TestViewController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.scrollRectToVisible(CGRect(x: 0, y: self.displayTextView.contentSize.height * 10, width: self.displayTextView.contentSize.width, height: 10), animated: true)
    }
}
extension TestViewController: LSItemFuncTestViewProtocol {
    
    func clickCollectViewCell(value: String) {
        viewModel.handleAction(value: value)
    }
    
}
