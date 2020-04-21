//
//  SQLHandler.swift
//  ARApp
//
//  Created by Ryan Grogan on 3/12/20.
//  Copyright © 2020 Ryan Grogan. All rights reserved.
//

import Foundation
import SQLite3



class SQLHandler{
    //singleton
    static let shared = SQLHandler()
    //database
    var db:OpaquePointer?
    //possible errors
    enum SQLError: Error{
        case BindingFailed
        case EmptyParams
        case PreparedStatementFailed
        case ExecutionFailed
        case OpenDatabaseFailed
        case PreparationFailed
    }
    
    
    var users:[User] =
    [
        //Doctor, can see the parents and the student
        User(username: "SamuelCullens",     //username
            password: "Pass1",              //password
            name: "Samuel Cullens",         //name
            bio: "I Have been helping parents diagnose for 10 years.",   // bio
            age: 45,                        //age
            student: 0),                    //student
        //Therapist, can see the guardian and the student
        User(username: "SiennaCowlry",
             password: "Pass2",
             name: "Sienna Cowlry",
             bio: "I have been teaching special needs for 6 years.",
             age: 34,
             student: 0),
        //Caretaker, can see the guardian and the student
        User(username: "JenniferDall",
             password: "Pass3",
             name: "Jennifer Dall",
             bio: "I have been caring for 5 years",
             age: 27,
             student: 0),
        //Guardian, can see caretaker, therapist, doctor.
        User(username: "TonyGroves",
             password: "Pass4",
             name: "Toney Groves",
            bio: "I have been a father for 9 years. Contact info: (123)-456-789",
            age: 37,
            student: 0),
        //Students do not log in, but their profile is stored.
        User(username: "DanielGroves",
             password: "",
             name: "Daniel Groves",
             bio: "Diagnosed in 2012",
             age: 9,
             student: 1),
        User(username: "JohnCian",
             password: "",
             name: "John Cian",
             bio: "Diagnosed in 2006",
             age: 14,
             student: 1),
    ]
    
    let perms:[Permission] =
    [
        //guardian(s)
        Permission(user1: "TonyGroves", user2: "DanielGroves"),
        Permission(user1: "TonyGroves", user2: "SamuelCullens"),
        Permission(user1: "TonyGroves", user2: "SiennaCowlry"),
        Permission(user1: "TonyGroves", user2: "JenniferDall"),
        //Doctor(s)
        Permission(user1: "SamuelCullens", user2: "TonyGroves"),
        Permission(user1: "SamuelCullens", user2: "DanielGroves"),
        //Therapist
        Permission(user1: "SiennaCowlry", user2: "TonyGroves"),
        Permission(user1: "SiennaCowlry", user2: "DanielGroves"),
        Permission(user1: "SiennaCowlry", user2: "JohnCian"),
        //Caretaker
        Permission(user1: "JenniferDall", user2: "TonyGroves"),
        Permission(user1: "JenniferDall", user2: "DanielGroves")
    
    ]
    
    let students:[Student] =
    [
        //Guardian
        Student(teacher: "TonyGroves", student: "DanielGroves"),
        //Doctor
        Student(teacher: "SamuelCullens", student: "DanielGroves"),
        //Therapist
        Student(teacher: "SiennaCowlry", student: "DanielGroves"),
        Student(teacher: "SiennaCowlry", student: "JohnCian"),
        //caretaker
        Student(teacher: "JenniferDall", student: "DanielGroves")
    ]
    //tables needed to operate
    
    let tables:[Table] =
        [
            //User table is for therapists, guardians, and students
            Table(name: "users", query: "CREATE TABLE IF NOT EXISTS users (`username` TEXT, `password` TEXT, `name` TEXT, `bio` TEXT, `age` INT, `student` BOOLEAN, UNIQUE(username))"),
            Table(name: "permissions", query: "CREATE TABLE IF NOT EXISTS permissions (`id` TEXT, `user1` TEXT, `user2` TEXT, UNIQUE(id))"),
            Table(name: "students", query: "CREATE TABLE IF NOT EXISTS students (`id` TEXT, `teacher` TEXT, `student` TEXT, UNIQUE(id))")
            
            //Lesson table is a list of possible lessons
            //"CREATE TABLE IF NOT EXISTS lessons (lesson TEXT, lessonplan TEXT)",
            //Progress table is for tracking progress of students
            //"CREATE TABLE IF NOT EXISTS progress (student TEXT, lesson TEXT, completed BOOLEAN, completion TEXT)"
        ]
    
    
    
