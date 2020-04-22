//
//  User.swift
//  ARApp
//
//  Created by Ryan Grogan on 4/17/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import Foundation

struct User{
    var username:String;
    var password:String;
    var name:String;
    var bio:String;
    var age:Int;
    var student:bool;
    
    init(username: String, password: String, name: String, bio: String, age: Int, student: Boolean){
        self.username = username;
        self.password = password;
        self.name = name;
        self.bio = bio;
        self.age = age;
        self.student = student;
    }
    var prepped:String{
        get{
            return  "INSERT OR IGNORE INTO users (`username`, `password`, `name`, `bio`, `age`, `student`) VALUES (\'\(username)\', \'\(password)\', \'\(name)\', \'\(bio)\', \'\(age)\', \'\(student)\')"
        }
    }
}
