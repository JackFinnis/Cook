//
//  Date.swift
//  Ecommunity
//
//  Created by Jack Finnis on 24/11/2021.
//

import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func formattedApple() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let oneWeekAgo = calendar.startOfDay(for: Date.now.addingTimeInterval(-7*24*3600))
        let oneWeekAfter = calendar.startOfDay(for: Date.now.addingTimeInterval(7*24*3600))
        
        if calendar.isDateInToday(self) || calendar.isDateInYesterday(self) || calendar.isDateInTomorrow(self) {
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .full
            return formatter.string(from: self)
        } else if self > oneWeekAgo && self < oneWeekAfter {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            return self.formatted(date: .numeric, time: .omitted)
        }
    }
}
