//
//  ContentView.swift
//  CodaMinaBarCode
//
//  Created by Terry Lou on 2023/9/2.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var qrCodeImage:Image = Image(systemName: "person")
    @State private var barCodeImage:Image = Image(systemName: "person")
    @State var barCodeData = "hello data"
    @State var qrcodeType = CodaMinaBarcodeView.BarcodeType.qrCode
    @State var barcodeType = CodaMinaBarcodeView.BarcodeType.barcode128
    @State var rotate = CodaMinaBarcodeView.Orientation.up
    
    @State var genBarCoded=false
    var body: some View {
        NavigationView{
            ZStack{
                Image("pay_background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                ZStack{
                    Color
                        .white
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    VStack{
                        Divider()
                        if !genBarCoded{
                            CodaMinaBarcodeView(data: $barCodeData,
                                          barcodeType: $qrcodeType,
                                          orientation: $rotate)
                            { image in
                                genBarCoded=true
                                self.qrCodeImage = Image(uiImage: image!)
                            }.frame(width:UIScreen.main.bounds.width * 0.76,height: UIScreen.main.bounds.height * 0.3)
                            CodaMinaBarcodeView(data: $barCodeData,
                                          barcodeType: $barcodeType,
                                          orientation: $rotate)
                            { image in
                                genBarCoded=true
                                self.barCodeImage = Image(uiImage: image!)
                            }.frame(width:UIScreen.main.bounds.width * 0.76,height: UIScreen.main.bounds.height * 0.3)
                        }
                        qrCodeImage.resizable().frame(width:UIScreen.main.bounds.width * 0.76,height: UIScreen.main.bounds.height * 0.3)
                        Spacer()
                        Spacer()
                        Divider()
                        Spacer()
                        Spacer()
                        barCodeImage.resizable().frame(width:UIScreen.main.bounds.width * 0.76,height: UIScreen.main.bounds.height * 0.1)
                    }
                    .padding()
                }
                .frame(width:UIScreen.main.bounds.width * 0.85 , height: UIScreen.main.bounds.height * 0.19)
            }
        }.navigationBarHidden(true)
            .ignoresSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
