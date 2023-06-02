//
//  ContentView.swift
//  DegreeCalculator
//
//  Created by Eskil Olsen on 5/19/23.
//

import SwiftUI

struct ContentView: View {
    @State var modelData = ModelData()

    var body: some View {
        DegreeCalculator().environmentObject(modelData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
