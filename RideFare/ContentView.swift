import SwiftUI

struct ContentView: View {
    @StateObject var store = FareStore()
    @State private var selectedRuleIndex = ContentView.defaultIndex
    @State private var distanceInput: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showDetails: Bool = false

    static var defaultIndex: Int {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 7 && hour < 20 {
            return 0 // 07:00 - 19:59
        } else if hour >= 20 {
            return 1 // 20:00 - 23:59
        } else {
            return 2 // 00:00 - 06:59
        }
    }

    private func calculateDetails() -> (total: Double, distance: Double, distanceCost: Double, longDistanceCost: Double, rule: FareRule)? {
        guard let inputDistance = Double(distanceInput),
              store.rules.indices.contains(selectedRuleIndex) else {
            return nil
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
        
        return (base + distanceCost + longDistanceCost, distance, distanceCost, longDistanceCost, rule)
    }

    var calculatedPrice: Double {
        calculateDetails()?.total ?? 0.0
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
                    
                    if calculatedPrice > 0 {
                        Button(action: { withAnimation { showDetails.toggle() } }) {
                            HStack {
                                Text(showDetails ? "收起明细" : "查看明细")
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showDetails ? 90 : 0))
                            }
                            .font(.subheadline)
                        }
                        
                        if showDetails, let details = calculateDetails() {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("起步价 (含\(Int(details.rule.baseDistance))公里)")
                                    Spacer()
                                    Text("¥\(String(format: "%.2f", details.rule.baseFare))")
                                }
                                HStack {
                                    let extraDistance = max(0, details.distance - details.rule.baseDistance)
                                    Text("里程费 (\(String(format: "%.0f", extraDistance))公里 * \(String(format: "%.2f", details.rule.unitPrice))元)")
                                    Spacer()
                                    Text("¥\(String(format: "%.2f", details.distanceCost))")
                                }
                                if details.longDistanceCost > 0 || details.distance > details.rule.longDistanceThreshold {
                                    HStack {
                                        let longDistance = max(0, details.distance - details.rule.longDistanceThreshold)
                                        Text("远途费 (\(String(format: "%.0f", longDistance))公里 * \(String(format: "%.2f", details.rule.longDistanceSurcharge))元)")
                                        Spacer()
                                        Text("¥\(String(format: "%.2f", details.longDistanceCost))")
                                    }
                                }
                            }
                            .font(.caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
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
