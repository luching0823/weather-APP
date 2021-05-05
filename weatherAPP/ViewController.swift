//
//  ViewController.swift
//  weatherAPP
//
//  Created by 廖昱晴 on 2021/5/4.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var PoP: UILabel!
    @IBOutlet weak var minT: UILabel!
    @IBOutlet weak var maxT: UILabel!
    @IBOutlet weak var CI: UILabel!
    @IBOutlet weak var Wx: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    let location = ["臺北市","新北市","基隆市","桃園市","新竹縣","新竹市","苗栗縣","臺中市","南投縣","彰化縣","雲林縣","嘉義縣","嘉義市","臺南市","高雄市","屏東縣","宜蘭縣","花蓮縣","臺東縣","澎湖縣","金門縣","連江縣",]
    var selectLocation = "臺北市"
    var selectTime = 0 // 選取器選擇的時間區間，範圍 0~2
    var timeData = ["","",""] // 讀取 JSON 後，存放三個時間的 startTime
    let locationPickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: 270, height: 150)) // 把地點選取器放入提示框裡，大小要自己嘗試調整
    let timePickerView = UIPickerView(frame: CGRect(x: 0, y: 50, width: 270, height: 150)) // 把時間選取器放入提示框裡，大小要自己嘗試調整
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationPickerView.dataSource = self
        locationPickerView.delegate = self
        timePickerView.dataSource = self
        timePickerView.delegate = self

        loadJSON(locationName: selectLocation, time: selectTime)

    }
    
    // MARK:- 讀 JSON 資料，必須要傳入地點和時間
    func loadJSON(locationName: String ,time: Int) {
        let url =  "https://opendata.cwb.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=CWB-6F803E34-66E5-4135-AC7D-25811AD53D5C&format=JSON&locationName=\(locationName)"
        let newUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // 網址有中文，需要先編碼
        
        var request = URLRequest(url: URL(string: newUrl)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, respond, error) in
            let decoder = JSONDecoder()
            if let data = data, let weather = try? decoder.decode(Weather.self, from: data) {
                print(weather)
                
                DispatchQueue.main.sync {
                    self.locationName.text = weather.records.location[0].locationName
                    self.Wx.text = weather.records.location[0].weatherElement[0].time[0].parameter.parameterName
                    self.PoP.text = weather.records.location[0].weatherElement[1].time[0].parameter.parameterName + "%"
                    self.minT.text = weather.records.location[0].weatherElement[2].time[0].parameter.parameterName + "°" + weather.records.location[0].weatherElement[2].time[0].parameter.parameterUnit!
                    self.CI.text = weather.records.location[0].weatherElement[3].time[0].parameter.parameterName
                    self.maxT.text = weather.records.location[0].weatherElement[4].time[0].parameter.parameterName + "°" + weather.records.location[0].weatherElement[4].time[0].parameter.parameterUnit!
                    self.startTime.text =  "起始：" + weather.records.location[0].weatherElement[0].time[time].startTime
                    self.endTime.text = "結束：" +  weather.records.location[0].weatherElement[0].time[time].endTime
                    
                    for i in 0...2 {
                        self.timeData[i] = weather.records.location[0].weatherElement[0].time[i].startTime
                    } // 把三個 startTime 放入陣列
                    
                    self.changeWeatherIcon() // 根據天氣現象改變圖示
                }
                
            } else {
                print(error.debugDescription)
            }
        }
        task.resume()
    }
    
    // MARK:- 改變 weatherIcon
    
    func changeWeatherIcon() {
        if Wx.text!.contains("積冰") {
            weatherIcon.image = UIImage.init(systemName: "snow")
        }
        else if Wx.text!.contains("暴風雪"){
            weatherIcon.image = UIImage.init(systemName: "wind.snow")
        }
        else if Wx.text!.contains("雪") {
            if Wx.text!.contains("雨") {
                weatherIcon.image = UIImage.init(systemName: "cloud.sleet")
            }
            else {
                weatherIcon.image = UIImage.init(systemName: "cloud.snow")
            }
        }
        else if Wx.text!.contains("雨") {
            if Wx.text!.contains("雷") {
                weatherIcon.image = UIImage.init(systemName: "cloud.bolt.rain")
            }
            else if Wx.text!.contains("晴"){
                weatherIcon.image = UIImage.init(systemName: "cloud.sun.rain")
            }
                
            else {
                weatherIcon.image = UIImage.init(systemName: "cloud.rain")
            }
        }
        else if Wx.text!.contains("晴") {
            if Wx.text!.contains("雲") {
                weatherIcon.image = UIImage.init(systemName: "cloud.sun")
            }
            else {
                weatherIcon.image = UIImage.init(systemName: "sun.max")
            }
        }
        else if Wx.text!.contains("陰") {
            weatherIcon.image = UIImage.init(systemName: "smoke.fill")
        }
        else if Wx.text!.contains("雲") {
            weatherIcon.image = UIImage.init(systemName: "smoke")
        }
        
    }
    
    // MARK:- 點擊一下畫面依序跳出選取器
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        locationView() // 點擊一下畫面可以選擇地點
    }
    
    func locationView() {
        let alertView = UIAlertController(
            title: "選擇地點",
            message: "\n\n\n\n\n\n\n\n\n", // 因為要放入選取器，使提示框高度增高
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .default,
            handler: nil
        )
        
        let okAction = UIAlertAction(
            title: "確認",
            style: .destructive,
            handler: {_ in
                self.loadJSON(locationName: self.selectLocation, time: self.selectTime)
                self.timeView()} // 選完地點接著選時間
        )
        
        alertView.view.addSubview(locationPickerView)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        
        present(alertView, animated: true, completion: nil)
    }
    func timeView() {
        let alertView = UIAlertController(
            title: "選擇時間",
            message: "\n\n\n\n\n\n\n\n\n", // 因為要放入選取器，使提示框高度增高
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .default,
            handler: nil
        )
        
        let okAction = UIAlertAction(
            title: "確認",
            style: .destructive,
            handler: {_ in self.loadJSON(locationName: self.selectLocation, time: self.selectTime)}
        )
        
        alertView.view.addSubview(timePickerView)
        alertView.addAction(cancelAction)
        alertView.addAction(okAction)
        
        present(alertView, animated: true, completion: nil)
    }

}

// MARK:- 選取器

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            
        if pickerView == locationPickerView {
            return location.count
        }
        if pickerView == timePickerView {
            return timeData.count // 三個時間區間
        }

        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == locationPickerView {
            return location[row]
        }
        if pickerView == timePickerView {
            return timeData[row]
        }

        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            
        if pickerView == locationPickerView {
            selectLocation = location[row] // 改變地點
        }
        if pickerView == timePickerView {
            selectTime = row // 改變時間
        }
        
    }
}
