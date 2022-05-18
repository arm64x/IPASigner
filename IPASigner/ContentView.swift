//
//  ContentView.swift
//  IPASigner
//
//  Created by SWING on 2522/5/18.
//

import SwiftUI

struct ContentView: View {

    @State private var ipaURL: String = ""
    @State private var appID: String = ""
    @State private var appDisplayName: String = ""
    @State private var appVersion: String = ""
    @State private var appShortVersion: String = ""
    
    @State private var ignorePluglnsfolder = false

    var window = NSScreen.main?.visibleFrame
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            HStack {
                Text("IPA File：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                        "File path or URL accepted",
                        text: $ipaURL
                    )
                
                Button {
                    
                } label: {
                    Text("导入")
                }
                .frame(width: 80, height: 30, alignment: .center)

            }
            
            
            HStack {
                Text("Signing Certificate：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
            }
            
            HStack {
                Text("Provisioning Profile：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
            }

            HStack {
                Text("App Display Name：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                        "This changes the app title on the home screen",
                        text: $appDisplayName
                    )
            }

            
            HStack {
                Text("App ID：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                        "This changes the app version number",
                        text: $appID
                    )
            }

            
            HStack {
                Text("App Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                        "This changes the app version number",
                        text: $appVersion
                    )
                
                Toggle(isOn: $ignorePluglnsfolder) {
                        Text("Ignore Pluglns folder")
                    }
                
            }
            
            HStack {
                Text("App Short Version：")
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .frame(width: 140, height: 25, alignment: .topTrailing)
                    .offset(x: 0, y: 5)
                
                TextField(
                        "This changes the app short version number",
                        text: $appShortVersion
                    )
                
                Toggle(isOn: $ignorePluglnsfolder) {
                        Text("Ignore Watch")
                    }
                
            }

        }
        .frame(width:750, height: 400, alignment: .top)
    }
    
    func validate(name: String) {
        
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
