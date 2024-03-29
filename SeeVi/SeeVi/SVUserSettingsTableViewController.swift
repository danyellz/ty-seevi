//
//  SVUserSettingsViewController.swift
//  SeeVi
//
//  Created by Ty Daniels on 4/10/17.
//  Copyright © 2017 Ty Daniels. All rights reserved.
//

import Foundation
import UIKit

class SVUserSettingsTableViewController: UITableViewController, EditSettingDelegate, UINavigationControllerDelegate {
    
    // MARK: - View assets
    var closeButton = UIBarButtonItem()
    var saveButton = UIBarButtonItem()
    
    // MARK: - Controllers
    var editSettingViewController = SVEditUserViewController()
    var paymentsViewController = SVPaymentsViewController()
    let imagePicker = UIImagePickerController()
    
    //MARK : - View data
    let realmManager = AppDelegate().realm
    var thisUser = AppDelegate().myUser[0]
    var infoTitles = ["Full name", "E-mail"]
    var passTitle = ["Current password"]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup image picker
        imagePicker.delegate = self
        
        //Setup tableview
        tableView.delegate = self
        tableView.dataSource = self
        
        //Link unique reuse-identifiers
        tableView.register(SVTextViewCell.self, forCellReuseIdentifier: "textViewCell")
        tableView.register(SVProfileUserCell.self, forCellReuseIdentifier: "ProfileCell")
        tableView.register(SVProfileSettingsCell.self, forCellReuseIdentifier: "settingCell")
        
