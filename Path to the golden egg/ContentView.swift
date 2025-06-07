//
//  ContentView.swift
//  Path to the golden egg
//
//  Created by alex on 6/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GViewModel(url: URL(string: "https://pathoglden.top/get/")!)
    
    var body: some View {
        ZStack {
            Color(hex: "#383C59")
                .ignoresSafeArea(.all)
            
            WebView(viewModel: viewModel)
                .opacity(viewModel.state == .completed && !viewModel.isLoadingVisible ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: viewModel.isLoadingVisible)
            
            if viewModel.isLoadingVisible, case .loading(let progress) = viewModel.state {
                LoadingOverlay(progress: progress)
            } else if viewModel.isLoadingVisible, case .failed(let error) = viewModel.state {
                ErrorView(error: error) {
                    viewModel.loadContent()
                }
            } else if viewModel.isLoadingVisible, case .offline = viewModel.state {
                OfflineView {
                    viewModel.loadContent()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoadingVisible)
    }
}

struct LoadingOverlay: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("chicken_eggs")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: min(geo.size.width, geo.size.height) * 0.45,
                            height: min(geo.size.width, geo.size.height) * 0.45
                        )
                    // Прогресс-бар
                    ZStack {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: min(geo.size.width, 240), height: 12)
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: CGFloat(min(geo.size.width, 240)) * progress, height: 12)
                            .animation(.linear(duration: 0.2), value: progress)
                    }
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                // Центрируем по всему экрану
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
    }
}

private struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Ошибка загрузки")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: retryAction) {
                    Text("Повторить")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.yellow)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
            }
        }
    }
}

private struct OfflineView: View {
    let retryAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                
                Text("Нет подключения")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("Проверьте подключение к интернету")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: retryAction) {
                    Text("Повторить")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.yellow)
                        .cornerRadius(25)
                }
                .padding(.top, 20)
            }
        }
    }
}

#Preview {
    ContentView()
}
