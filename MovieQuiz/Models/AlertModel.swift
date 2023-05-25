//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Георгий Матросов on 22.05.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
    
}
