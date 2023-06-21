//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Георгий Матросов on 22.05.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() 
    func didFailToLoadData(with error: Error)
}
