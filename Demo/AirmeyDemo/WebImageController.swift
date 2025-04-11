//
//  WebImageController.swift
//  Example
//
//  Created by supertext on 6/16/21.
//

import UIKit
import Airmey
class WebImageController: UIViewController {
    let tableView = UITableView()
    var urls:[String] = []
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        tableView.am.edge.equal(to: 0)
        tableView.register(Cell.self)
        tableView.dataSource = self
        tableView.delegate = self
        print(AMImageCache.shared.diskUseage)
        self.urls = [
            "https://gcdn.channelthree.tv/20210206/7/0/4/b/3/704b3a55cdee408093f1c9446910dfd2.jpg",
            "https://gcdn.channelthree.tv/20201201/3/d/b/c/b/3dbcb33529fa451d9e2272d18e39aa5f.jpg",
            "https://gcdn.channelthree.tv/20201201/2/1/4/d/a/214dabf4f0c249f8a2c111e01526eb7e.jpg",
            "https://gcdn.channelthree.tv/20201201/7/4/d/4/b/74d4b8f0cca649f589d6ca595512d7f0.jpg",
            "https://gcdn.channelthree.tv/20201201/1/0/9/1/6/1091663def194270ae637691310941c5.jpg",
            "https://gcdn.channelthree.tv/20201201/b/d/e/e/4/bdee415d4294485a851c963240efc0b8.jpg",
            "https://gcdn.channelthree.tv/20201201/3/9/6/8/c/3968c46126c04cc088aeb43ff4dfd7fb.jpg",
            "https://gcdn.channelthree.tv/20201201/3/7/7/1/8/37718a817d9f43dcba26983cd9b7509b.jpg",
            "https://gcdn.channelthree.tv/20201201/6/8/c/c/b/68ccb2b68fa4411b8fe3f01a65cbc685.jpg"
        ]
        self.tableView.reloadData()
    }
}
extension WebImageController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urls.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(Cell.self, for: indexPath)
        cell.setURL(self.urls[indexPath.row])
        return cell
    }
}
extension WebImageController{
    class Cell:UITableViewCell,AMReusableCell{
        let coverView:UIImageView = .init()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.contentView.addSubview(coverView)
            coverView.am.edge.equal(to: 0)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func setURL(_ url:String){
            self.coverView.setImage(with: url)
        }
    }
}
