//
//  HomeViewViewModal.swift
//  twitter
//
//  Created by Denis Lebedinsky on 06.04.23.
//

import Foundation
import Combine
import FirebaseAuth

final class HomeViewViewModel: ObservableObject {
    @Published var user: TwitterUser?
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    
    private var subscribtion: Set<AnyCancellable> = []
    
    func retreviewUser(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retrieve: id)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.user = user
                self?.fetchTweets()
            })
            .sink {[weak self] complition in
                if case .failure(let error) = complition {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscribtion)
    }
    
    func fetchTweets(){
        guard let userID = user?.id else { return }
        DatabaseManager.shared.collectionTweets(retrieveTweets: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] retrieveTweets in
                self?.tweets = retrieveTweets
            }
            .store(in: &subscribtion)

    }
}
