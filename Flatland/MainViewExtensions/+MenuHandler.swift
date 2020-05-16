//
//  +MenuHandler.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension MainView: UIPopoverPresentationControllerDelegate, MenuControllerDelegate
{
    func ShowSettingsWindow()
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "GeneralSettingsMenuRoot") as? GeneralSettingsController
        {
            Controller.Delegate = self
            Controller.Main = self
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = SettingsButton
                PopView.sourceRect = SettingsButton.bounds
            }
        }
    }
    
    func SettingsClosed()
    {
    }
}
