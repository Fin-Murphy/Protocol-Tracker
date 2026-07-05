//
//  TestView.swift
//  ScatterBrainVVD
//

import SwiftUI

struct TestView: View {

    var body: some View {

        VStack{

            HStack{
                Text("Test")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom)
            }.foregroundColor(ForeColor)

            Spacer()

            Text("This is a test view.")
                .foregroundColor(ForeColor)

            Spacer()
        }

    }
}

#Preview {
    TestView()
}
