//
//  StorageManager.swift
//  twitter
//
//  Created by Denis Lebedinsky on 03.05.23.
//

import Foundation
import Combine
import FirebaseStorageCombineSwift
import FirebaseStorage

enum FirestorageError: Error {
    case invalidImageId
}

class StorageManager {
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func getDownloadURL(for id: String?) -> AnyPublisher<URL, Error> {
        guard let id = id else {
            return Fail(error: FirestorageError.invalidImageId)
                .eraseToAnyPublisher()
            
        }
    
        return storage.reference(withPath: id)
            .downloadURL()
            .eraseToAnyPublisher()
    }
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error> {
        return storage
            .reference()
            .child("images/\(randomID).jpg")
            .putData(image, metadata: metaData)
            .eraseToAnyPublisher()
    }
}