    func Start() throws{
        print("starting sql handler")
        //db path
        let dir = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString)!
        let dbpath = dir+"db.sqlite3"
        
        //open the database
        if sqlite3_open(dbpath, &db) != SQLITE_OK{
            //error
            print("error")
            throw SQLError.OpenDatabaseFailed
        }
        //create tables
        for table in tables{
            var stmt: OpaquePointer?
            if sqlite3_prepare(db, table.query, -1, &stmt, nil) != SQLITE_OK{
                sqlite3_finalize(stmt)
                print("Failed to create table \(table.name)")
                throw(SQLError.PreparationFailed)
            }
            if sqlite3_step(stmt) == SQLITE_DONE{
                print("Created table \(table.name)")
            }
            sqlite3_finalize(stmt)
        }
        print("Tables created")
        //creates default users
        for user in users{
            var stmt: OpaquePointer?
            if sqlite3_prepare(db, user.prepped, -1, &stmt, nil) != SQLITE_OK{
                //error
                print("user \(user.username) not created")
                sqlite3_finalize(stmt)
                throw SQLError.PreparationFailed
            }
            
            if sqlite3_step(stmt) == SQLITE_DONE{
                print("Created user \(user.username)")
            }else{
                //still more left
            }
            sqlite3_finalize(stmt)
        }
        print("Users created")
        for perm in perms{
            var stmt: OpaquePointer?
            if(sqlite3_prepare(db, perm.prepped, -1, &stmt, nil) == SQLITE_OK){
                if(sqlite3_step(stmt) == SQLITE_DONE){
                    print("Created permission \(perm.id)")
                }else{
                    print("Permission")
                }
            }else{
                print("Permission \(perm.id) failed")
                print(sqlite3_extended_errcode(stmt))
            }
            sqlite3_finalize(stmt)
        }
        print("Permissions finished")
        for student in students{
            var stmt: OpaquePointer?
            if(sqlite3_prepare(db, student.prepped, -1, &stmt, nil) == SQLITE_OK){
                if(sqlite3_step(stmt) == SQLITE_DONE){
                    print("Created student relation \(student.id)")
                }
            }
        }
        print("Students created")
        print("sql finished");
    }
    
    func CheckLogin(user: String, pass: String) -> Bool{
        if CheckUserExists(user: user) && CheckPass(user: user, pass: pass){
            //successful login
            return true
        }else{
            //bad login
            return false
        }
    }
    
    func CheckUserExists(user: String) -> Bool{
        var stmt: OpaquePointer?
        //let checkQuery = "SELECT COUNT(1) FROM users WHERE username = "+user
        let checkQuery = "SELECT COUNT(1) FROM users WHERE username = '\(user)'"
        let studentQuery = "SELECT student FROM users WHERE username = '\(user)'"
        if sqlite3_prepare(db, checkQuery, -1, &stmt, nil) == SQLITE_OK{
            if sqlite3_step(stmt) == SQLITE_ROW{
                //let result = String(cString: sqlite3_column_text(stmt, 1))
                let result = sqlite3_column_int(stmt, 0)
                print("# of accounts by \(user): \(result)")
                if result == 1{
                    if(sqlite3_prepare(db, studentQuery, -1, &stmt, nil) == SQLITE_OK){
                        if(sqlite3_step(stmt) == SQLITE_ROW){
                            let studnt = sqlite3_column_int(stmt, 0)
                            if(studnt == 0){
                                sqlite3_finalize(stmt)
                                return true;
                            }else{
                                print("User is a student!")
                                sqlite3_finalize(stmt)
                                return false;
                            }
                        }
                    }
                    sqlite3_finalize(stmt)
                }
            }
            
        }
        sqlite3_finalize(stmt)
        return false
    }
    
    func CheckPass(user: String, pass: String) -> Bool{
        //not encrypted
        var stmt : OpaquePointer?
        let checkQuery = "SELECT password FROM users WHERE username = '\(user)'"
        if sqlite3_prepare(db, checkQuery, -1, &stmt, nil) == SQLITE_OK{
            if sqlite3_step(stmt) == SQLITE_ROW{
                let result = String(cString: sqlite3_column_text(stmt, 0))
                if result == pass{
                    sqlite3_finalize(stmt)
                    return true;
                }
            }
        }
        sqlite3_finalize(stmt)
        return false;
    }
    
    func GetUser(user: String, pass: String) -> User{
        if(CheckLogin(user: user, pass: pass)){
            var stmt:OpaquePointer?
            let query = "SELECT * FROM users WHERE username = '\(user)'"
            let prepped = sqlite3_prepare(db, query, -1, &stmt, nil)
            if (prepped != SQLITE_OK) {
                
                //preppared statement is failing
                print("prepare failed - get info for logon")
                if(prepped == SQLITE_ERROR){
                    print("sql error")
                    print(sqlite3_extended_errcode(stmt))
                }
                sqlite3_finalize(stmt)
                return User.empty
            }
            if sqlite3_step(stmt) != SQLITE_ROW{
                print("step failed")
                sqlite3_finalize(stmt)
                return User.empty
            }
            let name = String(cString: sqlite3_column_text(stmt, 2))
            let bio = String(cString: sqlite3_column_text(stmt, 3))
            let age = sqlite3_column_int(stmt, 4)
            let student = sqlite3_column_int(stmt, 5)
            sqlite3_finalize(stmt)
            return User(username: user, password: pass, name: name, bio: bio, age: Int(age), student: Int(student))
        }else{
            return User.empty;
        }
    }
    
    func GetUser(user1: String, pass: String, user2: String) -> User{
        if(CheckLogin(user: user1, pass: pass) && CheckPerms(user1: user1, pass: pass, user2: user2)){
            var stmt:OpaquePointer?
            let query = "SELECT * FROM users WHERE username = '\(user2)'"
            if sqlite3_prepare(db, query, -1, &stmt, nil) != SQLITE_OK{
                print("error - get info other user")
                sqlite3_finalize(stmt)
                return User.empty
            }
            if sqlite3_step(stmt) != SQLITE_ROW{
                print("not a row")
                sqlite3_finalize(stmt)
                return User.empty
            }
            
            let username = String(cString: sqlite3_column_text(stmt, 0))
            let name = String(cString: sqlite3_column_text(stmt, 2))
            let bio = String(cString: sqlite3_column_text(stmt, 3))
            let age = sqlite3_column_int(stmt, 4)
            let student = sqlite3_column_int(stmt, 5)
            sqlite3_finalize(stmt)
            return User(username: username, password: "", name: name, bio: bio, age: Int(age), student: Int(student))
        }
        return User.empty
    }
    
    func CheckPerms(user1: String, pass: String, user2: String) -> Bool{
        var stmt:OpaquePointer?
        let prepped = "SELECT COUNT(1) FROM permissions WHERE user1 = '\(user1)' AND user2 = '\(user2)'"
        if(sqlite3_prepare(db, prepped, -1, &stmt, nil) == SQLITE_OK){
            if(sqlite3_step(stmt) == SQLITE_ROW){
                if(sqlite3_column_int(stmt, 0) == 1){
                    sqlite3_finalize(stmt)
                    return true;
                }
                return false;
            }
        }
        sqlite3_finalize(stmt)
        return false;
    }
    
    func GetStudents(user: String, pass: String) -> [User]{
        if(CheckLogin(user: user, pass: pass)){
            //print("successful login")
            var stmt: OpaquePointer?
            var stdntUsrs:[String] = []
            let prepped = "SELECT * FROM students WHERE teacher = '\(user)'"
            if sqlite3_prepare(db, prepped, -1, &stmt, nil) == SQLITE_OK{
                while sqlite3_step(stmt) == SQLITE_ROW{
                    stdntUsrs.append(String(cString: sqlite3_column_text(stmt, 2)))
                }
                print(stdntUsrs)
                sqlite3_finalize(stmt)
                var studnts:[User] = []
                for stdnt in stdntUsrs{
                    let prepped = "SELECT * FROM users WHERE username = '\(stdnt)'"
                    if(sqlite3_prepare(db, prepped, -1, &stmt, nil) == SQLITE_OK){
                        if(sqlite3_step(stmt) == SQLITE_ROW){
                            let username = String(cString: sqlite3_column_text(stmt, 0))
                            print(username)
                            let passwd = ""
                            let name = String(cString: sqlite3_column_text(stmt, 2))
                            let bio = String(cString: sqlite3_column_text(stmt, 3))
                            let age = sqlite3_column_int(stmt, 4)
                            let student:User = User(username: username, password: passwd, name: name, bio: bio, age: Int(age), student: 1)
                            studnts.append(student)
                            sqlite3_finalize(stmt)
                        }
                    }else{
                        sqlite3_finalize(stmt)
                        print("Failed to retrieve student \(stdnt)")
                        return []
                    }
                }
                return studnts
            }else{
                sqlite3_finalize(stmt)
            }
        }else{
            print("Incorrect login")
        }
        return []
    }
    
    func CreatePreparedStmt(params: [String], query: String) throws -> OpaquePointer?{ //returns nil if preparing or binding malfunctions
        //finished statement
        var finalStmt : OpaquePointer?
        //simple error function. Is run when an error is encountered and automatically finalizes statememt
        let error = {() -> () in
            print("Error!");
            sqlite3_finalize(finalStmt)
        }
        //check if params is empty
        if(params.count < 1){
            error()
            throw(SQLError.EmptyParams)
        }
        //prepare statement
        if sqlite3_prepare(db, query, -1, &finalStmt, nil) != SQLITE_OK{
            //error
            error()
            throw(SQLError.PreparationFailed)
        }
        //bind statement
        for i in 1...params.count{
            if sqlite3_bind_text(finalStmt, Int32(i), params[i], -1, nil) != SQLITE_OK{
                //error
                error()
                throw(SQLError.BindingFailed)
            }
        }
        return finalStmt;
    }
}

