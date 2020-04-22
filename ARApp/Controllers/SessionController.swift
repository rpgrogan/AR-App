//
//  SessionController.swift
//  ARApp
//
//  Created by Ryan Grogan on 3/14/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//
import UIKit


class SessionController : UIViewController, SetStudentDelegate{
    func SetStudent(studnt: User, view: StudentTableController) {
        view.dismiss(animated: true) {
            self.SetStudent(student: studnt)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    var user:User!
    var student:User!
    @IBOutlet weak var UserImg: UIImageView!
    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var StudentImg: UIImageView!
    @IBOutlet weak var StudentBtn: UIButton!
    let stdntSelect: StudentTableController = StudentTableController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting User Image
        UserImg.image = UIImage(named: user.username)
        UserImg.layer.borderWidth = 1
        UserImg.layer.masksToBounds = false
        UserImg.layer.borderColor = UIColor.black.cgColor
        UserImg.layer.cornerRadius = UserImg.frame.height/2
        UserImg.clipsToBounds = true
        //setting student img
        StudentImg.layer.borderWidth = 1
        StudentImg.layer.masksToBounds = false
        StudentImg.layer.borderColor = UIColor.black.cgColor
        StudentImg.layer.cornerRadius = StudentImg.frame.height/2
        StudentImg.clipsToBounds = true
        //Setting Name
        UserName.text = user.name
        //print(SQLHandler.shared.GetStudents(user: user.username, pass: user.password))
        print("Session loaded")
    }
    
    func SetStudent(student: User){
        self.student = student
        StudentImg.image = UIImage(named: student.username)
        StudentBtn.setTitle(student.name, for: .normal)
        //update other student specific things
    }
    
    //Called when student name is pressed
    @IBAction func OnStudentBtnPress(_ sender: UIButton) {
        performSegue(withIdentifier: "Session2StudentSelect", sender: nil)
    }
    
    
    //Called when the 'Start Session' button is pressed
    @IBAction func OnSessionStartBtnPress(_ sender: UIButton) {
        performSegue(withIdentifier: "Session2AR", sender: nil)
    }
    //Called when preparing to segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        if(segue.identifier == "Session2StudentSelect"){
            let table = segue.destination as? StudentTableController
            table?.delegate = self
            table?.students = SQLHandler.shared.GetStudents(user: user.username, pass: user.password)
        }
    }
}
