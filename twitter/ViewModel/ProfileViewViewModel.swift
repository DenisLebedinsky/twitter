//
//  ProfileViewViewModel.swift
//  twitter
//
//  Created by Denis Lebedinsky on 09.05.23.
//

import Foundation
import Combine
import FirebaseAuth

final class ProfileViewViewModel: ObservableObject {
    
    @Published var user: TwitterUser?
    @Published var error: String?
    
    private var subscribtion: Set<AnyCancellable> = []
    
    func retreviewUser(){
        guard let id = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: id)
            .sink {[weak self] complition in
                if case .failure(let error) = complition {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscribtion)
    }
    
    func getFormattedDate(with date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        return dateFormatter.string(from: date)
    }
}
