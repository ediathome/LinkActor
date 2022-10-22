//
//  PreferencesWindow.swift
//  LinkActor
//
//  Created by Martin Kolb on 19.10.22.
//

import Foundation
import SwiftUI

struct SettingsView: View {

    @AppStorage("linkAceURL", store: .standard) var linkAceURL: String = ""
    @AppStorage("linkAceApiKey", store: .standard) var linkAceApiKey: String = ""

    var body: some View {
        VStack {
            HStack {
                Label("Server", systemImage: "cloud.fill")
                    .padding(8)
                    .frame(minWidth: 200, alignment: .trailing)
                TextField("Enter LinkAce URL...", text: $linkAceURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                    .frame(minWidth: 200, alignment: .leading)
            }
            HStack {
                Label("LinkAce API key", systemImage: "cloud.fill")
                    .padding(8)
                    .frame(minWidth: 200, alignment: .trailing)
                SecureField("Enter password...", text: $linkAceApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                    .frame(minWidth: 200, alignment: .leading)
            }
            
        }
        .padding(16)
        .frame(width: 960, height: 360, alignment: .topLeading)
    }
}

