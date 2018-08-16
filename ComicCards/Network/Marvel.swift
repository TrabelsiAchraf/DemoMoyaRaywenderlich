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

import Foundation
import Moya

public enum Marvel {
  // 1
  static private let publicKey = "bd04343966bf7605daecb091a21436c5"
  static private let privateKey = "95922896181c114499cbe3d8275f8eefb686d909"
  
  // 2
  case comics
}

extension Marvel: TargetType {
  // 1 Every target (e.g., a service) requires a base URL. Moya will use this to eventually build the correct Endpoint object.
  public var baseURL: URL {
    return URL(string: "https://gateway.marvel.com/v1/public")!
  }
  
  // 2 For every case of your target, you need to define the exact path you’ll want to hit, relative to the base URL. Since the comic’s API is at https://gateway.marvel.com/v1/public/comics, the value here is simply /comics.
  public var path: String {
    switch self {
    case .comics: return "/comics"
    }
  }
  
  // 3 You need to provide the correct HTTP method for every case of your target. Here, .get is what you want.
  public var method: Moya.Method {
    switch self {
    case .comics: return .get
    }
  }
  
  // 4 is used to provide a mocked/stubbed version of your API for testing. In your case, you might want to return a fake response with just one or two comics. When creating unit tests, Moya can return this “fake” response to you instead of reaching out to the network. As you won’t be doing unit tests for this tutorial, you return an empty Data object
  public var sampleData: Data {
    return Data()
  }
  
  // 5 is probably the most important property of the bunch. You’re expected to return a Task enumeration case for every endpoint you want to use. There are many options for tasks you could use, e.g., plain request, data request, parameters request, upload request and many more.
  public var task: Task {
    let ts = "\(Date().timeIntervalSince1970)"
    // 1 You create the required hash, as mentioned earlier, by concatenating your random timestamp, the private key and the public key, then hashing the entire string as MD5. You’re using an md5 helper property found in Helpers/String+MD5.swift.
    let hash = (ts + Marvel.privateKey + Marvel.publicKey).md5
    // 2 The authParams dictionary contains the required authorization parameters: apikey, ts and hash, which contain the public key, timestamp and hash, respectively.
    let authParams = ["apikey": Marvel.publicKey, "ts": ts, "hash": hash]
    
    switch self {
    case .comics:
      // 3 Instead of the .requestPlain task you had earlier, you switch to using a .requestParameters task type, which handles HTTP requests with parameters
      return .requestParameters(
        parameters: [
          "format": "comic",
          "formatType": "comic",
          "orderBy": "-onsaleDate",
          "dateDescriptor": "lastWeek",
          "limit": 50] + authParams,
        encoding: URLEncoding.default)
    }
  }
  
  // 6 is where you return the appropriate HTTP headers for every endpoint of your target. Since all the Marvel API endpoints return a JSON response, you can safely use a Content-Type: application/json header for all endpoints.
  public var headers: [String: String]? {
    return ["Content-Type": "application/json"]
  }
  
  // 7 is used to provide your definition of a successful API request. There are many options available and, in your case, you’ll simply use .successCodes which means a request will be deemed successful if its HTTP code is between 200 and 299
  public var validationType: ValidationType {
    return .successCodes
  }
}
