import Foundation
import Combine

struct Gastos: Decodable, Hashable, Encodable{
    var value:Double
    var icon:String
    var type:String
    var name:String
    var created_at:String
    
}
struct charts:Decodable,Hashable,Encodable  {
    var categoria:String
    var value:Double
}
struct User: Decodable,Hashable,Encodable {
    var _id:String
    var _rev:String
    var name:String
    var created_at:String
    var saldo:Double
    var metaGastos:Double
    var gastosTotais:Double
    var movimentacoes:[Gastos]
    var estatisticas:[charts]
    
}

class PostsViewModel: ObservableObject {
    @Published var user:User?
    func fetchUser() {
        let task = URLSession.shared.dataTask(with: URL(string: "http://127.0.0.1:1880/user")!) {
            data,_,error in
            
            do {
            let decodedResponse = try JSONDecoder().decode([User].self, from: data!)
                self.user = decodedResponse[0]
                print(self.user!)
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    func post(){
        
        guard let url = URL(string: "http://127.0.0.1:1880/update") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(self.user)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            print("Error encoding to JSON: \(error.localizedDescription)")
        }
        
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error to send resource: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error to send resource: invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Resource POST successfully")
                self.fetchUser()
             
            } else {
                print("Error POST resource: status code \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    func newGasto(value:Double , icon:String , type:String , name:String) {
        
        let newGasto = Gastos(value: value, icon: icon, type: type, name: name,created_at: "\(Date())")
        self.user?.movimentacoes.append(newGasto)
        post()
    }
    func newMetaGastos(value:Double) {
        self.user?.metaGastos = value
        post()
    }
    func newGastosTotais (value:Double) {
        self.user?.gastosTotais = value
        post()
    }

}
