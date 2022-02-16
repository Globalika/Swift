import SwiftUI

struct ContentView: View {
    @State private var isPresented = false
    @State private var chosenModel: DetailsModel?
    let models = DetailsModel.models

    var body: some View {
        VStack {
            ForEach(models, id: \.self) { model in
                Text("\(model.title ?? "- - - -")")
                .padding()
                .onTapGesture {
                    self.chosenModel = model
                    isPresented.toggle()
                }
            }
        }
        .fullScreenCoverBackport(isPresented: $isPresented) {
            DetailsView(model: $chosenModel)
        }
    }
}
extension View {
    func fullScreenCoverBackport<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) -> some View {
            ModifiedContent(content: self, modifier: ModalContainerModifier(isPresented: isPresented, addition: content()))
    }
}

struct ModalContainerModifier<Addition: View>: ViewModifier {
    @Binding var isPresented: Bool
    var addition: Addition
    
    func body(content: Content) -> some View {
        content
        .background( ZStack {
            if isPresented {
                ModalContainer(content: addition)
            }
        })
    }
}

struct ModalContainer<Content: View>: UIViewControllerRepresentable {
    let content: Content
    func makeUIViewController(context: UIViewControllerRepresentableContext<ModalContainer>) -> UIViewController {
        let proxyController = ViewController()
        
        proxyController.child = UIHostingController(rootView: content)
        //proxyController.isModalInPresentation = true
        return proxyController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // nothing is needed here
    }

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        print("DISMANTLE")
        (uiViewController as! ViewController).child?.dismiss(animated: true, completion: nil)
    }
    
    private class ViewController: UIViewController {
        var child: UIHostingController<Content>?
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
//            if let child = self.presentedViewController {
//                print("\(111)")
//                child.removeFromParent()
//            }
            child?.modalPresentationStyle = .overCurrentContext
            child?.view.backgroundColor = .blue
            
            child?.definesPresentationContext = true
            //child?.isModalInPresentation = true
            
            if let child = child {
                self.present(child, animated: true, completion: nil)
            }
        }
        override func viewWillDisappear(_ animated: Bool) {
            print("view will disappear")
            dismantleUIViewController(self, coordinator: ())
            //parent?.dismiss(animated: false, completion: {})
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
                DetailsModel(sections: ["11---","12---","13---",
                                        "14---","15---","16---","17---",
                                        "18---","19---","20---","21---",
                                        "22---","23---","24---","25---",
                                        "26---","27---","28---","29---"]),
                DetailsModel(title: "fff4")]
    }()
}

struct DetailsView: View {
    @State private var viewContentSize: CGSize = .zero
    @GestureState private var translation: CGFloat = .zero
    let maxHeight: CGFloat = BottomSheetConstants.maxHeight

    @Environment(\.presentationMode) var presentation
    @Binding var model: DetailsModel?
    
    var body: some View {
        GeometryReader { geometry in
        VStack {
            title
            sections
        }
        .bindSize(to: $viewContentSize)
        .frame(width: geometry.size.width,
               height: min(viewContentSize.height, maxHeight),
               alignment: .top)
        .background(Color(.red))//secondarySystemBackground
        .frame(height: geometry.size.height, alignment: .bottom)
        .offset(y: max(translation, 0))
        .gesture(DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.height
        }.onEnded { value in
            let snapDistance = min(viewContentSize.height, maxHeight) * BottomSheetConstants.snapRatio
            guard abs(value.translation.height) > snapDistance else {
                return
            }
            dismiss()
        })
        }
        .onDisappear {
            print(">>> going to disappear")
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
    private func dismiss() {
        //model = nil
        presentation.wrappedValue.dismiss()
    }
}

extension View {
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

private struct BottomSheetConstants {
    static let indicatorHeight: CGFloat = 4
    static let indicatorWidth: CGFloat = 50
    static let snapRatio: CGFloat = 0.7
    static let maxHeight: CGFloat = UIScreen.main.bounds.height / 2
    static let indicatorInsets = EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
    static let indicatorPadding: CGFloat = 14
}
