//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Георгий Матросов on 23.05.2023.
//

import Foundation

struct GameRecord: Codable, Comparable{
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
    
    let correct: Int
    let total: Int
    let date: Date
    
}

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int)
}


final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct,
             total,
             bestGame,
             gamesCount
    }
    
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get{
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    
    func store(correct count: Int, total amount: Int) {
        
        self.correct += count
        
        self.total += amount
        
        self.gamesCount += 1

        let thisGame = GameRecord(correct: count, total: amount, date: Date())
        if bestGame < thisGame {
            bestGame = thisGame
        }
        
    }
    
}
