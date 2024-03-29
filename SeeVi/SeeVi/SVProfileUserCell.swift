//
//  SVProfileUserCell.swift
//  SeeVi
//
//  Created by Ty Daniels on 4/10/17.
//  Copyright © 2017 Ty Daniels. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Stevia

class SVProfileUserCell: UITableViewCell {
    
    //MARK: View assets
    var mainBackgroundView = UIView()
    var avatar = UIImageView(image: UIImage(named: "user-placeholder"))
    var tappableName = UILabel()
    var settingsButton = UIButton()
    var selectBtn = UIButton()
    
    //MARK: Reused view data
    var myUser = AppDelegate().myUser.first
    var avatarData: NSData? = nil
    var name: String? = ""
    var isEditingProfile: Bool = false
    
    //MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
    
    //MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupView() {
        contentView.sv(mainBackgroundView)
        contentView.layout(
            0,
            |-mainBackgroundView-| ~ self.contentView.frame.height
        )
        
        mainBackgroundView.sv(avatar, tappableName, selectBtn, settingsButton)
        mainBackgroundView.layout(
            (contentView.frame.height / 4), //Set very top margin based on contentview frame height
            avatar,
            10,
            |-tappableName-| ~ contentView.frame.height / 8,
            0,
            |-settingsButton-| ~ contentView.frame.height / 8
            
        )
        
        //MARK: - Additional cell layouts
        
        mainBackgroundView.backgroundColor = UIColor.groupTableViewBackground
        
        let imageFromData = UIImage(data: (myUser?.profileImg)! as Data) // Get image from locally stored NSData
        avatar.image = imageFromData
        avatar.layer.masksToBounds = true
        avatar.height(80)
        avatar.width(80)
        avatar.backgroundColor = UIColor.lightGray
        avatar.layer.cornerRadius = 40
        avatar.layer.borderColor = UIColor.darkGray.cgColor
        avatar.layer.borderWidth = 2
        avatar.centerHorizontally()
        
        tappableName.height(20)
        tappableName.top(-10) // Negative top offset to move above vertically-subsequent object
        tappableName.font = UIFont.svTextStyle2Font()
        tappableName.backgroundColor = UIColor.clear
        tappableName.textColor = UIColor.black
        tappableName.textAlignment = .center
        tappableName.text = myUser?.name
        
        //Setup edit profile button attributes
        var editProfileAttrText = NSAttributedString(string: "Edit Profile",
                                                     attributes: [NSForegroundColorAttributeName : UIColor.svBrightLightBlue, NSFontAttributeName: UIFont.svTextStyle4Font()!])
        if isEditingProfile {
            tappableName.frame = .zero
            tappableName.isHidden = true

            editProfileAttrText = NSAttributedString(string: "Update Image",
                                                     attributes: [NSForegroundColorAttributeName : UIColor.svBrightLightBlue, NSFontAttributeName: UIFont.svTextStyle4Font()!])
        }
        
        settingsButton.setAttributedTitle(editProfileAttrText, for: .normal)
    }
    
    // MARK: - Clear data for reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tappableName.text = ""
        avatar.image = nil
        avatar.isHidden = false
        avatar.sd_cancelCurrentImageLoad()
    }
}
