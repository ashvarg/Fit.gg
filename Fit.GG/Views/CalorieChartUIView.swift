//
//  CalorieChartUIView.swift
//  Fit.GG
//
//  Created by Ashwin George on 2/6/2023.
//  Reference: https://youtu.be/ZMe6Xq2gCGs (Drawing Line Graph in SwiftUI)

import SwiftUI
import Charts

struct LineChartView: View{
    // y axis values
    let values: [Double]
    // x axis labels
    let labels: [String]
    
    let screenWidth = UIScreen.main.bounds.width
    private var path: Path{
        
        if values.isEmpty {
            return Path()
        }
        
        // offset between each data point
        var offsetX: Int = Int(screenWidth/CGFloat(values.count))
        var path = Path()
        path.move(to: CGPoint(x: offsetX, y: Int(values[0])))
        
        for value in values.dropFirst() {
            offsetX +=  Int(screenWidth/CGFloat(values.count))
            path.addLine(to: CGPoint(x: offsetX, y: Int(value)))
        }
        
        return path
    }
    var body: some View{
        VStack {
            // creates the path between each point
            path.stroke(Color.green, lineWidth: 2.0)
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z:0))
                
            
            HStack {
                ForEach(labels, id: \.self){ label in
                    Text(label)
                        .frame(width: screenWidth/CGFloat(labels.count) - 10)
                }
            }
        }
    }
}


struct CalorieChartUIView: View {
    var maxY: Double
    var minY: Double
    var labels: [String]
    var calories : [Double]
    
    // initialising the calorie graph
    init(data: [(Date, Double)]){
        maxY = 0.0
        minY = 0.0
        labels = []
        calories = []
        
        var sortedData = sortData(data: data)
        labels = convertToDateString(sortedData: sortedData)
        calories = getSortedValues(sortedData: sortedData)
            
        maxY = getMaxY(data: data)
        minY = getMinY(data: data)
        
    }
    
    var body: some View {
        VStack{
            Text("Calorie Graph")
            LineChartView(values: calories, labels: labels)
        }
    }

}

struct CalorieChartUIView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieChartUIView(data: defaultValues())
    }
}

func sortData(data: [(date: Date,value: Double)]) -> [(date: Date,value: Double)]{
    /**
     Sorts data from earliest to latest data
     */
    let sortedData = data.sorted(by: {$0.date < $1.date})
    return sortedData
}



func getMinY(data: [(date:Date,value: Double)]) -> Double{
    /**
     Gets minimum value
     */
    var returnMin = Double(0)
    if let minValueTuple = data.min(by: {$0.value < $1.value}){
        let minValue = minValueTuple.value
        returnMin = minValue
    }
    
    else{
        print("Data Array is empty")
    }
    return returnMin
    
}

func getMaxY(data: [(date:Date,value: Double)]) -> Double{
    /**
     Gets maximum Value
     */
    var returnMax = Double(0)
    if let maxValueTuple = data.max(by: {$0.value < $1.value}){
        let maxValue = maxValueTuple.value
        returnMax = maxValue
    }
    
    else{
        print("Data Array is empty")
    }
    return returnMax
}

  
func getStartAndEndDate(from data: [(date: Date, value: Double)]) -> (startDate: Date?, endDate: Date?) {
    /**
     Gets starting and ending date
     */
    let startDate = data.min(by: { $0.date < $1.date })?.date
    let endDate = data.max(by: { $0.date < $1.date })?.date
    return (startDate, endDate)
}


func convertToDateString(sortedData: [(date: Date,value: Double)]) -> [String]{
    /**
     Converts the date object to a string
     */
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dateString = sortedData.map { dateFormatter.string(from: $0.date)}
    return dateString
    
}

func getSortedValues(sortedData: [(date: Date, value: Double)]) -> [Double]{
    /*
     gets sorted values
     */
    let sortedValues = sortedData.map {$0.value }
    return sortedValues
}

func defaultValues() -> [(date: Date,value: Double)]{
    /*
     Default values to show in the preview
     */
    var data: [(date: Date,value: Double)] = []
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        let endDate = Date()

        // Generate data for each date in the range
        var currentDate = startDate
        while currentDate <= endDate {
            // Generate a random value for each date
            let randomValue = Double.random(in: 0...100)

            // Append the tuple to the data array
            data.append((date: currentDate, value: randomValue))

            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return data
}
