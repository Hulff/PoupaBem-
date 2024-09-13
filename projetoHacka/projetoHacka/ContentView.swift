//
//  ContentView.swift
//  projetoHacka
//
//  Created by Turma21-02 on 06/09/24.
//

import SwiftUI
import Charts
//main
struct ContentView: View {
    @StateObject  var data = PostsViewModel()
    @State var isShowing = false
    var body: some View {
        ZStack {
            if isShowing {
                TabView {
                    Home(data: data).tabItem {Label("Home", systemImage: "house").foregroundColor(.green)}
                    Estatisticas(data: data).tabItem {Label("Estatísticas", systemImage: "chart.xyaxis.line")}
                    GuiaInvestimentos(data: data).tabItem {Label("Guia", systemImage: "questionmark")}
                    perfil(data: data).tabItem {Label("Perfil", systemImage: "person")}
                    historico(data: data).tabItem {Label("Histórico", systemImage: "dollarsign")}
                }.accentColor(.figmaGreen)
            } else {
                VStack {
                    //nossa logo
                    Image(.logo).resizable().scaledToFit().frame(width: 150).clipShape(Circle())
                    HStack {
                        Text("Poupa Bem").font(.headline)
                    }.padding()
                    //botao para entrar no app
                    Button ("Entrar") {
                        isShowing.toggle()
                    }.foregroundStyle(.white).padding(.vertical,10).padding(.horizontal,50) .background(Color(.figmaGreen)).cornerRadius(8).fontWeight(.bold).offset(y:150)
                }
            }
        }
    }
}
//home
struct Home:View {
    @ObservedObject  var data : PostsViewModel
    @State var pos:Double = -300
    var body: some View {
            VStack {
                if data.user != nil{
                    VStack {
                        Header(text:"Bem vindo \n\(data.user!.name.capitalized)")
                    }.onAppear {
                        pos = 0
                    }.offset(y:pos).animation(.bouncy(duration: 0.5),value: pos)
                    ScrollView {
                      moveRecents(data: data)
                    } .offset(y:-30)
                    Spacer()
                } else {
                    Loader()
                }
                
            }.onAppear {
                Task {
                    data.fetchUser()
                }
                
            }
        }
}
//perfil
struct perfil: View {
    @ObservedObject  var data : PostsViewModel
    @State var pos:Double = -300
    var body: some View {
        VStack {
            if data.user != nil{
                VStack {
                    Header(text:"Olá \(data.user!.name)")
                }.onAppear {
                    pos = 0
                }.offset(y:pos).animation(.bouncy(duration: 0.5),value: pos)
                ZStack{
                    VStack{
                        ScrollView {
                            Image(.logo)
                                .resizable()
                                .frame(width:150,height: 150 )
                                .cornerRadius(300)
                                .padding(50)
                            Text("Nome: \(data.user!.name)")
                                .bold()
                                .font(.title)
                            HStack {
                                Spacer()
                                VStack {
                                    Text("Meta de gastos: \(String(format: "%.2f",data.user!.metaGastos))")
                                        .font(.subheadline)
                                    Text("Gastos totais: \(String(format: "%.2f",data.user!.gastosTotais))")
                                        .font(.subheadline)
                                }
                                Spacer()
                            }
                            
                            Spacer()
                        }.padding().frame(width: 300 , height: 400 )
                            .background()
                            .cornerRadius(20)
                    }.shadow(radius: 10).offset(y:-30)
                    
                }
            } else {
                Loader()
            }
        }.onAppear {
            Task {
                data.fetchUser()
            }
            
        }
    }
}
//Historico
func convertAndFormatDate(dateString: String, inputFormat: String = "yyyy-MM-dd HH:mm:ss Z", outputFormat: String = "dd/MM/yyyy") -> String? {
    let dateFormatter = DateFormatter()
    
    // Configura o formato de entrada e converte para Date
    dateFormatter.dateFormat = inputFormat
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Ajusta o fuso horário para GMT
    
    guard let date = dateFormatter.date(from: dateString) else {
        return nil // Retorna nil se a conversão falhar
    }
    
    // Configura o formato de saída e converte Date para string
    dateFormatter.dateFormat = outputFormat
    return dateFormatter.string(from: date)
}
struct historico:View {
    @ObservedObject  var data : PostsViewModel
    @State var pos:Double = -300
    var meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio","Junho","Julho"]
    var anos = ["2020", "2021", "2022", "2023", "2024"]
    @State var mesSelecionado = "Mês"
    @State var anoSelecionado = "Ano"
    var body: some View {
        VStack {
            if data.user != nil{
                VStack {
                    Header(text:"Bem vindo \n\(data.user!.name.capitalized)")
                }.onAppear {
                    pos = 0
                }.offset(y:pos).animation(.bouncy(duration: 0.5),value: pos)
                VStack {
                    Text("Movimentações recentes").foregroundColor(.black).font(.title).bold().padding()
                        HStack {
                            Spacer()
                            Menu(mesSelecionado) {
                                ForEach(meses, id: \.self) {auxMes in
                                    Button(action: {
                                        mesSelecionado = auxMes
                                    }, label: {
                                        Text(auxMes)
                                    })
                                }
                            }.frame(width: 90, height: 50)
                                .foregroundStyle(Color.darkGrey).font(.headline).bold()
                            Menu(anoSelecionado) {
                                ForEach(anos, id: \.self) {auxAno in
                                    Button(action: {
                                        anoSelecionado = auxAno
                                    }, label: {
                                        Text(auxAno)
                                    })
                                }
                            }.frame(width: 90, height: 50)
                                .foregroundStyle(Color.darkGrey).font(.headline).bold()
                            Spacer()
                        }.frame(width: 200).background(.figmaGray).cornerRadius(25).padding()
                    VStack {
                        ScrollView {
                            VStack {
                                ForEach(data.user!.movimentacoes, id: \.self) {gasto in
                                    HStack {
                                        Spacer()
                                        Image(systemName: "plus.circle").colorInvert().colorMultiply(gasto.value > 0 ? .figmaGreen : .red)
                                        VStack(alignment: .leading) {
                                            Text(gasto.name).font(.title2).bold()
                                            Text(gasto.type).font(.caption).bold()
                                            Text("\(String(describing: convertAndFormatDate(dateString:gasto.created_at)!))").font(.caption2)
                                        }
                                        Spacer()
                                        Text("R$" + String(format: "%.2f", (gasto.value >= 0 ? gasto.value: abs(gasto.value)))).foregroundColor(gasto.value >= 0 ? .green: .red)
                                        Spacer()
                                    }.frame(width: .infinity,height: 80).background().cornerRadius(10.0).shadow(radius: 1).padding()
                                    Spacer()
                                }
                            }
                        }

                    }
                }.frame(width: 300).padding(.vertical,20).background(.white).cornerRadius(15).padding().shadow(radius: 5).offset(y:-30)
                Spacer()
            } else {
                Loader()
            }
            
        }.onAppear {
            Task {
                data.fetchUser()
            }
            
        }
    }
}
//movimentacoes recentes
struct moveRecents:View {
    @ObservedObject  var data : PostsViewModel
    @State private var isSheetPresented = false
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Spacer()
                        Text("Saldo").font(.title).foregroundColor(.darkGrey).bold()
                        HStack {
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).frame(width: 5, height: 30).foregroundColor(.figmaGreen)
                            Text("R$\(String(format: "%.2f",data.user!.saldo))").font(.title3)
                        }
                        Text("Movimentações recentes").font(.title2).bold().foregroundColor(.darkGrey)
                        Spacer()
                    }
                    Spacer()
                    Button(action: {
                        isSheetPresented = true
                    }) {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width:20,height: 17)
                            .foregroundColor(.darkGrey)
                    }
                    .sheet(isPresented: $isSheetPresented) {
                        SheetContentView(data: data)
                    }
                    Spacer()
                }
                VStack {
                    ForEach(data.user!.movimentacoes, id: \.self) { e in
                        HStack {
                            Image(systemName: "plus.circle").colorInvert().colorMultiply(e.value > 0 ? .figmaGreen : .red)
                            Text("R$\(String(format: "%.2f", abs(e.value)))").font(.title3).bold().foregroundColor(e.value > 0 ? .figmaGreen : .red)
                            Spacer()

                        }
                    }
                }.padding(.horizontal,30)
            }
        }.padding(.vertical,20).background(.white).cornerRadius(15).padding().shadow(radius: 5)
        VStack {
            VStack(alignment: .leading) {
                Text("Movimentações").font(.title2).bold().foregroundColor(.darkGrey)
                    .padding(.horizontal, 37)
                    .padding(.vertical, 10)
                
                VStack {
                    Chart(data.user!.movimentacoes, id: \.created_at) { gasto in
                                BarMark(
                                    x: .value("Category", "\(convertAndFormatDate(dateString:gasto.created_at)!)"),
                                    y: .value("Value", gasto.value)
                                )
                            }
                }.frame(height: 250).background()
                    .padding()
            }
        }.padding(.vertical,20).background(.white).cornerRadius(15).padding().shadow(radius: 5)
    }
}
// Estatisticas
struct Estatisticas: View {
    @ObservedObject  var data : PostsViewModel
    @State var pos:Double = -300
    var body: some View {
        VStack {
            if data.user != nil{
                VStack {
                    Header(text:"Estatísticas")
                }.onAppear {
                    pos = 0
                }.offset(y:pos).animation(.bouncy(duration: 0.5),value: pos)
                ZStack{
                    ScrollView {
                        VStack{
                            Text("Gastos totais:\n R$ \(String(format: "%.2f",data.user!.gastosTotais))").font(.system(size: 20)).bold()
                                .foregroundColor(.black)
                                .padding()
                                .multilineTextAlignment(.center)
                            VStack{
                                Chart(data.user!.estatisticas,id: \.categoria){ e in
                                    SectorMark(
                                        angle: .value("saldo",e.value),
                                        innerRadius: .ratio(0.5)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("",e.categoria))
                                }
                                .padding()
                            }.frame(height: 200 )
                            
                            VStack{
                                ProgressView("", value: data.user!.gastosTotais, total: data.user!.metaGastos)
                                    .scaleEffect(x:1, y:4)
                                    .accentColor(.figmaGreen)
                                    .frame(width: 300)
                                Spacer()
                                Text("Controle de gastos: \(String(format: "%.0f",(data.user!.gastosTotais/data.user!.metaGastos)*100))%")
                                    .padding(10)
                            }.frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        }
                    }.frame(width: 350 , height: 400 )
                        .background()
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .offset(y:-30)
                    
    }
            } else {
                Loader()
            }
        }.onAppear {
            Task {
                data.fetchUser()
            }
            
        }
    }
}
// Guida Investimentos
struct guiaSheet: Hashable{
    var name:String
    var text:String
}
struct GuiaInvestimentos: View {
    @ObservedObject  var data : PostsViewModel
    @State private var isSheetPresented = false
    @State var sheetText = ""
    @State var pos:Double = -300
    @State var guias:[guiaSheet] = [
        guiaSheet(name: "Como Economizar", text: "Economizar dinheiro é uma habilidade valiosa que pode ajudar a alcançar seus objetivos financeiros e proporcionar uma maior segurança. Aqui estão algumas dicas práticas para economizar dinheiro \n \("1. Crie um Orçamento") \n Avalie Seus Gastos: Liste todas as suas despesas mensais para entender onde seu dinheiro está indo. Defina Limites: Estabeleça limites de gasto para diferentes categorias, como alimentação, transporte e lazer. \n 2. Pague-se Primeiro \n Economize Antes de Gastar: Configure uma transferência automática para uma conta de poupança logo após receber seu salário. Trate isso como uma despesa fixa. \n 3. Corte Despesas Desnecessárias \n Analise Assinaturas e Serviços: Cancele assinaturas de serviços que você não usa com frequência. \n Reduza o Desperdício: Evite comprar itens desnecessários e minimize o desperdício de alimentos. \n 4. Compare Preços \n Pesquise Antes de Comprar: Use comparadores de preços e leia resenhas para garantir que você está obtendo o melhor negócio. \n Aproveite Ofertas e Cupons: Procure por cupons e ofertas especiais antes de fazer uma compra."),
        guiaSheet(name: "Controlar Sustos Essenciais", text: ""),
        guiaSheet(name: "Metas de Economia", text: ""),
        guiaSheet(name: "Como ser menos consumista?", text: ""),
        guiaSheet(name: "Como Investir", text: ""),
    ]
    var body: some View {
        VStack {
            if data.user != nil{
                VStack {
                    Header(text:"Guia de Investimentos")
                }.onAppear {
                    pos = 0
                }.offset(y:pos).animation(.bouncy(duration: 0.5),value: pos)
                VStack{
                    VStack{
                        ScrollView {
                            ForEach (guias,id: \.self) { e in
                                Button(action: {
                                    sheetText = e.text
                                    isSheetPresented.toggle()
                                }) {
                                    Text(e.name)
                                        .font(.headline)
                                        .foregroundColor(.black).bold()
                                        .frame(width: 200)
                                        .padding()
                                        .background(.figmaGray)
                                        .cornerRadius(8)
                                        .padding(.vertical,10)
                                        
                                       
                                }
                            }
                        }
                    }.frame(width: 300).padding(.vertical,4).background().cornerRadius(20)
                }.shadow(radius: 10).offset(y:-30)
            } else {
                Loader()
            }
        }.onAppear {
            Task {
                data.fetchUser()
            }

        }.sheet(isPresented:$isSheetPresented) {
            SheetView(isSheetPresented: $isSheetPresented, text: $sheetText)
        }
    }
}
struct SheetView: View {
    @Binding var isSheetPresented: Bool
    @Binding var text:String
    var body: some View {
        ScrollView{
            Text(text).padding()
        }
        HStack {
            Spacer()
            Button ("Voltar") {
                isSheetPresented.toggle()
            }.padding().bold()
            Spacer()
        }
    }
}
// sheet view
struct FirstSheetView: View {
    var body: some View {
        ScrollView{
            ZStack{
                HStack{
                    Spacer()
                    Rectangle()
                        .foregroundColor(.figmaGreen)
                        .frame(width: 3)
                    
                }.padding(1.3)
                VStack (alignment: .leading){
                    Text("Economizar dinheiro é uma habilidade valiosa que pode ajudar a alcançar seus objetivos financeiros e proporcionar uma maior segurança. Aqui estão algumas dicas práticas para economizar dinheiro")
                        .font(.system(size:20))
                        .padding()
                    Text("1. Crie um Orçamento")
                        .font(.system(size: 15))
                        .bold()
                    Text("Avalie Seus Gastos: Liste todas as suas despesas mensais para entender onde seu dinheiro está indo.")
                    Text("Defina Limites: Estabeleça limites de gasto para diferentes categorias, como alimentação, transporte e lazer.")
                    Text("2. Pague-se Primeiro")
                        .font(.system(size: 15))
                        .bold()
                    Text("Economize Antes de Gastar: Configure uma transferência automática para uma conta de poupança logo após receber seu salário. Trate isso como uma despesa fixa.")
                    Text("3. Corte Despesas Desnecessárias")
                        .font(.system(size: 15))
                        .bold()
                    Text("Analise Assinaturas e Serviços: Cancele assinaturas de serviços que você não usa com frequência.")
                    Text("Reduza o Desperdício: Evite comprar itens desnecessários e minimize o desperdício de alimentos.")
                    Text("4. Compare Preços")
                        .font(.system(size: 15))
                        .bold()
                    Text("Pesquise Antes de Comprar: Use comparadores de preços e leia resenhas para garantir que você está obtendo o melhor negócio.")
                    Text("Aproveite Ofertas e Cupons: Procure por cupons e ofertas especiais antes de fazer uma compra.")
                }.padding()
            }
        }
    }
}
// view header mostra o texto que foi passado à ela
struct Header: View {
    @State var text:String
    var body: some View {
        ZStack {
            Color(.figmaGreen)
                HStack {
                    Text(text).font(.title).foregroundStyle(.white).bold().padding(.top,15)
                    Spacer()
                }.padding(.horizontal,30)
        }.frame(height: 200).cornerRadius(25).offset(y:-50)
    }
}
// spinner para loading
struct Loader: View {
    @State private var angle:Double = 0.0
    var body: some View {
        Circle()
            .trim(from: 0.1,to: 1.0)
            .stroke(style: StrokeStyle(lineWidth: 8,lineCap: .round,lineJoin: .round))
            .foregroundStyle(Color(.figmaGreen))
            .rotationEffect(Angle(degrees: angle))
            .onAppear{
                withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }.frame(width: 70)
    }
}
//adicionar gastos sheet
struct SheetContentView: View {
    @ObservedObject  var data : PostsViewModel
    @State private var inputText: String = ""
    @State private var name: String = ""
    @State private var category: String = ""
    @State private var isExpense: Bool = true

    
    let rows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [",", "0", "⌫"]
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        isExpense = true
                    }) {
                        Text("Gasto")
                            .font(.headline)
                            .frame(width: 100, height: 40)
                            .background(isExpense ? Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isExpense = false
                    }) {
                        Text("Ganho")
                            .font(.headline)
                            .frame(width: 100, height: 40)
                            .background(!isExpense ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Nome")
                        .font(.headline)
                        .foregroundColor(.figmaGreen)
                    TextField("Digite o nome", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                }
                
                VStack(alignment: .leading) {
                    Text("Categoria")
                        .font(.headline)
                        .foregroundColor(.figmaGreen)
                    TextField("Digite a categoria", text: $category)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                }
                
                VStack(alignment: .leading) {
                    Text("Valor")
                        .foregroundColor(.figmaGreen)
                        .font(.headline)
                    Text("R$ \(inputText)")
                        .multilineTextAlignment(.center)
                        .frame(width: 150, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                VStack(spacing: 8) {
                    ForEach(rows, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { key in
                                Button(action: {
                                    handleKeyPress(key)
                                }) {
                                    Text(key)
                                        .font(.title2)
                                        .frame(width: 60, height: 60)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    var formattedInputText = inputText.replacingOccurrences(of: ",", with: ".")
                    guard var value = Double(formattedInputText) else { return }
                    var adjustedValue = isExpense ? -value : value
                    var newGasto = Gastos(value: adjustedValue, icon: "defaultIcon", type: "none", name: "new", created_at: "\(Date())")
                    Task {
                        data.newGasto(value: adjustedValue, icon: "default", type: "none", name: "new gasto")
                    }
                }) {
                    Text("Adicionar")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 150, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.top, 16)
                }
            }
            .padding()
        }
    }
    
    func handleKeyPress(_ key: String) {
        switch key {
        case "⌫":
            if !inputText.isEmpty {
                inputText.removeLast()
            }
        case ",":
            if !inputText.contains(",") {
                inputText.append(",")
            }
        default:
            inputText.append(key)
        }
    }
}

#Preview {
    ContentView()
}

// exemplo de uso da fetch view
//            Button ("add gasto"){
//                Task {
//                    data.newGasto(value: 60, icon: "food", type: "alimento", name: "cafe da tarde")
//                }
//            }
