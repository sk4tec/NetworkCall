//
//  ContentView.swift
//  NetworkCall
//
//  Created by Sunjay Kalsi on 22/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Let's do a network call")
            if let user {
                VStack(alignment: .leading, spacing: 12) {
                    Text(user.login)
                    Text(user.bio)
                    Image(user.avatarUrl)
                }
            }
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch {
                print("Error \(error)")
            }
        }
    }
    
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/sallen0400"
        guard let url = URL(string: endpoint) else { throw GHError.invalidUrl }

        let (data, response) = try await URLSession.shared.data(from: url) // note the Tuple is of data and response

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData // decoding error, mismatch
        }
    }
}

#Preview {
    ContentView()
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}
