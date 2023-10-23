//
//  ViewController.swift
//  ios101-project6-tumblr
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var posts: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: "Georgia", size: 17.0) {
                navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
            }
        
        if let font = UIFont(name: "Georgia", size: 34.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: font]
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        tableView.dataSource = self
        fetchPosts()

    }
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Customize the navigation bar appearance
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Georgia", size: 17.0)!]
//        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Georgia", size: 34.0)!]
//        return true
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Customary to call the overridden method on `super` any time you override a method.
        super.viewWillAppear(animated)

        // get the index path for the selected row
        if let selectedIndexPath = tableView.indexPathForSelectedRow {

            // Deselect the currently selected row
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected post
        // Get Index Path for selected rows
        // `indexPathForSelectedRow` returns an optional `indexPath` , so we'll unwrap it with guard
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        // Get the selected post from the posts array using selected index path's row
        let selectedPost = posts[selectedIndexPath.row]
        
        // Get access to DetailViewController via segue's destination. (guard to unwrap the optional)
        guard let detailViewController = segue.destination as? DetailViewController else { return }
        
        detailViewController.post = selectedPost
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell

        let post = posts[indexPath.row]

        cell.summaryLabel.text = post.summary

        if let photo = post.photos.first {
            let url = photo.originalSize.url
            Nuke.loadImage(with: url, into: cell.postImageView)
        }

        return cell
    }

    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts
                    self?.posts = posts
                    self?.tableView.reloadData()

                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
