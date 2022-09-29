//
//  AllDaysView.swift
//  Cook
//
//  Created by Jack Finnis on 29/09/2022.
//

import SwiftUI

struct AllDaysView: View {
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day>
    @State var scrolled = false
    
    let editMode: EditMode
    let justSuppers: Bool
    let empty: Bool
    let nextDayToPlan: Day?
    
    var filteredDays: [Day] {
        days.filter { day in
            day.date ?? .distantFuture < Date.now.startOfDay
        }.sorted { one, two in
            one.date ?? .now < two.date ?? .now
        }
    }
    
    var body: some View {
        ScrollViewReader { list in
            List {
                PlanList(days: filteredDays, editMode: editMode, justSuppers: justSuppers, empty: empty, nextDayToPlan: nextDayToPlan)
            }
            .navigationTitle("Previous Meals")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !scrolled {
                    scrolled = true
                    list.scrollTo(filteredDays.last?.id)
                }
            }
        }
    }
}