        setupView()
    }
    
    // MARK: - Layout views
    
    /*
     Setup views/containers. Using Stevia to configure layouts: a framework that is practical due to
     a more visually intuitive syntax. The basic usage of this framework involves setting a top constraint
     for every asset that is vertically aligned. Also, Stevia allows for positioning view objects horizontally
     aligned, and the sizes of each element become relative to one another based on percentages in relation to UIWindow sizes.
     Finally, |-asset-| spans the window with a small margin left/right. ~ is used to set an approximate
     height relative to window height.
     
     In order to use Stevia:
     - 1. Add subviews to corresponding views w/ UIView.sv(views)
     - 2. Layout views within the top view with UIView.layout()
     */
    fileprivate func setupView() {
        // MARK : Additional layouts
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveChanges))
        navigationItem.rightBarButtonItem = rightBarButton //Right
    }
    
    @objc fileprivate func saveChanges() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Updates from SVProfileSettingsCell button
    
    @objc fileprivate func selectButtonForCell(sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let button = sender as! UIButton
        
        UIView.animate(withDuration: 0.2, animations: { //Bouncy button animation on eye select/deselect
            button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }, completion: { _ in
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: { [] in
                            button.transform = .identity
            }, completion: nil)
        })
        
        if let index = self.tableView.indexPathForRow(at: buttonPosition)?.row {
            processButtonSelection(index: index)
        }
    }
    
    /* 
     NOTE: This simply changes the bool tied to the user, which indicates whether or not the password string
     should be shown. Ideally there would be a workaround unrelated to local data. This logic would be triggered within
     the cell via a custom protocol, etc.
     */
    fileprivate func processButtonSelection(index: Int) {
        let selectedUser = realmManager.objects(SVUser.self).first
        
        // Set password bool to opposite
        try! realmManager.write {() -> Void in
            (selectedUser?.isPassShowing = !(selectedUser?.isPassShowing)!)!
        }
        // Change password string security
        tableView.reloadData()
    }
    
    @objc fileprivate func showImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
    }
    
    //PROTOCOLS
    
    func updateSettings() {
        tableView.reloadData()
    }
    
    // MARK: - Tableview controller protocols
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return infoTitles.count
        case 2:
            return 2
        case 5:
            return 1
        default:
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! SVProfileUserCell
        
        switch indexPath.section {
        case 0:
            
            //Profile cell
            
            profileCell.isEditingProfile = true //Set bool to modify profile cell layout for settings
            profileCell.settingsButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
            return profileCell
        case 1:
            
            //User information
            
            let settingCell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SVProfileSettingsCell
            if indexPath.row == 0 {
                settingCell.descriptionLabel.text = infoTitles[indexPath.row]
                settingCell.userValLabel.text = thisUser.name
                settingCell.accessoryType = .disclosureIndicator
            } else {
                settingCell.descriptionLabel.text = infoTitles[indexPath.row]
                settingCell.userValLabel.text = thisUser.email
                settingCell.accessoryType = .disclosureIndicator
            }
            return settingCell
        case 2:
            
            //User security
            
            let settingCell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SVProfileSettingsCell
            if indexPath.row == 0 {
                settingCell.descriptionLabel.text = passTitle[indexPath.row]
                settingCell.userValLabel.text = thisUser.passWord
                settingCell.isPass = true
                settingCell.isPassShown = thisUser.isPassShowing
                settingCell.viewPassBtn.tag = indexPath.row
                settingCell.viewPassBtn.addTarget(self, action: #selector(selectButtonForCell(sender:)), for: .touchUpInside)
                settingCell.separatorInset = UIEdgeInsetsMake(0, view.bounds.width/2.0, 0, view.bounds.width/2.0)
                return settingCell
            } else {
                settingCell.descriptionLabel.text = "Change password"
                settingCell.userValLabel.isHidden = true // Hidden description label--only used to pass value to detail
                settingCell.userValLabel.text = thisUser.passWord
                settingCell.accessoryType = .disclosureIndicator
                return settingCell
            }
        case 3:
            
            //User tags
            
            let settingCell = tableView.dequeueReusableCell(withIdentifier: "textViewCell") as! SVTextViewCell
            settingCell.descriptionView.text = "BEER, FOOD, GAMES, CODE"
            return settingCell
            
        case 4:
            
            //User description
            
            let settingCell = tableView.dequeueReusableCell(withIdentifier: "textViewCell") as! SVTextViewCell
            settingCell.descriptionView.text = thisUser.userDescription
            return settingCell
        case 5:
            
            //Billing
            
            let settingCell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as! SVProfileSettingsCell
            settingCell.descriptionLabel.text = "Payment methods"
            settingCell.accessoryType = .disclosureIndicator
            return settingCell
        default:
            break
        }
        
        return UITableViewCell() //Return unitialized cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // No transition for section 0
        guard indexPath.section != 0 && indexPath.section != 3 && indexPath.section != 4 else {
            return
        }
        
        // Prep cell data to pass to edit viewcontroller
        let index = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: index!) as! SVProfileSettingsCell
        let titleToPass = currentCell.descriptionLabel.text
        let valueToPass = currentCell.userValLabel.text
        
        //Set var values for the settings detailview
        editSettingViewController.settingsDelegate = self
        editSettingViewController.editingLabel.text = titleToPass
        editSettingViewController.editTextField.text = valueToPass
        
        //Trigger transition to edit viewcontroller for cells with indicators
        switch indexPath.section {
        case 2:
            if indexPath.row == 0 {
                break
            } else {
                navigationController?.pushViewController(editSettingViewController, animated: true)
            }
        case 3:
            break
        case 4:
            break
        case 5:
            navigationController?.pushViewController(paymentsViewController, animated: true)
        default:
            navigationController?.pushViewController(editSettingViewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellConstant = view.frame.height / 12
        let extendedCellConstant = view.frame.height / 6
        
        switch indexPath.section {
        case 0:
            return view.frame.height / 3
        case 4:
            return extendedCellConstant
        case 5:
            return extendedCellConstant
        default:
            return cellConstant
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "User information"
        case 2:
            return "User security"
        case 3:
            return "Tags"
        case 4:
            return "Description"
        case 5:
            return "Billing"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.backgroundView?.backgroundColor = UIColor.groupTableViewBackground
            headerView.textLabel?.textColor = UIColor.svDarkBlue
            headerView.textLabel?.font = UIFont.svTextStyle5Font()
            headerView.textLabel?.backgroundColor = UIColor.clear
            headerView.layer.opacity = 0.9
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 20 {
            self.title = thisUser.name
        } else {
            self.title = ""
        }
    }
}

// MARK: - Image picker protocols

extension SVUserSettingsTableViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print(info)
        if let theImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImage = UIImage().resizeImage(image: theImage, newWidth: 200)
            let updateUser = realmManager.objects(SVUser.self).first
            let imageData = UIImagePNGRepresentation(resizedImage!)! as NSData
            
            try! realmManager.write {
                updateUser?.profileImg = imageData
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
        tableView.reloadData()
    }
}
