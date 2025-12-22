import SwiftUI

struct ContentView: View {
    @StateObject var store = FareStore()
    @State private var selectedRuleIndex = ContentView.defaultIndex
    @State private var distanceInput: String = ""
    @FocusState private var isInputFocused: Bool

    static var defaultIndex: Int {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 10 && hour < 19 {
            return 0 // 10:00 - 18:59 -> 19点前
        } else if hour >= 19 {
            return 1 // 19:00 - 23:59 -> 24点前
        } else {
            return 2 // 00:00 - 09:59 -> 24点后
        }
    }

    var calculatedPrice: Double {
        guard let inputDistance = Double(distanceInput),
              store.rules.indices.contains(selectedRuleIndex) else {
            return 0.0
        }
        let distance = ceil(inputDistance)
        let rule = store.rules[selectedRuleIndex]
        
        // 价格计算逻辑：
        // 1. 起步价
        // 2. 超出起步里程的部分 * 单价
        // 3. 超出远途门槛的部分 * 远途附加费
        
        let base = rule.baseFare
        let distanceCost = max(0, distance - rule.baseDistance) * rule.unitPrice
        let rawLongDistanceCost = max(0, distance - rule.longDistanceThreshold) * rule.longDistanceSurcharge
        let longDistanceCost = min(rawLongDistanceCost, rule.longDistanceCap)
        
        return base + distanceCost + longDistanceCost
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 1. 时间段选择
                Picker("时间段", selection: $selectedRuleIndex) {
                    ForEach(store.rules.indices, id: \.self) { index in
                        Text(store.rules[index].name).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // 2. 输入框
                VStack(alignment: .leading) {
                    Text("行驶里程 (公里)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("请输入公里数", text: $distanceInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFocused)
                        .font(.title)
                }
                .padding(.horizontal)

                // 3. 价格显示
                VStack(spacing: 10) {
                    Text("预估价格")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("¥\(String(format: "%.2f", calculatedPrice))")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)

                Spacer()
            }
            .navigationTitle("代驾计算器")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        isInputFocused = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(store: store)) {
                        Image(systemName: "gear")
                        Text("设置")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
