//
//  Topic002View.swift
//  SwiftUIWeeklyLayoutChallenge
//
//  Created by treastrain on 2022/07/20.
//

import SwiftUI
import Foundation

// MARK: - Entities
struct Vital: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let value: Value
    let date: Date
    let iconSystemName: String
    let color: Color
    
    enum Value {
        case percent(_ percent: Double)
        case count(_ count: Int, unit: String)
        case duration(_ duration: Duration)
        case temperature(_ measurement: Measurement<UnitTemperature>, usage: MeasurementFormatUnitUsage<UnitTemperature> = .asProvided)
    }
}

// MARK: - Sample Data
fileprivate let vitalData: [Vital] = [
    .init(title: "取り込まれた酸素のレベル", value: .percent(0.99), date: Date(timeIntervalSinceNow: -300), iconSystemName: "o.circle.fill", color: .blue),
    .init(title: "心拍数", value: .count(61, unit: "拍/分"), date: Date(timeIntervalSinceNow: -5400), iconSystemName: "heart.fill", color: .red),
    .init(title: "睡眠", value: .duration(.seconds(451 * 60)), date: Date(timeIntervalSinceNow: -87000), iconSystemName: "bed.double.fill", color: .green),
    .init(title: "体温", value: .temperature(.init(value: 36.4, unit: .celsius)), date: Date(timeIntervalSinceNow: -172800), iconSystemName: "thermometer", color: .red),
]

// MARK: - Views
/// <doc:Topic002>
public struct Topic002View: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            navigationContent(vitalData)
                .navigationTitle("バイタルデータ")
        }
    }
    
    func navigationContent(_ vitalData: [Vital]) -> some View {
        #if os(tvOS) || os(watchOS)
        List(vitalData) { datum in
            NavigationLink(destination: EmptyView()) {
                VitalDataItemView(data: datum, isListContent: true)
                    .padding()
            }
        }
        #else
        ScrollView {
            ForEach(vitalData) { datum in
                LazyVStack(spacing: 10) {
                    NavigationLink(destination: EmptyView()) {
                        VitalDataItemView(data: datum, isListContent: false)
                            .foregroundColor(.primary)
                            .padding()
                    }
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(10)
                }.padding(.horizontal, 10)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        #endif
    }
}

struct VitalDataItemView: View {
    let data: Vital
    var isListContent: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Label(
                    data.title,
                    systemImage: data.iconSystemName
                )
                .foregroundColor(data.color)
                .font(.headline)
                .layoutPriority(1)
                
                Spacer()
                
                Text(data.date.formatted(.relative(presentation: .named)))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if !isListContent {
                    Image(systemName: "chevron.right")
                        .font(.callout.bold())
                        .foregroundStyle(.secondary)
                }
            }
            Text(attributedString(data.value).vitalAttributed())
        }
    }
    
    private func attributedString(_ value: Vital.Value) -> AttributedString {
        switch value {
        case .percent(let value):
            return value.formatted(.percent.attributed)
        case .count(_, _):
            return AttributedString("カスタムUnit諦めました")
        case .duration(let duration):
            return duration.formatted(.units().attributed)
        case .temperature(let measurement, let usage):
            return measurement.formatted(.measurement(width: .narrow, usage: usage).attributed)
        }
    }
}

extension AttributedString {
    func vitalAttributed() -> AttributedString {
        var attributedString = self
        
        let boldAttributes = AttributeContainer
            .foregroundColor(.primary)
            .font(.system(.title, design: .rounded, weight: .medium))
        let normalAttributes = AttributeContainer
            .foregroundColor(.secondary)
            .font(.system(.body, design: .rounded))
        
        let numberSymbol = AttributeContainer.numberSymbol(.percent)
        attributedString.replaceAttributes(numberSymbol, with: normalAttributes)
        
        let integer = AttributeContainer.numberPart(.integer)
        attributedString.replaceAttributes(integer, with: boldAttributes)
        
        let value = AttributeContainer.measurement(.value)
        attributedString.replaceAttributes(value, with: boldAttributes)
        
        let unit = AttributeContainer.measurement(.unit)
        attributedString.replaceAttributes(unit, with: normalAttributes)
        
        return attributedString
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Topic002View()
    }
}

class UnitConverterInverse: UnitConverter {
    var coefficient: Double

    init(coefficient: Double) {
        self.coefficient = coefficient
    }

    override func baseUnitValue(fromValue value: Double) -> Double {
        return coefficient / value
    }

    override func value(fromBaseUnitValue baseUnitValue: Double) -> Double {
        return coefficient / baseUnitValue
    }
}

extension UnitSpeed {
    static let minutesPerKilometer = UnitSpeed(symbol: "min/km",
        converter: UnitConverterInverse(coefficient: 1000.0 / 60.0))
}


