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
    @State var repeatEvery = Repeat(weeks: UserDefaults.standard.integer(forKey: "repeatEvery"))
    @State var justSuppers = UserDefaults.standard.bool(forKey: "justSuppers")
    @State var editMode = EditMode.inactive
    var editing: Bool { editMode == .active }
    
    var filteredDays: [Day] {
        days.filter { day in
            day.date ?? .distantPast >= Date.now.startOfDay
        }.sorted { one, two in
            one.date ?? .now < two.date ?? .now
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredDays) { day in
                    if justSuppers {
                        PlanRow(day: day, meal: .supper, editing: editing, justSuppers: justSuppers)
                    } else {
                        Section {
                            PlanRow(day: day, meal: .lunch, editing: editing, justSuppers: justSuppers)
                            PlanRow(day: day, meal: .supper, editing: editing, justSuppers: justSuppers)
                        } header: {
                            Text(day.date?.formattedApple() ?? "")
                        }
                        .headerProminence(.increased)
                    }
                }
            }
            .navigationTitle("Meal Plan")
            .onAppear(perform: updateDays)
            .onChange(of: repeatEvery, perform: updateRepeatEvery)
            .onChange(of: justSuppers, perform: updateJustSuppers)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if filteredDays.reduce(false) { $0 || $1.lunch != nil || $1.supper != nil } {
                        EditButton(editMode: $editMode)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Toggle("Plan suppers only", isOn: $justSuppers.animation())
                        
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
                try? context.save()
            }
        }
    }
}
