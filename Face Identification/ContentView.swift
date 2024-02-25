//
//  ContentView.swift
//  Face Identification
//
//  Created by Daniel Coburn on 2/25/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HostedCameraServiceViewController()
                .ignoresSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
