//
//  TweetComposeViewViewModel.swift
//  twitter
//
//  Created by Denis Lebedinsky on 09.05.23.
//

import Foundation
import Combine
import FirebaseAuth

final class TweetComposeViewViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var isValidToTweet: Bool = false
    @Published var error: String = ""
    @Published var tweetContent: String = ""
    @Published var shouldDismissComposer: Bool = false
    
    private var user: TwitterUser?
    
    func getUserData(){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: userID)
            .sink { [weak self] compliton in
                if case .failure(let error) = compliton {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] twitterUser in
                self?.user = twitterUser
            }
            .store(in: &subscriptions)
    }
    
    func validateToTweet(){
        isValidToTweet = !tweetContent.isEmpty
    }
    
    func dispatchTweet(){
        guard let user = user else { return }
        let tweet = Tweet(author: user, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, parentReferences: nil)
        DatabaseManager.shared.collectionsTweets(dispatch: tweet)
            .sink {[weak self] compliton in
                if case .failure(let error) = compliton {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] state in
                self?.shouldDismissComposer = state
            }
            .store(in: &subscriptions)

    }
}
