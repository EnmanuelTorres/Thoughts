//
//  PostPreviewTableViewCell.swift
//  Thoughts
//
//  Created by ENMANUEL TORRES on 9/03/23.
//

import UIKit

class PostPreviewTableViewCellViewModel {
    let title : String
    let imageUrl : URL?
    var imageData : Data?
    
    init(title: String, imageUrl: URL?, imageData: Data? = nil) {
        self.title = title
        self.imageUrl = imageUrl
        self.imageData = imageData
    }
}

class PostPreviewTableViewCell: UITableViewCell {

    static let indertifier = "PostPreviewTableViewCell"
    
    private let postImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let postTitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(postImageView)
        contentView.addSubview(postTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImageView.frame = CGRect(x: separatorInset.left,
                                     y: 5,
                                     width: contentView.height - 10,
                                     height: contentView.height - 10)
        
        postTitleLabel.frame = CGRect(x: postImageView.right + 5,
                                      y: 5,
                                      width: contentView.width - 5 - separatorInset.left - postImageView.width,
                                      height: contentView.height - 10)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        postTitleLabel.text = nil
    }

    func congifure(with viewModel: PostPreviewTableViewCellViewModel){
        postTitleLabel.text = viewModel.title
        
        
        if let data = viewModel.imageData {
            postImageView.image = UIImage(data: data)
        }
        
        else if let url = viewModel.imageUrl {
            // Fetch image & cache
            
            let task = URLSession.shared.dataTask(with: url) { [weak self]data, _, _ in
                guard let data  = data else {
                    print("pase por aqui 2")
                    return
                }
                viewModel.imageData = data
                print("pase por aqui 1")
                
                DispatchQueue.main.async {
                    self?.postImageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
