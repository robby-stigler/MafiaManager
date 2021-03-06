//
//  SignUpViewController.swift
//  MafiaManager
//
//  Created by Tesia Wu on 3/21/19.
//  Copyright © 2019 Aishwarya Shashidhar. All rights reserved.
//
//  Responsible for handling the sign up view controller

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    let signInSegueIdentifier = "signInSegueIdentifier"
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var mafiaImage: UIImageView!
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    
    @IBOutlet weak var signUpkeyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpimageHeightConstraint: NSLayoutConstraint!
    
    @IBAction func onRegisterButtonPressed(_ sender: Any) {
        // Check if input is valid
        guard
            let name = nameTextfield.text,
            let email = emailTextfield.text,
            let password = passwordTextfield.text,
            let confirmPassword = confirmPasswordTextfield.text,
            name.count > 0,
            email.count > 0,
            password.count > 0,
            confirmPassword.count > 0
            else {
                let alert = UIAlertController(
                    title: "Empty Fields",
                    message: "Please fill in the required fields",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        guard password == confirmPassword
            else {
                let alert = UIAlertController(
                    title: "Passwords do not match",
                    message: "Please confirm your password",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                return
        }
        
        // Sign up logic
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { user, error in
            if error == nil && user != nil {
                // In the database, tie the name to the user
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("users").child(user!.user.uid).setValue(["Name":name])
                
                // Just automatically sign in
                Auth.auth().signIn(withEmail: self.emailTextfield.text!,
                                   password: self.passwordTextfield.text!)
                // Go to welcome page
                let homeView = self.storyboard?.instantiateViewController(withIdentifier: "loadingWelcomeIdentifier") as! LoadingWelcomeViewController
                self.present(homeView, animated: true, completion: nil)
                
            } else if error != nil && user == nil {
                let alert = UIAlertController(
                    title: "Sign Up Failed",
                    message: error!.localizedDescription,
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onCancelbuttonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Mafia icon should appear
        CoreGraphicsHelper.colorButtons(button: registerButton, color: CoreGraphicsHelper.darkRedColor)
        mafiaImage.image = UIImage(named: "MafiaIcon")
        passwordTextfield.isSecureTextEntry = true
        confirmPasswordTextfield.isSecureTextEntry = true
        
        // After signing up
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                // Switch to the welcome screen and clear fields
                self.nameTextfield.text = nil
                self.emailTextfield.text = nil
                self.passwordTextfield.text = nil
                self.confirmPasswordTextfield.text = nil
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    // code to dismiss keyboard when user clicks on background
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame!.origin.y
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            let keyboardShow: Bool!
            if endFrameY >= UIScreen.main.bounds.size.height {
                print("signup keyboard hide")
                keyboardShow = false
                self.signUpkeyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                print("signup keyboard show")
                keyboardShow = true
                self.signUpkeyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            print("size:", mafiaImage.frame.size)
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            if keyboardShow {
                                self.mafiaImage?.isHidden = true
                                self.signUpimageHeightConstraint?.constant = 0.0
                            } else {
                                self.mafiaImage?.isHidden = false
                                self.signUpimageHeightConstraint?.constant = 172.0
                            }
                            self.view.layoutIfNeeded() },
                           completion: nil)
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
