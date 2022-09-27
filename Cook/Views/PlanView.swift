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
    @State var editing = false
    
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
                    Section {
                        PlanRow(day: day, meal: .lunch, editing: editing)
                        PlanRow(day: day, meal: .supper, editing: editing)
                    } header: {
                        Text(day.date?.formattedApple() ?? "")
                    }
                    .headerProminence(.increased)
                }
            }
            .navigationTitle("Meal Plan")
            .onAppear(perform: updateDays)
            .onChange(of: repeatEvery, perform: updateRepeatEvery)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(editing ? "Done" : "Edit") {
                        withAnimation {
                            editing.toggle()
                        }
                    }
                    .font(.body.weight(editing ? .semibold : .regular))
                    .animation(.none, value: editing)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
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
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
        }
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
