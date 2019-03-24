//
//  LoadingWelcomeViewController.swift
//  MafiaManager
//
//  Created by Tesia Wu on 3/21/19.
//  Copyright © 2019 Aishwarya Shashidhar. All rights reserved.
//

import UIKit

class LoadingWelcomeViewController: UIViewController {
    
    let FirstViewControllerIdentifier = "FirstViewControllerIdentifier"
    
    @IBOutlet weak var mafiaUserImage: UIImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mafiaUserImage.image = UIImage(named: "WelcomeLoadingPicture")
        usersNameLabel.text = "User"
       
        // Transitions after a few seconds to the first VC (deck management)
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            print("Timer fired!")
            /*
            let transitionViewController = FirstViewController()
            self.present(transitionViewController, animated: true, completion: nil)
            */
            let homeView = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewControllerIdentifier") as! FirstViewController
            self.present(homeView, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}