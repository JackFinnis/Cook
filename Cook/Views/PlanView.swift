//
//  PlanView.swift
//  Cook
//
//  Created by Jack Finnis on 26/09/2022.
//

import SwiftUI
import CoreData

struct PlanView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var days: FetchedResults<Day>
    @State var editMode = EditMode.inactive
    
    @Binding var justSuppers: Bool
    @Binding var repeatEvery: Repeat
    let filteredDays: [Day]
    
    var nextDayToPlan: Day? {
        for day in filteredDays where day.supper == nil {
            return day
        }
        return nil
    }
    
    var empty: Bool {
        filteredDays.reduce(true) { $0 && (justSuppers ? true : $1.lunch == nil) && $1.supper == nil }
    }
    var complete: Bool {
        filteredDays.reduce(true) { $0 && (justSuppers ? true : $1.lunch != nil) && $1.supper != nil }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredDays) { day in
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
                Section {} footer: {
                    if complete {
                        Text("🎉 Your week is planned!")
                            .horizontallyCentred()
                    }
                }
            }
            .navigationTitle("Meal Plan")
            .onAppear(perform: updateDays)
            .onChange(of: repeatEvery, perform: updateRepeatEvery)
            .onChange(of: justSuppers, perform: updateJustSuppers)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !empty {
                        EditButton(editMode: $editMode)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !editMode.isEditing {
                        Menu {
                            Toggle("Only plan suppers", isOn: $justSuppers.animation())
                            
                            Picker("Repeat Every", selection: $repeatEvery) {
                                let none = Repeat(weeks: 0)
                                Text(none.name)
                                    .tag(none)
                                
                                ForEach(1...4, id: \.self) { weeks in
                                    let repeatEvery = Repeat(weeks: weeks)
                                    Text(repeatEvery.name)
                                        .tag(repeatEvery)
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
    
    func updateJustSuppers(_ newJustSuppers: Bool) {
        UserDefaults.standard.set(justSuppers, forKey: "justSuppers")
    }
    
    func updateRepeatEvery(_ newRepeatEvery: Repeat) {
        UserDefaults.standard.set(newRepeatEvery.weeks, forKey: "repeatEvery")
    }
    
    func updateDays() {
        for i in 0...6 {
            let date = Date.now.addingTimeInterval(Double(i)*24*3600).startOfDay
            if !days.contains(where: { $0.date == date }) {
                let day = Day(context: context)
                day.date = date
                if let previousDay = days.first(where: { $0.date?.addingTimeInterval(repeatEvery.interval) == date }) {
                    day.lunch = previousDay.lunch
                    day.supper = previousDay.supper
                }
            }
        }
        try? context.save()
        context.refreshAllObjects()
    }
}
