//
//  AlertContentPresentable.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 13.08.2025.
//

import UIKit

protocol AlertContentPresentable {
    var alert: UIViewController { get }
    var isAnimated: Bool { get }
}

protocol AlertFactoryService: AnyObject {
    func showNetworkError(
        message: String,
        cancelHandler: @escaping () -> Void,
        repeatHadler: @escaping () -> Void
    ) -> AlertContentPresentable
}

struct AlertContent: AlertContentPresentable {
    var alert: UIViewController
    var isAnimated: Bool
}

final class AlertFactoryServiceImpl: AlertFactoryService {
    func showNetworkError(
        message: String,
        cancelHandler: @escaping () -> Void,
        repeatHadler: @escaping () -> Void
    ) -> any AlertContentPresentable {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Отсутствует подключение к интернету",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Отменить",
            style: .cancel,
            handler: { _ in
                cancelHandler()
            })
        )
        
        alert.addAction(UIAlertAction(
            title: "Повторить",
            style: .default,
            handler: { _ in
                repeatHadler()
            })
        )
        return AlertContent(
            alert: alert,
            isAnimated: true
        )
    }
}
