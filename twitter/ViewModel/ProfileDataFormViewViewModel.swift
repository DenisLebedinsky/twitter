//
//  ProfileDataFormViewModel.swift
//  twitter
//
//  Created by Denis Lebedinsky on 06.04.23.
//

import Foundation
import Combine
import UIKit
import FirebaseStorage

final class ProfileDataFormViewViewModel: ObservableObject {
    
    public var subscription: Set<AnyCancellable> = []
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarpath: String?
    @Published var imageData: UIImage?
    @Published var isFormValid: Bool = false
    @Published var error: String = ""
    
    func validateUserProfileForm(){
        guard let displayName = displayName, displayName.count > 2 else {
            isFormValid = false
            return
        }
        guard let username = username, username.count > 2 else {
            isFormValid = false
            return
        }
        guard let bio = bio, bio.count > 2 else {
            isFormValid = false
            return
        }
        guard imageData != nil else {
            isFormValid = false
            return
        }
        
        isFormValid = true
    }
    
    func uploadAvatar() {
        
        let randomID = UUID().uuidString
        
        guard let imageData = imageData?.jpegData(compressionQuality: 0.5) else {return}
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        StorageManager.shared.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
            .flatMap({ metaData in
                StorageManager.shared.getDownloadURL(for: metaData.path)
            })
            .sink { [weak self] completion in
             
                switch completion {
                case .failure(let error):
                    self?.error = error.localizedDescription
                    
                case .finished:
                    self?.updateUserData()
                }
            } receiveValue: { [weak self] url in
                self?.avatarpath = url.absoluteString
            }
            .store(in: &subscription)
    }
    
    private  func updateUserData(){
        guard let displayName,
              let username,
              let bio,
              let avatarpath else {return}
        
    }
}
