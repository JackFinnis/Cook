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
    @State var showInfoView = false
    
    @Binding var justSuppers: Bool
    @Binding var repeatEvery: Repeat
    let filteredDays: [Day]
    
    var nextDayToPlan: Day? {
        for day in filteredDays where day.supper == nil || (justSuppers ? false : day.lunch == nil) {
            return day
        }
        return nil
    }
    
    var toPlan: Int {
        filteredDays.reduce(0) { $0 + (justSuppers ? 0 : ($1.lunch == nil ? 1 : 0)) + ($1.supper == nil ? 1 : 0) }
    }
    var empty: Bool {
        toPlan == (justSuppers ? 7 : 14)
    }
    
    var body: some View {
        NavigationView {
            List {
                PlanList(days: filteredDays, editMode: editMode, justSuppers: justSuppers, empty: empty, nextDayToPlan: nextDayToPlan)
            }
            .navigationTitle("Meal Plan")
            .onAppear(perform: updateDays)
            .onChange(of: repeatEvery, perform: updateRepeatEvery)
            .onChange(of: justSuppers, perform: updateJustSuppers)
            .overlay(alignment: .bottom) {
                Text(toPlan == 0 ? "🎉 Your week is planned!" : "\(toPlan.formattedPlural("meal")) to plan")
                    .horizontallyCentred()
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .animation(.none)
                    .padding(10)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !empty {
                        EditButton(editMode: $editMode)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !editMode.isEditing {
                        HStack {
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
                                Image(systemName: "gear")
                            }
                            
                            Button {
                                showInfoView = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showInfoView) {
                InfoView()
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
