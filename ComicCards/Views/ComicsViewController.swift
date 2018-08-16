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
import UIKit
import Moya

class ComicsViewController: UIViewController {
    // MARK: - View State
    private var state: State = .loading {
        didSet {
            switch state {
            case .ready:
                viewMessage.isHidden = true
                tblComics.isHidden = false
                tblComics.reloadData()
            case .loading:
                tblComics.isHidden = true
                viewMessage.isHidden = false
                lblMessage.text = "Getting comics ..."
                imgMeessage.image = #imageLiteral(resourceName: "Loading")
            case .error:
                tblComics.isHidden = true
                viewMessage.isHidden = false
                lblMessage.text = """
                Something went wrong!
                Try again later.
                """
                imgMeessage.image = #imageLiteral(resourceName: "Error")
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak private var tblComics: UITableView!
    @IBOutlet weak private var viewMessage: UIView!
    @IBOutlet weak private var lblMessage: UILabel!
    @IBOutlet weak private var imgMeessage: UIImageView!
    
    // As mentioned earlier, the main class you’ll use to interact with your Moya targets is MoyaProvider, so you start by creating an instance of MoyaProvider that uses your new Marvel target.
    let provider = MoyaProvider<Marvel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1 First, you set the view’s state to .loading.
        state = .loading
        // 2 Use the provider to perform a request on the .comics endpoint. Notice that this is entirely type-safe, since .comics is an enum case
        provider.request(.comics) { [weak self] result in
            guard case self = self else { return }
            
            // 3 The closure provides a result which can be either .success(Moya.Response) or .failure(Error).
            switch result {
            case .success(let response):
                do {
                    // 4 If the request succeeds, you use Moya’s mapJSON method to map the successful response to a JSON object and then print it to the console. If the conversion throws an exception, you change the view’s state to .error.
                    // print(try response.mapJSON())
                    // Instead of mapping the object to a raw JSON response, you use a mapper that takes the MarvelResponse generic Decodable with a Comic struct. This will take care of parsing the two levels of nesting as well, which lets you access the array of comics by accessing data.results.
                    self?.state = .ready(try response.map(MarvelResponse<Comic>.self).data.results)
                } catch {
                    self?.state = .error
                }
            case .failure:
                // 5 If the returned result is a .failure, you set the view’s state to .error as well
                self?.state = .error
            }
        }
    }
}

extension ComicsViewController {
    enum State {
        case loading
        case ready([Comic])
        case error
    }
}

// MARK: - UITableView Delegate & Data Source
extension ComicsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ComicCell.reuseIdentifier, for: indexPath) as? ComicCell ?? ComicCell()
        
        guard case .ready(let items) = state else { return cell }
        
        cell.configureWith(items[indexPath.item])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case .ready(let items) = state else { return 0 }
        
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard case .ready(let items) = state else { return }
        
        let comicVC = CardViewController.instantiate(comic: items[indexPath.item])
        navigationController?.pushViewController(comicVC, animated: true)
    }
}

