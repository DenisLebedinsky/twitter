//
//  TweetComposeViewController.swift
//  twitter
//
//  Created by Denis Lebedinsky on 09.05.23.
//

import UIKit
import Combine

class TweetComposeViewController: UIViewController {
    
    private var viewModal = TweetComposeViewViewModel()
    private var subscription: Set<AnyCancellable> = []
    
    private let tweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .tweeterBlueColor
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.tintColor = .white
        button.isEnabled = false
        return button
    }()
    
    private lazy var tweetContentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "What's happening?"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Tweet"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapToCancel))
        view.addSubview(tweetButton)
        view.addSubview(tweetContentTextView)
        
        tweetContentTextView.delegate = self
        
        configureConstraints()
        bindViews()
        
        tweetButton.addTarget(self, action: #selector(didTapTweet), for: .touchUpInside)
    }
    
    @objc private func didTapToCancel(){
        dismiss(animated: true)
    }
    
    @objc private func didTapTweet(){
        viewModal.dispatchTweet()
    }
    
    private func bindViews(){
        viewModal.$isValidToTweet.sink { [weak self] state in
            self?.tweetButton.isEnabled = state
        }.store(in: &subscription)
        
        viewModal.$shouldDismissComposer.sink {[weak self] state in
            if state {
                self?.dismiss(animated: true)
            }
        }
        .store(in: &subscription)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModal.getUserData()
    }
    
    private func configureConstraints() {
        let tweetButtonConstraints = [
            tweetButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            tweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tweetButton.widthAnchor.constraint(equalToConstant: 120),
            tweetButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        let tweetTextViewConstraints = [
            tweetContentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tweetContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tweetContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tweetContentTextView.bottomAnchor.constraint(equalTo: tweetButton.topAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(tweetButtonConstraints)
        NSLayoutConstraint.activate(tweetTextViewConstraints)
    }
}

extension TweetComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModal.tweetContent = textView.text
        viewModal.validateToTweet()
    }
}
