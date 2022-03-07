//
//  AppMetrics.swift
//  
//
//  Created by Alessandro Pavesi on 22/01/22.
//

import Foundation
import MetricKit

public class AppMetrics: NSObject, MXMetricManagerSubscriber {
    func receiveReports() {
       let shared = MXMetricManager.shared
       shared.add(self)
    }

    func pauseReports() {
       let shared = MXMetricManager.shared
       shared.remove(self)
    }

    // Receive daily metrics.
    public func didReceive(_ payloads: [MXMetricPayload]) {
       // Process metrics.
        print("Metrics")
        guard let firstPayload = payloads.first else { return }
        print(firstPayload.dictionaryRepresentation())
    }

    // Receive diagnostics immediately when available.
    public func didReceive(_ payloads: [MXDiagnosticPayload]) {
       // Process diagnostics.
        print("Diagnostic")
        guard let firstPayload = payloads.first else { return }
        print(firstPayload.dictionaryRepresentation())
    }
}

public let RLMetrics = AppMetrics()
