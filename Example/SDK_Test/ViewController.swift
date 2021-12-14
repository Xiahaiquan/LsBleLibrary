//
//  ViewController.swift
//  SDK_Test
//
//  Created by 夏海泉 on 2021/11/1.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    func changeTextViewDisplay(Content:String) {
        
        DispatchQueue.main.async {
            self.displayTextView.text = String(self.displayTextView.text.suffix(800)).appending(Content) + "\n"
            self.displayTextView.scrollRectToVisible(CGRect(x: 0, y: self.displayTextView.contentSize.height-15, width: self.displayTextView.contentSize.width, height: 10), animated: true)
            
        }
        
    }
    
}
// MARK: - TextView的代理
extension ViewController:UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.scrollRectToVisible(CGRect(x: 0, y: self.displayTextView.contentSize.height * 10, width: self.displayTextView.contentSize.width, height: 10), animated: true)
    }
}
extension ViewController: LSItemFuncTestViewProtocol {
    
    func clickCollectViewCell(value: String) {
        viewModel.handleAction(value: value)
    }
    
}
