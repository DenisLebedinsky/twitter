//
//  RegisterViewModel.swift
//  twitter
//
//  Created by Denis Lebedinsky on 02.04.23.
//

import Foundation
import Firebase
import Combine

final class AuthinticationViewViewModel: ObservableObject {
    @Published var email: String?
    @Published var password: String?
    @Published var isAuthenticationFormValid: Bool = false
    @Published var user: User?
    @Published var error: String?
    
    private var subscribtions: Set<AnyCancellable> = []
    
    func validateAuthenticationForm() {
        guard let email = email, let password = password else{
            isAuthenticationFormValid = false
            return
        }
        
        isAuthenticationFormValid = isValidEmail(email) && password.count >= 8
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func createUser(){
        guard let email = email, let password = password else{
            return
        }
        AuthManager.shared.registerUser(with: email, password: password)
            .handleEvents(receiveOutput: { [weak self] user in
                self?.user = user
            })
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.createRcord(for: user)
            }
            .store(in: &subscribtions)
    }
    
    func createRcord(for user: User){
        DatabaseManager.shared.collectionUsers(add: user)
            .sink { [weak self] complition in
                if case .failure(let error) = complition{
                    self?.error = error.localizedDescription
                }
            } receiveValue: { state in
                print("adding user record to database: \(state)")
            }
            .store(in: &subscribtions)

    }
    
    func loginUser(){
        guard let email = email, let password = password else{
            return
        }
        AuthManager.shared.loginUser(with: email, password: password)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscribtions)
    }
}
