//
//  ContentView.swift
//  FlatMany-Example
//
//  Created by Leif on 5/13/21.
//

import SwiftUI
import Combine

import FlatMany
func absurd<A>(_ never: Never) -> A { }

import DataObject
import SURL

struct ContentView: View {
    @State private var task: AnyCancellable?
    @State private var data: [DataObject] = []
    
    var body: some View {
        guard !data.isEmpty else {
            return AnyView(
                ProgressView()
                    .onAppear {
                        task = Just<[Int]>([Int](1 ... 100))
                            .mapError(absurd)
                            .flatMany { value in
                                "https://jsonplaceholder.typicode.com/todos/\(value)".url!.get()
                                    .map { DataObject($0.0) }
                                    .eraseToAnyPublisher()
                            }
                            .sink(receiveCompletion: { _ in }, receiveValue: {
                                data = $0
                            })
                    }
            )
        }
        
        return AnyView(
            List(data, id: \.self) { value in
                Text(value.description)
            }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
