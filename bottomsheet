//
//  ContentView.swift
//  testnavigation
//
//  Created by Volodymyr Seredovych on 09.02.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresented = false
    @State private var chosenModel: DetailsModel?
    let models = DetailsModel.models

    var body: some View {
        VStack {
            Spacer()
            ForEach(models, id: \.self) { model in
                Spacer()
                Text("\(model.title ?? "- - - -")")
                .onTapGesture {
                    self.chosenModel = model
                    isPresented = true
                }
            }
            Spacer()
        }
        .allowsHitTesting(!isPresented)
        .bottomSheet(isPresented: $isPresented) {
            DetailsView(model: $chosenModel)
        }
    }
}

struct DetailsModel: Hashable {
    var title: String?
    var sections: [String]?
    static var models: [DetailsModel] = {
        return [DetailsModel(title: "fff1", sections: ["11---","12---","13---",
                                                       "14---","15---","16---","17---",
                                                       "18---","19---","20---","21---",
                                                       "22---","23---","24---","25---",
                                                       "26---","27---","28---","29---"]),
                DetailsModel(title: "fff2", sections: ["21---","22---","23---","24---",
                                                       "25---","26---","27---","28---"]),
                DetailsModel(sections: ["31---"]),
                DetailsModel(title: "fff4")]
    }()
}

struct DetailsView: View {
    @Binding var model: DetailsModel?
    
    var body: some View {
        VStack {
            title
            sections
        }
    }
    
    @ViewBuilder
    var title: some View {
        Text("\(model?.title ?? "_-_-_-_")")
    }
    
    @ViewBuilder
    var sections: some View {
        VStack {
            if let sections = model?.sections {
                ForEach(sections, id: \.self) {
                    Text("\($0)")
                }
            }
        }
    }
}

extension View {
    func bottomSheet<Content: View>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View {
        self.modifier(BottomSheetModifier(isPresented: isPresented, coverContent: content))
    }

    func bindSize(to binding: Binding<CGSize>) -> some View {
        self.background(GeometryReader { proxy in
            self.sizeBindingView(for: binding, proxy: proxy)
        })
    }
}

private extension View {
    func sizeBindingView(for binding: Binding<CGSize>, proxy: GeometryProxy) -> some View {
        changeStateAsync { binding.wrappedValue = proxy.size }
        return Color.clear
    }
    func changeStateAsync(_ action: @escaping () -> Void) {
        DispatchQueue.main.async(execute: action)
    }
}

struct BottomSheetModifier<CoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var coverContentSize: CGSize = .zero
    @GestureState private var translation: CGFloat = .zero
    
    let coverContent: () -> CoverContent
    let maxHeight: CGFloat = BottomSheetConstants.maxHeight
    let indicatorPadding: CGFloat = BottomSheetConstants.indicatorPadding

    private var offset: CGFloat {
        isPresented ? 0 : maxHeight + indicatorPadding
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: .zero)
            .fill(Color.secondary)
            .frame(width: BottomSheetConstants.indicatorWidth,
                   height: BottomSheetConstants.indicatorHeight
        )
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                VStack(spacing: .zero) {
                    indicator.padding(BottomSheetConstants.indicatorInsets)
                    ScrollView(showsIndicators: false) {
                        coverContent().bindSize(to: $coverContentSize)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .frame(width: geometry.size.width,
                       height: min(coverContentSize.height, maxHeight) + indicatorPadding,
                       alignment: .top)
                .background(Color(.secondarySystemBackground))
                .frame(height: geometry.size.height, alignment: .bottom)
                .opacity(isPresented ? 1 : 0)
                .offset(y: max(offset + translation, 0))
                .animation(.interactiveSpring())
                .gesture(DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = min(coverContentSize.height, maxHeight) * BottomSheetConstants.snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isPresented = value.translation.height < 0
                })
            }
        }
    }
}

private struct BottomSheetConstants {
    static let indicatorHeight: CGFloat = 4
    static let indicatorWidth: CGFloat = 50
    static let snapRatio: CGFloat = 0.7
    static let maxHeight: CGFloat = UIScreen.main.bounds.height / 2
    static let indicatorInsets = EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
    static let indicatorPadding: CGFloat = 14
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