struct Table{
    var name:String;
    var query:String;
}

struct User{
    
    static var empty:User = User(username: "", password: "", name: "", bio: "", age: -1, student: -1)
    
    var username:String;
    var password:String;
    var name:String;
    var bio:String;
    var age:Int;
    var student:Int;
    
    init(username: String, password: String, name: String, bio: String, age: Int, student: Int){
        self.username = username;
        self.password = password;
        self.name = name;
        self.bio = bio;
        self.age = age;
        self.student = student;
    }
    var prepped:String{
        get{
            return "INSERT OR IGNORE INTO users (`username`, `password`, `name`, `bio`, `age`, `student`) VALUES('\(username)', '\(password)', '\(name)', '\(bio)', '\(age)', '\(student)')"
        }
    }
}

struct Permission{
    var id:String{
        get{
            return user1+user2;
        }
    }
    var user1:String;
    var user2:String;
    
    init(user1:String, user2:String){
        self.user1 = user1;
        self.user2 = user2;
    }
    
    var prepped:String{
        get{
            return "INSERT OR IGNORE INTO permissions (`id`,`user1`,`user2`) VALUES('\(id)', '\(user1)', '\(user2)')"
        }
    }
}

struct Student{
    var id:String{
        get{
            return teacher+student
        }
    }
    var teacher:String;
    var student:String;
    
    init(teacher:String, student:String){
        self.teacher = teacher;
        self.student = student;
    }
    
    var prepped:String{
        get{
            return "INSERT OR IGNORE INTO students (`id`,`teacher`,`student`) VALUES('\(id)', '\(teacher)', '\(student)')"
        }
    }
}
