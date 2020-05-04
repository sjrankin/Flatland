//
//  AboutView.swift
//  Flatland
//
//  Created by Stuart Rankin on 5/4/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class AboutView: UIViewController, UIPopoverPresentationControllerDelegate
{
    public weak var ClosedDelegate: ChildClosed? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AboutWorld.ShowAsHelp()
    }
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        ClosedDelegate?.ChildWindowClosed()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleDetailsPressed(_ sender: Any)
    {
        let Storyboard = UIStoryboard(name: "Menus", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "VersioningMenu") as? VersioningMenu
        {
            Controller.modalPresentationStyle = .popover
            if let PresentingController = Controller.presentationController
            {
                PresentingController.delegate = self
            }
            self.present(Controller, animated: true, completion: nil)
            if let PopView = Controller.popoverPresentationController
            {
                PopView.sourceView = DetailsButton
                PopView.sourceRect = DetailsButton.bounds
            }
        }
    }
    
    /// Tells the view controller how to display the context menus.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    @IBOutlet weak var DetailsButton: UIButton!
    @IBOutlet weak var AboutWorld: GlobeView!
}
