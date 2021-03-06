//
//  JogoDaMemoriaViewModel.swift
//  Portifolio
//
//  Created by Bruno Soares on 19/07/20.
//  Copyright © 2020 Bruno Vieira. All rights reserved.
//

import Foundation
import UIKit

class JogoDaMemoriaViewModel {
    enum Cards: Int, CaseIterable {
        case cow = 1
        case equalCow
        case chicken
        case equalChicken
        case bear
        case equalBear
        case dog
        case equalDog
        case elephant
        case equalElephant
        case frog
        case equalFrog
        case bird
        case equalBird
        case kangaroo
        case equalKangaroo
        
        var cardImage: UIImage? {
            switch self {
            case .cow, .equalCow:
                return UIImage(named: "cow")
            case .chicken, .equalChicken:
                return UIImage(named: "chicken")
            case .bear, .equalBear:
                return UIImage(named: "bear")
            case .dog, .equalDog:
                return UIImage(named: "dog")
            case .elephant, .equalElephant:
                return UIImage(named: "elephant")
            case .frog, .equalFrog:
                return UIImage(named: "frog")
            case .bird, .equalBird:
                return UIImage(named: "bird")
            case .kangaroo, .equalKangaroo:
                return UIImage(named: "kangaroo")
            }
        }
        
        var reletedTo: Cards {
            switch self {
            
            case .cow:
                return .equalCow
            case .equalCow:
                return .cow
            case .chicken:
                return .equalChicken
            case .equalChicken:
                return .chicken
            case .bear:
                return .equalBear
            case .equalBear:
                return .bear
            case .dog:
                return .equalDog
            case .equalDog:
                return .dog
            case .elephant:
                return .equalElephant
            case .equalElephant:
                return .elephant
            case .frog:
                return .equalFrog
            case .equalFrog:
                return .frog
            case .bird:
                return .equalBird
            case .equalBird:
                return .bird
            case .kangaroo:
                return .equalKangaroo
            case .equalKangaroo:
                return .kangaroo
            }
        }
    }
    
    var updateViewCards: ((_ card1: Cards?,_ card2: Cards?) -> Void)?
    var updateViewCronometer: ((String) -> Void)?
    var playerDidWin: ((_ score: String?) -> Void)?
    
    var cardsRightAwnser: [Cards:Bool] = [:]
    
    private var scoreFormat: ((_ minute: Int,_ second:Int) -> String) = { (minute, second) in
        return "\(minute < 10 ? "0\(minute)" : "\(minute)"):\(second < 10 ? "0\(second)" : "\(second)")"
    }
    
    var cardsClicked: (card1: Cards?, card2: Cards?) = (nil, nil)
    
    private func checkinBothCardsClicked() {
        
        defer {
            self.cardsClicked = (nil, nil)
        }
        
        if let card1 = self.cardsClicked.card1, let card2 = self.cardsClicked.card2, card1 == card2.reletedTo {
            self.cardsRightAwnser[card1] = true
            self.cardsRightAwnser[card2] = true
        } else {
            self.updateViewCards?(self.cardsClicked.card1, self.cardsClicked.card2)
        }
    }
    
    var timer: Timer?
    var timeCurrent: (initial: Date, final: Date)?
    var model: JogoDaMemoriaScoreModel = JogoDaMemoriaScoreModel()
    
    func startTheGame() {
        Cards.allCases.forEach({ self.cardsRightAwnser[$0] = false })
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerCronometer(_:)), userInfo: nil, repeats: true)
        self.timeCurrent = (Date(), Date())
        self.timer?.fire()
    }
    
    func stopTheGame() {
        self.timer?.invalidate()
    }
    
    @objc
    func updateTimerCronometer(_ timer: Timer) {
        
        if let fireDate = self.timeCurrent?.initial {
            let (minute, second) = self.handlerDate(inicial: fireDate, to: timer.fireDate)
            self.timeCurrent?.final = timer.fireDate
            
            self.updateViewCronometer?(self.scoreFormat(minute, second))
        }
    }
    
    private func handlerDate(inicial: Date, to final: Date) -> (Int, Int) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: inicial, to: final)
        return (components.minute ?? 0, components.second ?? 0)
    }
    
    func checkGameProgress() {
        let numberOfRightAwnser = self.cardsRightAwnser.filter( { $0.value == true})
        if numberOfRightAwnser.count == Cards.allCases.count {
            
            var scoreTimeString: String?
            if let initialDate = self.timeCurrent?.initial,
                let finalDate = self.timeCurrent?.final {
                let (minute, second) = self.handlerDate(inicial: initialDate, to: finalDate)
                scoreTimeString = self.scoreFormat(minute, second)
            }
            
            self.playerDidWin?(scoreTimeString)
            self.stopTheGame()
        }
    }
    
    func selectACard(_ card: Cards) {

        if let _ = self.cardsClicked.card1 {
            self.cardsClicked.card2 = card
            self.checkinBothCardsClicked()
            self.checkGameProgress()
        } else {
            self.cardsClicked.card1 = card
        }
    }
    
    func saveNewScoreWithPlayer(name: String) {
        if let initialDate = self.timeCurrent?.initial, let finalDate = self.timeCurrent?.final {
            let (minute, second) = self.handlerDate(inicial: initialDate, to: finalDate)
            self.model.saveNewScore(player: name, dateScore: finalDate, minute: minute, second: second)
        }
    }
    
    func firstThreePlacesScore() -> [(String,String)] {

        var scoreArray: [(String,String)] = []
        for score in self.model.fetchfirstThreePlacesScore() {
            scoreArray.append((score.player ?? "", self.scoreFormat(Int(score.minute), Int(score.second))))
        }
        return scoreArray
    }
    
}
