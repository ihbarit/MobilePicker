//
//  ContentView.swift
//  MobilePicker
//
//  Created by MCNMACBOOK01 on 16/03/23.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var isPlacementButtonsEnabled = false
    @State private var selectedModel : String?
    @State private var modelConfirmedForPlacement : String?
    
    var models : [String] = {
        let manager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? manager.contentsOfDirectory(atPath: path) else{return[]}
        
        var avialableModels : [String] = []
        for fileName in files where fileName.hasSuffix("usdz"){
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            avialableModels.append(modelName)
        }
        return avialableModels
        
    }()
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedForPlacemnet: $modelConfirmedForPlacement)
            if self.isPlacementButtonsEnabled{
                PlacementButtonsViews(isPlacementButtonsEnabled: $isPlacementButtonsEnabled, selectedModel: $selectedModel, modelConfirmedForPlacemnet: $modelConfirmedForPlacement)
            }else{
                ModelPickerView(models: self.models, isPlacementButtonsEnabled: $isPlacementButtonsEnabled, selectedModel: $selectedModel)
            }
            
        }
    }
}

struct PlacementButtonsViews : View{
    @Binding var isPlacementButtonsEnabled : Bool
    @Binding var selectedModel : String?
    @Binding var modelConfirmedForPlacemnet : String?
    var body: some View{
        HStack{
            Button(action: {
                print("Debug cancel model placement")
                self.isPlacementButtonsEnabled = false
                self.selectedModel = nil
            }){
                Image(systemName: "xmark")
                    .font(.title)
                    .background(Color.white)
                    .padding(20)
                
            }
            
            Button(action: {
                print("Debug cancel model placement")
                self.isPlacementButtonsEnabled = false
                self.modelConfirmedForPlacemnet = selectedModel
                self.selectedModel = nil
            }){
                Image(systemName: "checkmark")
                    .font(.title)
                    .background(Color.white)
                    .padding(20)
                
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var modelConfirmedForPlacemnet : String?
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let modelNamed = self.modelConfirmedForPlacemnet{
            let fileName = modelNamed + ".usdz"
            let modelEntity = (try? ModelEntity.loadModel(named: fileName))!
            let anchorEntity = AnchorEntity(plane: .any)
            anchorEntity.addChild(modelEntity)
            uiView.scene.addAnchor(anchorEntity)
            DispatchQueue.main.async {
                self.modelConfirmedForPlacemnet = nil
            }
        }
    }
    
}

struct ModelPickerView : View{
    var models : [String] = []
    @Binding var isPlacementButtonsEnabled : Bool
    @Binding var selectedModel : String?
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30){
                ForEach(0..<self.models.count){index in
                    Button(action: {
                        self.isPlacementButtonsEnabled = true
                        self.selectedModel = self.models[index]
                    }){
                        Image(self.models[index])
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                    }
                    
                }
                .cornerRadius(20)
            }
        }
        .padding(20)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
