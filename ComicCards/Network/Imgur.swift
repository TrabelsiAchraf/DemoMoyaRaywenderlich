/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Foundation
import Moya

public enum Imgur {
    // 1 Store your Imgur Client ID in clientId
    static private let clientId = "81ba3080b8435c6"
    
    // 2 Define the two endpoints that you’ll be using: upload, used to upload an image, and delete, which takes a hash for a previously uploaded image and deletes it from Imgu
    case upload(UIImage)
    case delete(String)
}

extension Imgur: TargetType {
    // 1 The base URL for the Imgur API
    public var baseURL: URL {
        return URL(string: "https://api.imgur.com/3")!
    }
    
    // 2 You return the appropriate endpoint path based on the case. /image for .upload, and /image/{deletehash} for .delete.
    public var path: String {
        switch self {
        case .upload: return "/image"
        case .delete(let deletehash): return "/image/\(deletehash)"
        }
    }
    
    // 3 The method differs based on the case as well: .post for .upload and .delete for .delete.
    public var method: Moya.Method {
        switch self {
        case .upload: return .post
        case .delete: return .delete
        }
    }
    
    // 4 Just like before, you return an empty Data struct for sampleData.
    public var sampleData: Data {
        return Data()
    }
    
    // 5 The task is where things get interesting. You return a different Task for every endpoint. The .delete case doesn’t require any parameters or content since it’s a simple DELETE request, but the .upload case needs some more work. To upload a file, you’ll use the .uploadMultipart task type, which takes an array of MultipartFormData structs. You then create an instance of MultipartFormData with the appropriate image data, field name, file name and image mime type.
    public var task: Task {
        switch self {
        case .upload(let image):
            // let imageData = image.jpegData(compressionQuality: 1.0)!
            let imageData = image.jpeg(.high)
            
            return .uploadMultipart([MultipartFormData(provider: .data(imageData!),
                                                       name: "image",
                                                       fileName: "card.jpg",
                                                       mimeType: "image/jpg")])
        case .delete:
            return .requestPlain
        }
    }
    
    // 6 Like the Marvel API, the headers property returns a Content-Type: application/json header, and an additional header. The Imgur API uses Header authorization, so you’ll need to provide your Client ID in the header of every request, in the form of Authorization: Client-ID (YOUR CLIENT ID).
    public var headers: [String: String]? {
        return [
            "Authorization": "Client-ID \(Imgur.clientId)",
            "Content-Type": "application/json"
        ]
    }
    
    // 7 The .validationType is the same as before — valid for any status codes between 200 and 299.
    public var validationType: ValidationType {
        return .successCodes
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}
