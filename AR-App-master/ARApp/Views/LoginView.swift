//
//  LoginView.swift
//  ARApp
//
//  Created by Ryan Grogan on 3/14/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import Foundation
import UIKit

class LoginView{
    @IBOutlet var LoginFields: [UITextField]!
    @IBOutlet weak var LoginBtn: UIButton!
    var usernameValid: Bool = false
    var passwordValid: Bool = false
    var handler = SQLHandler.shared

    @IBAction func OnReturn(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    @IBAction func OnFieldChange(_ sender: UITextField) {
        if(sender.placeholder == "Username"){ //current UIfield is login
            if(sender.text?.contains(" ") ?? true){//username has spaces in it
                usernameValid = false;
                return;
            }else{
                usernameValid = true;
            }
        }else{ //current UIfield is password
            if(sender.text?.count ?? 0 >= 5){
                passwordValid = true;
            }else{
                passwordValid = false;
            }
        }
        if(usernameValid && passwordValid){
            LoginBtn.isEnabled = true;
        }else{
            LoginBtn.isEnabled = false;
        }
    }
    
    @IBAction func OnLoginBtnPress(_ sender: UIButton) {
        if(handler.CheckLogin(user: LoginFields[0].text ?? "", pass: LoginFields[1].text ?? "")){
        //login successful
        OnLogin()
        }else{
        //bad login
            let alert = UIAlertController(title: "Login Submition", message: "Username or password is incorrect.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
// Called when properly logged in
    func OnLogin(){
        print("logging in...")
        performSegue(withIdentifier: "Login2Session", sender: nil)
    }
}
