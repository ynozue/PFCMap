import SwiftUI

@MainActor
struct TutorialPage: View {
    @Environment(\.factory) private var factory
    @Binding var isTutorialCompleted: Bool
    @State private var model: TutorialPageModel
    @State private var selectedTab = 0
    
    init(factory: Factory, isTutorialCompleted: Binding<Bool>) {
        self._isTutorialCompleted = isTutorialCompleted
        self._model = State(wrappedValue: factory.makeTutorialPageModel())
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TutorialStep1View(selectedTab: $selectedTab)
                .tag(0)
            
            TutorialStep2View(model: model, selectedTab: $selectedTab)
                .tag(1)
            
            TutorialStep3View(model: model, isTutorialCompleted: $isTutorialCompleted)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color(.systemGroupedBackground))
        .onAppear {
            Task {
                await model.onAppear()
            }
        }
    }
}

@MainActor
private struct TutorialStep1View: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "map.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("PFCMapへようこそ！")
                .font(.title)
                .fontWeight(.bold)
            
            Text("このアプリでは、周辺の飲食店を検索し、高タンパク・低脂質なメニューを見つけることができます。マクロバランスを意識した食事選びをサポートします。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    selectedTab = 1
                }
            }) {
                Text("次へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 50)
        }
    }
}

@MainActor
private struct TutorialStep2View: View {
    var model: TutorialPageModel
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("検索対象のお店の選択")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            Text("よく利用するお店や、検索したいお店にチェックを入れてください。設定は後からでも変更可能です。")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if model.isFetchingShops {
                Spacer()
                ProgressView("お店情報を読み込み中...")
                Spacer()
            } else {
                List {
                    ForEach(model.shops, id: \.id) { shop in
                        Button(action: {
                            model.toggleShop(shop)
                        }) {
                            HStack {
                                Text(shop.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if !model.disabledShopIds.contains(shop.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            Button(action: {
                Task {
                    await model.saveDisabledShops()
                    withAnimation {
                        selectedTab = 2
                    }
                }
            }) {
                Text("次へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 50)
        }
    }
}

@MainActor
private struct TutorialStep3View: View {
    var model: TutorialPageModel
    @Binding var isTutorialCompleted: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "location.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("位置情報の利用")
                .font(.title)
                .fontWeight(.bold)
            
            Text("現在地の周辺にあるお店を検索するため、位置情報の利用を許可してください。")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            Button(action: {
                Task {
                    await model.requestLocationPermission()
                }
            }) {
                Text("位置情報を許可する")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await model.completeTutorial(isTutorialCompleted: $isTutorialCompleted)
                }
            }) {
                Text("はじめる")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            
            Spacer().frame(height: 50)
        }
    }
}

#Preview {
    let factory = Factory.create(env: .preview)
    return TutorialPage(factory: factory, isTutorialCompleted: .constant(false))
        .environment(\.factory, factory)
}
