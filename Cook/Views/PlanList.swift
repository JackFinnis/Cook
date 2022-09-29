//
//  PlanList.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import SwiftUI

struct PlanList: View {
    let days: [Day]
    let editMode: EditMode
    let justSuppers: Bool
    let empty: Bool
    let nextDayToPlan: Day?
    
    var body: some View {
        ForEach(days) { day in
            if justSuppers {
                PlanRow(day: day, meal: .supper, editMode: editMode, justSuppers: justSuppers, empty: empty, nextDayToPlan: nextDayToPlan)
            } else {
                Section {
                    PlanRow(day: day, meal: .lunch, editMode: editMode, justSuppers: justSuppers, empty: empty, nextDayToPlan: nextDayToPlan)
                    PlanRow(day: day, meal: .supper, editMode: editMode, justSuppers: justSuppers, empty: empty, nextDayToPlan: nextDayToPlan)
                } header: {
                    Text(day.date?.formattedApple() ?? "")
                }
                .headerProminence(.increased)
            }
        }
    }
}
