//
//  LoginViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 2/5/2023.
//
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
    }
    
    func setupAuthListener() {
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            
            (self.databaseController as! FirebaseController).currentUser = user
            
            if user != nil {
                self.performSegue(withIdentifier: "loggedInSegue", sender: self)
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    @IBAction func signUp(_ sender: Any) {
        guard let email = emailField.text else {
            displayMessage(title: "Empty Email", message: "Email cannot be empty.")
            return
        }
        
        guard let password = passwordField.text else {
            displayMessage(title: "Empty Password", message: "Password cannot be empty.")
            return
        }
        
        let result = databaseController!.signUpWith(email: email, password: password)
        
        if result {
            displayMessage(title: "Account Created", message: "Account created successfully.")
        }
        else {
            displayMessage(title: "Sign Up Failed", message: "Error ocurred when signing up.")
        }
    }
        
    @IBAction func signIn(_ sender: Any) {
        guard let email = emailField.text, let password = passwordField.text else {
            displayMessage(title: "Empty Fields", message: "Email and password cannot be empty.")
            return
        }
        
        
        let result = databaseController!.signInWith(email: email, password: password)
        
        if result {
            displayMessage(title: "Login Success", message: "Logged in successfully.")
        }
        else {
            displayMessage(title: "Login Failed", message: "Error occured when logging in.")
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
    
    // MARK: - Miscellaneous
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

